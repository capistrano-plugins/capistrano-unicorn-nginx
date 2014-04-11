require 'capistrano/dsl/unicorn_paths'
require 'capistrano/unicorn_nginx/helpers'

include Capistrano::UnicornNginx::Helpers
include Capistrano::DSL::UnicornPaths

namespace :load do
  task :defaults do
    set :unicorn_service, -> { "unicorn_#{fetch(:application)}_#{fetch(:stage)}" }
    set :templates_path, 'config/deploy/templates'
    set :unicorn_pid, -> { unicorn_default_pid_file }
    set :unicorn_config, -> { unicorn_default_config_file }
    set :unicorn_workers, 2
    # set :unicorn_user # default set in `unicorn:defaults` task

    set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids')
  end
end

namespace :unicorn do

  task :defaults do
    on roles :app do
      set :unicorn_user, fetch(:unicorn_user, deploy_user)
    end
  end

  desc 'Setup Unicorn initializer'
  task :setup_initializer do
    on roles :app do
      next if file_exists? unicorn_initd_file
      sudo_upload! template('unicorn_init.erb'), unicorn_initd_file
      execute :chmod, '+x', unicorn_initd_file
      sudo 'update-rc.d', '-f', fetch(:unicorn_service), 'defaults'
    end
  end

  desc 'Setup Unicorn app configuration'
  task :setup_app_config do
    on roles :app do
      next if file_exists? fetch(:unicorn_config)
      execute :mkdir, '-pv', File.dirname(fetch(:unicorn_config))
      upload! template('unicorn.rb.erb'), fetch(:unicorn_config)
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles :app do
        execute :service, fetch(:unicorn_service), command
      end
    end
  end

  before :setup_initializer, :defaults

end

namespace :deploy do
  after :publishing, 'unicorn:restart'
end

desc 'Server setup tasks'
task :setup do
  invoke 'unicorn:setup_initializer'
  invoke 'unicorn:setup_app_config'
end
