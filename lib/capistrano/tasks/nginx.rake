require 'capistrano/dsl/nginx_paths'
require 'capistrano/unicorn_nginx/helpers'

include Capistrano::UnicornNginx::Helpers
include Capistrano::DSL::NginxPaths

namespace :load do
  task :defaults do
    set :templates_path, 'config/deploy/templates'
    set :nginx_config_name, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :nginx_pid, nginx_default_pid_file
    # set :nginx_server_name # default set in the `nginx:defaults` task
    # ssl options
    set :nginx_location, '/etc/nginx'

    set :nginx_use_ssl, false
    set :nginx_ssl_cert, -> { nginx_default_ssl_cert_file_name }
    set :nginx_ssl_cert_key, -> { nginx_default_ssl_cert_key_file_name }
    set :nginx_upload_local_cert, true
    set :nginx_ssl_cert_local_path, -> { ask(:nginx_ssl_cert_local_path, 'Local path to ssl certificate: ') }
    set :nginx_ssl_cert_key_local_path, -> { ask(:nginx_ssl_cert_key_local_path, 'Local path to ssl certificate key: ') }

    set :nginx_overwrite_config, false # set to true if you want to overwrite nginx config files on next `cap setup`

    set :linked_dirs, fetch(:linked_dirs, []).push('log')
  end
end

namespace :nginx do

  task :defaults do
    on roles :web do
      set :nginx_server_name, fetch(:nginx_server_name, host.to_s)
    end
  end

  # this is needed when the web role is a non release role -> directories are not created, and nginx log files are
  # written to [shared_path]/log/
  desc "Create the nginx log directory"
  task :create_log_dir do
    on roles :web do
      # create the deploy_to, shared_path and the directory in which the nginx_access_log_file resides.
      # ensure that all are created with the correct ownership
      [fetch(:deploy_to), shared_path, File.dirname(nginx_access_log_file)].each do |dir|
        next if file_exists? dir

        sudo :mkdir, '-pv', dir
        user = capture :id, '-un'
        group = capture :id, '-gn'
        sudo :chown, "#{user}:#{group}", dir
      end
    end
  end

  desc 'Setup nginx configuration'
  task setup: [:create_log_dir] do
    on roles :web do
      next if !fetch(:nginx_overwrite_config) && file_exists?(nginx_sites_available_file)
      sudo_upload! template('nginx_conf.erb'), nginx_sites_available_file
      sudo :ln, '-fs', nginx_sites_available_file, nginx_sites_enabled_file
    end
  end

  desc 'Setup nginx ssl certs'
  task :setup_ssl do
    next unless fetch(:nginx_use_ssl)
    on roles :web do
      next if !fetch(:nginx_overwrite_config) && file_exists?(nginx_ssl_cert_file) && file_exists?(nginx_ssl_cert_key_file)
      if fetch(:nginx_upload_local_cert)
        sudo_upload! fetch(:nginx_ssl_cert_local_path), nginx_ssl_cert_file
        sudo_upload! fetch(:nginx_ssl_cert_key_local_path), nginx_ssl_cert_key_file
      end
      sudo :chown, 'root:root', nginx_ssl_cert_file
      sudo :chown, 'root:root', nginx_ssl_cert_key_file
    end
  end

  desc 'Reload nginx configuration'
  task :reload do
    on roles :web do
      sudo nginx_service_path, 'reload'
    end
  end

  before :setup, :defaults
  before :setup_ssl, :defaults

end

namespace :deploy do
  after :publishing, 'nginx:reload'
end

desc 'Server setup tasks'
task :setup do
  invoke 'nginx:setup'
  invoke 'nginx:setup_ssl'
end
