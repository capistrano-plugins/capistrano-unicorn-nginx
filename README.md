# Capistrano-Nginx-Unicorn

Capistrano tasks for configuration and management nginx+unicorn combo for zero downtime deployments of Rails applications.

Provides capistrano tasks to:

* easily add application to nginx and reload it's configuration
* create unicorn init script for application, so it will be automatically started when OS restarts
* start/stop unicorn (also can be done using `sudo service unicorn_<your_app> start/stop`)
* reload unicorn using `USR2` signal to load new application version with zero downtime
* creates logrotate record to rotate application logs

Provides several capistrano variables for easy customization.
Also, for full customization, all configs can be copied to the application using generators.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-nginx-unicorn', require: false, group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-nginx-unicorn

## Usage

Add this line to your `deploy.rb`

    require 'capistrano-nginx-unicorn'

Note, that following capistrano variables should be defined:

    application
    current_path
    shared_path
    user

You can check that new tasks are available (`cap -T`):

for nginx:

    # add and enable application to nginx
    cap nginx:setup

    # reload nginx configuration
    cap nginx:reload

and for unicorn:

    # create unicorn configuration and init script
    cap unicorn:setup

    # start unicorn
    cap unicorn:start

    # stop unicorn
    cap unicorn:stop

    # reload unicorn with no downtime
    # old workers will process new request until new master is fully loaded
    # then old workers will be automatically killed and new workers will start processing requests
    cap unicorn:restart

and shared:

    # create logrotate record to rotate application logs
    cap logrotate

There is no need to execute any of these tasks manually.
They will be called automatically on different deploy stages:

* `nginx:setup`, `nginx:reload`, `unicorn:setup` and `logrotate` are hooked to `deploy:setup`
* `unicorn:restart` is hooked to `deploy:restart`

This means that if you run `cap deploy:setup`,
nginx and unicorn will be automatically configured.
And after each deploy, unicorn will be automatically reloaded.

However, if you changed variables or customized templates,
you can run any of these tasks to update configuration.

## Customization

### Using variables

You can customize nginx and unicorn configs using capistrano variables:


```ruby
# path to customized templates (see below for details)
# default value: "config/deploy/templates"
set :templates_path, "config/deploy/templates"

# server name for nginx, default value: no (will be prompted if not set)
# set this to your site name as it is visible from outside
# this will allow 1 nginx to serve several sites with different `server_name`
set :nginx_server_name, "example.com"

# path, where unicorn pid file will be stored
# default value: `"#{current_path}/tmp/pids/unicorn.pid"`
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

# path, where nginx pid file will be stored (used in logrotate recipe)
# default value: `"/run/nginx.pid"`
set :nginx_pid, "/run/nginx.pid"

# path, where unicorn config file will be stored
# default value: `"#{shared_path}/config/unicorn.rb"`
set :unicorn_config, "#{shared_path}/config/unicorn.rb"

# path, where unicorn log file will be stored
# default value: `"#{shared_path}/config/unicorn.rb"`
set :unicorn_log, "#{shared_path}/config/unicorn.rb"

# user name to run unicorn
# default value: `user` (user varibale defined in your `deploy.rb`)
set :unicorn_user, "user"

# number of unicorn workers
# default value: no (will be prompted if not set)
set :unicorn_workers, 4

# if set, nginx will be configured to 443 port and port 80 will be auto rewritten to 443
# also, on `nginx:setup`, paths to ssl certificate and key will be configured
# and certificate file and key will be copied to `/etc/ssl/certs` and `/etc/ssl/private/` directories
# default value: false
set :nginx_use_ssl, false

# if set, it will ask to upload certificates from a local path. Otherwise, it will expect
# the certificate and key defined in the next 2 variables to be already in the server.
set :nginx_upload_local_certificate, { true }

# remote file name of the certificate, only makes sense if `nginx_use_ssl` is set
# default value: `nginx_server_name + ".crt"`
set :nginx_ssl_certificate, "#{nginx_server_name}.crt"

# remote file name of the certificate, only makes sense if `nginx_use_ssl` is set
# default value: `nginx_server_name + ".key"`
set :nginx_ssl_certificate_key, "#{nginx_server_name}.key"

# local path to file with certificate, only makes sense if `nginx_use_ssl` is set
# this file will be copied to remote server
# default value: none (will be prompted if not set)
set :nginx_ssl_certificate_local_path, "/home/ivalkeen/ssl/myssl.cert"

# local path to file with certificate key, only makes sense if `nginx_use_ssl` is set
# this file will be copied to remote server
# default value: none (will be prompted if not set)
set :nginx_ssl_certificate_key_local_path, "/home/ivalkeen/ssl/myssl.key"
```

For example, of you site name is `example.com` and you want to use 8 unicorn workers,
your `deploy.rb` will look like this:

```ruby
set :server_name, "example.com"
set :unicorn_workers, 4
require 'capistrano-nginx-unicorn'
```

### Template Customization

If you want to change default templates, you can generate them using `rails generator`

    rails g capistrano:nginx_unicorn:config

This will copy default templates to `config/deploy/templates` directory,
so you can customize them as you like, and capistrano tasks will use this templates instead of default.

You can also provide path, where to generate templates:

    rails g capistrano:nginx_unicorn:config config/templates

# TODO:

* add tests

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
