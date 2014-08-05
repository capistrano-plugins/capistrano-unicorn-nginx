# Capistrano::UnicornNginx

Capistrano tasks for automatic and sensible unicorn + nginx configuraion.

Goals of this plugin:

* automatic unicorn and nginx configuration for Rails apps
* **no manual ssh** to the server required
* zero downtime deployments enabled

Specifics:

* generates nginx config file on the server
* generates unicorn initializer and config files<br/>
application is started automatically after server restart
* capistrano tasks for server management, example: `unicorn:restart`<br/>
see below for all available tasks

`capistrano-unicorn-nginx` works only with Capistrano 3!

This project was based on
[capistrano-nginx-unicorn](https://github.com/kalys/capistrano-nginx-unicorn).
I contributed a lot to Capistrano 3 version of that plugin. In the end I
decided to create my own project to bring in additional improvements, without
having to ask for permissions and wait for merging.

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.1'
      gem 'capistrano-unicorn-nginx', '~> 2.0'
    end

And then:

    $ bundle install

### Setup and usage

Add this line to `Capfile`

    require 'capistrano/unicorn_nginx'

Only if you already have a domain for your app, set `nginx_server_name` in
stage file, example `config/deploy/production.rb`:

    set :nginx_server_name, 'mydomain.com'

If you don't have a domain yet, you do not have to do anything
(`nginx_server_name` will use the default value - server IP).

**SSL only setup**

If you want to setup SSL for your page, add these options to stage file
(i.e. `config/deploy/production.rb`):

    # ignore this if you do not need SSL
    set :nginx_use_ssl, true
    set :nginx_ssl_cert_local_path, "/path/to/ssl_cert.crt"
    set :nginx_ssl_cert_key_local_path, "/path/to/ssl_cert.key"

And you're all set!

**Setup task**

Make sure the `deploy_to` path exists and has the right privileges on the
server (i.e. `/var/www/myapp`).<br/>
Or just install
[capistrano-safe-deploy-to](https://github.com/bruno-/capistrano-safe-deploy-to)
plugin and don't think about it.

To setup the server for unicorn and nginx, run:

    $ bundle exec cap production setup

### Configuration

As described in the Usage section, this plugin works with minimal setup.
However, configuration is possible.

You'll find the options and their defaults below.

In order to override the default, put the option in the stage file, for example:

    # in config/deploy/production.rb
    set :unicorn_workers, 4

**Nginx options**

Defaults are listed near option name in the first line.

- `set :nginx_server_name` # defaults to <server_IP><br/>
Your application's domain. The default is your server's IP address.

- `set :nginx_pid, "/run/nginx.pid"`<br/>
Path for nginx process pid file.

- `set :nginx_location, "/etc/nginx"`<br/>
Nginx installation directory.

SSL related options:

- `set :nginx_use_ssl, false`<br/>
If set to `true`, nginx will be configured to 443 port and port 80 will be auto
routed to 443. Also, on `nginx:setup`, paths to ssl certificate and key will be
configured. Certificate file and key will be uploaded to `/etc/ssl/certs/`
and `/etc/ssl/private/` directories on the server.

- `set :nginx_upload_local_cert, true`<br/>
If `true`, certificates will be uploaded from a local path. Otherwise, it
is expected for the certificate and key defined in the next 2 variables to be
already on the server.

- `set :nginx_ssl_cert, "#{fetch(:nginx_server_name)}.crt"`<br/>
Remote file name of the certificate. Only makes sense if `nginx_use_ssl` is set.

- `set :nginx_ssl_cert_key, "#{fetch(:nginx_server_name)}.key"`<br/>
Remote file name of the certificate. Only makes sense if `nginx_use_ssl` is set.

- `set :nginx_ssl_cert_local_path` # no default, required if
`nginx_use_ssl = true` and `nginx_upload_local_cert = true`<br/>
Local path to file with certificate. Only makes sense if `nginx_use_ssl` is
set. This file will be copied to remote server. Example value:
`set :nginx_ssl_cert_local_path, "/home/user/ssl/myssl.cert"`

- `set :nginx_ssl_cert_key_local_path` # no default<br/>
Local path to file with certificate key. Only makes sense if `nginx_use_ssl` is set.
This file will be copied to remote server. Example value:
`set :nginx_ssl_cert_key_local_path, "/home/user/ssl/myssl.key"`

**Unicorn options**

Defaults are listed near option name in the first line.

- `set :unicorn_service, "unicorn_#{fetch(:application)}_#{fetch(:stage)}`<br/>
Unicorn service name is `unicorn_myapp_production` by default.

- `set :unicorn_pid, shared_path.join("tmp/pids/unicorn.pid")`<br/>
Path for unicorn process pid file.

- `set :unicorn_config, shared_path.join("config/unicorn.rb")`<br/>
Path for unicorn config file.

- `set :unicorn_workers, 2`<br/>
Number of unicorn workers.

### How it works

Here's what happens when you run `$ bundle exec cap production setup`:

**Nginx**

- `nginx:setup`<br/>
Generates and uploads nginx config file. Symlinks config file to
`/etc/nginx/sites-enabled`.
- `nginx:setup_ssl`<br/>
Performs SSL related tasks if `nginx_use_ssl` is true (false by default).

**Unicorn**

- `unicorn:setup_initializer`<br/>
Uploads unicorn initializer file.
- `unicorn:setup_app_config`<br/>
Generates unicorn application config file

**Capistrano `deploy` task**

This plugin also integrates seamlessly with Capistrano `deploy` task.
Here's what happens when you run `$ bundle exec cap production deploy`:

- `after :publishing, "nginx:reload"`<br/>
Reloads nginx.
- `after :publishing, "unicorn:restart"`<br/>
Restarts unicorn after new release.

### Template customization

If you want to change default templates, you can generate them using
`rails generator`:

    $ bundle exec rails g capistrano:unicorn_nginx:config

This will copy default templates to `config/deploy/templates` directory, so you
can customize them as you like, and capistrano tasks will use this templates
instead of default.

You can also provide path, where to generate templates:

    $ bundle exec rails g capistrano:unicorn_nginx:config config/templates

### More Capistrano automation?

If you'd like to streamline your Capistrano deploys, you might want to check
these zero-configuration, plug-n-play plugins:

- [capistrano-postgresql](https://github.com/bruno-/capistrano-postgresql)<br/>
plugin that automates postgresql configuration and setup
- [capistrano-rbenv-install](https://github.com/bruno-/capistrano-rbenv-install)<br/>
would you like Capistrano to install rubies for you?
- [capistrano-safe-deploy-to](https://github.com/bruno-/capistrano-safe-deploy-to)<br/>
if you're annoyed that Capistrano does **not** create a deployment path for the
app on the server (default `/var/www/myapp`), this is what you need!

### Bug reports and pull requests

...are very welcome!

### Thanks

[@kalys](https://github.com/kalys) - for his
[capistrano-nginx-unicorn](https://github.com/kalys/capistrano-nginx-unicorn)
plugin.
