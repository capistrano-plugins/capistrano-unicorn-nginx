require 'capistrano/unicorn_nginx/helpers'

include Capistrano::UnicornNginx::Helpers

namespace :load do
  task :defaults do
    set :templates_path, "config/deploy/templates"
    set :nginx_server_name, -> { ask(:nginx_server_name, "Nginx server name: ") }
    set :nginx_config_name, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :nginx_pid, "/run/nginx.pid"
    # ssl options
    set :nginx_use_ssl, false
    set :nginx_ssl_cert, -> { "#{fetch(:nginx_server_name)}.crt" }
    set :nginx_ssl_cert_key, -> { "#{fetch(:nginx_server_name)}.key" }
    set :nginx_upload_local_cert, true
    set :nginx_ssl_cert_local_path, -> { ask(:nginx_ssl_cert_local_path, "Local path to ssl certificate: ") }
    set :nginx_ssl_cert_key_local_path, -> { ask(:nginx_ssl_cert_key_local_path, "Local path to ssl certificate key: ") }
  end
end

namespace :nginx do
  desc "Setup nginx configuration"
  task :setup do
    on roles :web do
      config_name = fetch(:nginx_config_name)
      next if file_exists? "/etc/nginx/sites-available/#{config_name}"

      execute :mkdir, "-p", shared_path.join("log")
      template "nginx_conf.erb", "#{fetch(:tmp_dir)}/#{config_name}"
      sudo :mv, "#{fetch(:tmp_dir)}/#{config_name}", "/etc/nginx/sites-available/#{config_name}"
      sudo :ln, "-fs", "/etc/nginx/sites-available/#{config_name}", "/etc/nginx/sites-enabled/#{config_name}"
    end
  end

  desc "Setup nginx ssl certs"
  task :setup_ssl do
    on roles :web do
      next unless fetch(:nginx_use_ssl)
      next if file_exists?("/etc/ssl/certs/#{fetch(:nginx_ssl_cert)}") && file_exists?("/etc/ssl/private/#{fetch(:nginx_ssl_cert_key)}")

      if fetch(:nginx_upload_local_cert)
        upload! fetch(:nginx_ssl_cert_local_path), "#{fetch(:tmp_dir)}/#{fetch(:nginx_ssl_cert)}"
        upload! fetch(:nginx_ssl_cert_key_local_path), "#{fetch(:tmp_dir)}/#{fetch(:nginx_ssl_cert_key)}"
        sudo :mv, "#{fetch(:tmp_dir)}/#{fetch(:nginx_ssl_cert)}", "/etc/ssl/certs/#{fetch(:nginx_ssl_cert)}"
        sudo :mv, "#{fetch(:tmp_dir)}/#{fetch(:nginx_ssl_cert_key)}", "/etc/ssl/private/#{fetch(:nginx_ssl_cert_key)}"
      end
      sudo :chown, "root:root", "/etc/ssl/certs/#{fetch(:nginx_ssl_cert)}"
      sudo :chown, "root:root", "/etc/ssl/private/#{fetch(:nginx_ssl_cert_key)}"
    end
  end

  desc "Reload nginx configuration"
  task :reload do
    on roles :web do
      sudo "/etc/init.d/nginx reload"
    end
  end
end

namespace :deploy do
  after :started, "nginx:setup"
  after :started, "nginx:setup_ssl"
  after :publishing, "nginx:reload"
end
