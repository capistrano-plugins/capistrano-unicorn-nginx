module Capistrano
  module DSL
    module NginxPaths

      def nginx_sites_available_file
        "#{fetch(:nginx_location)}/sites-available/#{fetch(:nginx_config_name)}"
      end

      def nginx_sites_enabled_file
        "#{fetch(:nginx_location)}/sites-enabled/#{fetch(:nginx_config_name)}"
      end

      def nginx_service_path
        '/etc/init.d/nginx'
      end

      def nginx_default_pid_file
        '/run/nginx.pid'
      end

      # ssl related files
      def nginx_default_ssl_cert_file_name
        "#{fetch(:nginx_server_name)}.crt"
      end

      def nginx_default_ssl_cert_key_file_name
        "#{fetch(:nginx_server_name)}.key"
      end

      def nginx_ssl_cert_file
        "/etc/ssl/certs/#{fetch(:nginx_ssl_cert)}"
      end

      def nginx_ssl_cert_key_file
        "/etc/ssl/private/#{fetch(:nginx_ssl_cert_key)}"
      end

      # log files
      def nginx_access_log_file
        shared_path.join('log/nginx.access.log')
      end

      def nginx_error_log_file
        shared_path.join('log/nginx.error.log')
      end

    end
  end
end
