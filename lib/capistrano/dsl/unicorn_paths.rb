module Capistrano
  module DSL
    module UnicornPaths

      def unicorn_initd_file
        "/etc/init.d/#{fetch(:unicorn_service)}"
      end

      def unicorn_default_config_file
        shared_path.join('config/unicorn.rb')
      end

      def unicorn_default_pid_file
        shared_path.join('tmp/pids/unicorn.pid')
      end

      def unicorn_log_file
        shared_path.join('log/unicorn.stdout.log')
      end

      def unicorn_error_log_file
        shared_path.join('log/unicorn.stderr.log')
      end

    end
  end
end
