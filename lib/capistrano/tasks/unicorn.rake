require 'capistrano/unicorn_nginx/helpers'

include Capistrano::UnicornNginx::Helpers

namespace :load do
  task :defaults do
    set :unicorn_service_name, -> { "unicorn_#{fetch(:application)}_#{fetch(:stage)}" }
    set :templates_path, "config/deploy/templates"
    set :unicorn_pid, -> { shared_path.join("tmp/pids/unicorn.pid") }
    set :unicorn_config, -> { shared_path.join("config/unicorn.rb") }
    set :unicorn_log, -> { shared_path.join("log/unicorn.log") }
    set :unicorn_user, nil # user is set by executing `id -un` on the server
    set :unicorn_workers, 2
  end
end

namespace :unicorn do
  desc 'Setup Unicorn initializer'
  task :setup_initializer do
    on roles :app do
      next if file_exists? "/etc/init.d/#{fetch(:unicorn_service_name)}"

      set :unicorn_user, capture(:id, '-un') unless fetch(:unicorn_user)
      init_tmp = "#{fetch(:tmp_dir)}/unicorn_init"

      template 'unicorn_init.erb', init_tmp
      execute :chmod, "+x", init_tmp
      sudo :mv, init_tmp, "/etc/init.d/#{fetch(:unicorn_service_name)}"
      sudo 'update-rc.d', '-f', fetch(:unicorn_service_name), 'defaults'
    end
  end

  desc 'Setup Unicorn app configuration'
  task :setup_app_config do
    on roles :app do
      next if file_exists? fetch(:unicorn_config)

      execute :mkdir, '-p', shared_path.join('config')
      execute :mkdir, '-p', shared_path.join('log')
      execute :mkdir, '-p', shared_path.join('tmp/pids')
      template 'unicorn.rb.erb', fetch(:unicorn_config)
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles :app do
        execute :service, fetch(:unicorn_service_name), command
      end
    end
  end
end

namespace :deploy do
  after :updated, 'unicorn:setup_initializer'
  after :updated, 'unicorn:setup_app_config'
  after :publishing, 'unicorn:restart'
end
