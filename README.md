# Capistrano::UnicornNginx

> NOTE: The instructions below are no longer necessary from version 4.1.0. 
> The dhparam file will be automatically generated if missing.
>
> IMPORTANT NOTE. When upgrading to 4.0.0, please ensure you have
> generated a new 2048 bits Diffie-Hellman group. Run the following command 
> on your server before installing this gem:
>
> `openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048` 
>
> See <https://weakdh.org/sysadmin.html> for more details.
>

Capistrano tasks for automatic and sensible unicorn + nginx configuraion.

Goals of this plugin:

* automatic unicorn and nginx configuration for Rails apps
* **no manual ssh** to the server required
* zero downtime deployments enabled
* support for single node as well as cluster deployments

Specifics:

* generates nginx config file on the server (web role)
* generates unicorn initializer and config files (app role)<br/>
application is started automatically after server restart
* capistrano tasks for server management, example: `unicorn:restart`<br/>
see below for all available tasks
* automatic load balancing setup when there are multiple `app` nodes

`capistrano-unicorn-nginx` works only with Capistrano 3!

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.6.1'
      gem 'capistrano-unicorn-nginx', '~> 4.1.0'
    end

And then:

    $ bundle install

### Setup and usage

Depending on your needs 2 general scenarios are covered:

- [single server setup](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Single-server-setup)<br/>
  A scenario where you run the webserver (nginx) and application server
  (unicorn) on the same node.
- [multiple server setup](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Multiple-server-setup)<br/>
  Webserver (nginx) and application server (unicorn) run on different nodes.
  
### Ubuntu 16.04 ###
In order for current version to work you need upstart installed instead of systemd.

`sudo apt-get install upstart-sysv package` 

This commando should remove `ubuntu-standard` and `systemd-sysv`.

After that go ahead and run `sudo update-initramfs -u`.

### Default log file directories

- nginx: `/var/log/nginx/`
- unicorn: `#{shared_path}/log/`

### Configuration

See the
[full options list on the wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Configuration).
Feel free to skip this unless you're looking for something specific.

### How it works

[How it works wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/How-it-works)
contains the list of tasks that the plugin executes.

You do not have to know this unless you want to learn more about the plugin internals.

### Template customization

[On template customization wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Template-customization)
see how to inspect, tweak and override templates for `nginx` and `unicorn`
config files.

Do not do this unless you have a specific need.

### More Capistrano automation?

Check out [capistrano-plugins](https://github.com/capistrano-plugins) github org.

### Bug reports and pull requests

...are very welcome!

### Thanks

[@kalys](https://github.com/kalys) - for his
[capistrano-nginx-unicorn](https://github.com/kalys/capistrano-nginx-unicorn)
plugin.
