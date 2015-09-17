require 'erb'

module Capistrano
  module UnicornNginx
    module Helpers

      def bundle_unicorn(*args)
        SSHKit::Command.new(:bundle, :exec, :unicorn, args).to_command
      end

      # renders the ERB template specified by template_name to string. Use the locals variable to pass locals to the
      # ERB template
      def template_to_s(template_name, locals = {})
        config_file = "#{fetch(:templates_path)}/#{template_name}"
        # if no customized file, proceed with default
        unless File.exists?(config_file)
          config_file = File.join(File.dirname(__FILE__), "../../generators/capistrano/unicorn_nginx/templates/#{template_name}")
        end

        ERB.new(File.read(config_file), nil, '-').result(ERBNamespace.new(locals).get_binding)
      end

      # renders the ERB template specified by template_name to a StringIO buffer
      def template(template_name, locals = {})
        StringIO.new(template_to_s(template_name, locals))
      end

      def file_exists?(path)
        test "[ -e #{path} ]"
      end

      def deploy_user
        capture :id, '-un'
      end

      def sudo_upload!(from, to)
        filename = File.basename(to)
        to_dir = File.dirname(to)
        tmp_file = "#{fetch(:tmp_dir)}/#{filename}"
        upload! from, tmp_file
        sudo :mv, tmp_file, to_dir
      end

      # Helper class to pass local variables to an ERB template
      class ERBNamespace
        def initialize(hash)
          hash.each do |key, value|
            singleton_class.send(:define_method, key) { value }
          end
        end

        def get_binding
          binding
        end
      end
    end
  end
end
