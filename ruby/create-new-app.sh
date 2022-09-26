#!/bin/bash
#https://github.com/sinatra/sinatra-recipes/blob/master/deployment/nginx_proxied_to_unicorn.md
#https://gist.github.com/0x263b/683c5d09b1cbf4240884491696eb5e46

echo -n "Provide an app name > "
read APP_NAME
echo "Adding $APP_NAME ..."

echo -n "Provide a server name > "
read SERVER

ROOT_PATH=/var/www/$APP_NAME

# Create a shell folder with the right user permissions
sudo mkdir -p $ROOT_PATH
sudo mkdir -p $ROOT_PATH/var
sudo mkdir -p $ROOT_PATH/var/run
sudo mkdir -p $ROOT_PATH/var/log

# Set up puma config for this app
sudo tee $ROOT_PATH/puma.rb >/dev/null <<EOF
ENV['APP_ENV'] = 'production'

#ruby -e "require 'sysrandom/securerandom'; puts SecureRandom.hex(64)"
ENV['SESSION_SECRET'] = '<REPLACE_ME.................................................PADDING>'

threads 1, 6
# I'm too tight to pay for any more than a single-core server
# so run puma in single user mode
workers 0

root = "#{Dir.getwd}"

bind "unix://#{root}/var/run/puma.sock"

stdout_redirect "#{root}/var/log/puma.stdout.log", "#{root}/var/log/puma.stderr.log", true

pidfile "#{root}/var/run/puma.pid"
state_path "#{root}/var/run/state"

rackup "#{root}/config.ru"
EOF

# Set up rackup config for this app
sudo tee $ROOT_PATH/config.ru >/dev/null <<EOF
require "rubygems"
require "sinatra"

require File.expand_path '../myapp.rb', __FILE__

run MyApp
EOF

# Set up shell appplication file
sudo tee $ROOT_PATH/myapp.rb >/dev/null <<EOF
require "rubygems"
require "sinatra/base"

class MyApp < Sinatra::Base

  get '/' do
    'You rock! Love Ruby, Puma and Nginx'
  end

end
EOF

# Set up Gemfile
sudo tee $ROOT_PATH/Gemfile >/dev/null <<EOF
source 'https://rubygems.org'

gem 'puma'
gem 'sinatra'
EOF

# Set bundle config to only install production gems
sudo mkdir -p $ROOT_PATH/.bundle
sudo tee $ROOT_PATH/.bundle/config >/dev/null <<EOF
---
BUNDLE_WITHOUT: "development:test"
EOF

# Set the ownership of the app folder
sudo sh -c "chown -R www-data: $ROOT_PATH"

# Set up virtual host
sudo tee /etc/nginx/sites-available/$APP_NAME.conf >/dev/null <<EOF
upstream puma_$APP_NAME {
  server unix:/$ROOT_PATH/var/run/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name $SERVER;
  root $ROOT_PATH/public;

  location / {
    try_files \$uri @app;
  }

  location @app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_pass http://puma_$APP_NAME;
  }
}
EOF
sudo ln -s \
/etc/nginx/sites-available/$APP_NAME.conf \
/etc/nginx/sites-enabled/$APP_NAME.conf

# Add app to puma conf file
sudo sh -c "echo $ROOT_PATH >> /etc/puma/puma.conf"

# Create database role & blank database for the app
# Assumes runner of this script is already setup as a postgres superuser
createuser $APP_NAME
createdb $APP_NAME -O $APP_NAME
psql -d $APP_NAME -c "GRANT pg_read_all_data, pg_write_all_data TO $APP_NAME;"

echo "Now add a password for the app database:"
echo "1) Start interactive postrgres shell: '$ psql'"
echo -e "2) Type: '\\password $APP_NAME'"
echo "3) Record the password in your app settings e.g. config/database.yml"

# Restart Nginx & Puma
sudo service puma-manager restart
sudo service nginx restart

# Test to see if it worked
#curl http://$SERVER
