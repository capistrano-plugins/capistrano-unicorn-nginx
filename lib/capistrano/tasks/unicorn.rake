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
    set :unicorn_logrotate_config, -> { unicorn_default_logrotate_config_file }
    set :unicorn_workers, 2
    set :unicorn_env, "" # environmental variables passed to unicorn/Ruby. Useful for GC tweaking, etc
    set :unicorn_worker_timeout, 30
    set :unicorn_tcp_listen_port, 8080
    set :unicorn_use_tcp, -> { roles(:app, :web).count > 1 } # use tcp if web and app nodes are on different servers
    set :unicorn_app_env, -> { fetch(:rails_env) || fetch(:stage) }
    # set :unicorn_user # default set in `unicorn:defaults` task

    set :unicorn_logrotate_enabled, false # by default, don't use logrotate to rotate unicorn logs

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
      sudo_upload! template('unicorn_init.erb'), unicorn_initd_file
      execute :chmod, '+x', unicorn_initd_file
      sudo 'update-rc.d', '-f', fetch(:unicorn_service), 'defaults'
    end
  end

  desc 'Setup Unicorn app configuration'
  task :setup_app_config do
    on roles :app do
      execute :mkdir, '-pv', File.dirname(fetch(:unicorn_config))
      upload! template('unicorn.rb.erb'), fetch(:unicorn_config)
    end
  end

  desc 'Setup logrotate configuration'
  task :setup_logrotate do
    on roles :app do
      sudo :mkdir, '-pv', File.dirname(fetch(:unicorn_logrotate_config))
      sudo_upload! template('unicorn-logrotate.rb.erb'), fetch(:unicorn_logrotate_config)
      sudo 'chown', 'root:root', fetch(:unicorn_logrotate_config)
    end
  end

  %w[start stop reload upgrade].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles :app do
        sudo 'service', fetch(:unicorn_service), command
      end
    end
  end

  desc 'restart unicorn'
  task 'restart' do
    on roles :app do
      if test "[ -f #{fetch(:unicorn_pid)} ]"
        sudo 'service', fetch(:unicorn_service), 'upgrade'
      else
        sudo 'service', fetch(:unicorn_service), 'start'
      end
    end
  end

  before :setup_initializer, :defaults
  before :setup_logrotate, :defaults

end

namespace :deploy do
  after :publishing, 'unicorn:restart'
end

desc 'Server setup tasks'
task :setup do
  invoke 'unicorn:setup_initializer'
  invoke 'unicorn:setup_app_config'
  if fetch(:unicorn_logrotate_enabled)
    invoke 'unicorn:setup_logrotate'
  end
end
