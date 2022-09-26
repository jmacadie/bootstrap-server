#!/bin/bash
#https://github.com/sinatra/sinatra-recipes/blob/master/deployment/nginx_proxied_to_unicorn.md
#https://gist.github.com/0x263b/683c5d09b1cbf4240884491696eb5e46

echo -n "Provide an app name > "
read APP_NAME
echo "Adding $APP_NAME..."

echo -n "Provide a server name > "
read SERVER

echo -n "Provide a repo to pull from > "
read REPO

ROOT_PATH=/var/www/$APP_NAME
DATE_STAMP=`date +%Y%m%d-%H%M%S`
APP_PATH=$ROOT_PATH/releases/$DATE_STAMP

# Create shell folders
sudo mkdir -p $ROOT_PATH
sudo mkdir -p $ROOT_PATH/releases
sudo mkdir -p $APP_PATH
sudo mkdir -p $ROOT_PATH/var
sudo mkdir -p $ROOT_PATH/var/run
sudo mkdir -p $ROOT_PATH/var/log

# Set up a deploy script
sudo tee $ROOT_PATH/deploy.sh >/dev/null <<EOF
#!/bin/bash

ROOT_PATH=$ROOT_PATH
DATE_STAMP=\`date +%Y%m%d-%H%M%S\`
APP_PATH=\$ROOT_PATH/releases/\$DATE_STAMP

# Pull in the latest code
cd \$ROOT_PATH/repo
git pull origin main

# Set up release folder
sudo mkdir -p \$APP_PATH

# Copy application files over
sudo cp -r src/ \$APP_PATH/src/
sudo cp -r public/ \$APP_PATH/public/
sudo cp Gemfile \$APP_PATH/Gemfile
sudo cp config.ru \$APP_PATH/config.ru
sudo cp \$ROOT_PATH/current/puma.rb \$APP_PATH/puma.rb

echo -n "Retain current server config files? (y/n) "
read RES
if [[ \$RES == "y" ]]; then
  sudo cp -r \$ROOT_PATH/current/config/ \$APP_PATH/config/
else
  sudo cp -r config/ \$APP_PATH/config/
fi

# Set ownership
sudo chown -R www-data: \$APP_PATH

# Update symlink to new path
sudo rm -f \$ROOT_PATH/current
sudo ln -s \$APP_PATH \$ROOT_PATH/current
sudo chown www-data: \$ROOT_PATH/current

# Restart puma
sudo service puma-manager restart
EOF
sudo sh -c "chmod 777 $ROOT_PATH/deploy.sh"

# Set up puma config for this app
sudo tee $APP_PATH/puma.rb >/dev/null <<EOF
ENV['APP_ENV'] = 'production'

#ruby -e "require 'sysrandom/securerandom'; puts SecureRandom.hex(64)"
ENV['SESSION_SECRET'] = '<REPLACE_ME.................................................PADDING>'

threads 1, 6
# I'm too tight to pay for any more than a single-core server
# so run puma in single user mode
workers 0

root = "$ROOT_PATH"

bind "unix://#{root}/var/run/puma.sock"

stdout_redirect "#{root}/var/log/puma.stdout.log", "#{root}/var/log/puma.stderr.log", true

pidfile "#{root}/var/run/puma.pid"
state_path "#{root}/var/run/state"

rackup "#{Dir.getwd}/config.ru"
EOF

# Set up rackup config for this app
sudo tee $APP_PATH/config.ru >/dev/null <<EOF
require File.expand_path '../myapp.rb', __FILE__
run MyApp
EOF

# Set up shell appplication file
sudo tee $APP_PATH/myapp.rb >/dev/null <<EOF
require "rubygems"
require "sinatra/base"

class MyApp < Sinatra::Base

  get '/' do
    'You rock! Love Ruby, Puma and Nginx'
  end

end
EOF

# Set up Gemfile
sudo tee $APP_PATH/Gemfile >/dev/null <<EOF
source 'https://rubygems.org'

gem 'puma'
gem 'sinatra'
EOF

# Set bundle config to only install production gems
sudo mkdir -p $APP_PATH/.bundle
sudo tee $APP_PATH/.bundle/config >/dev/null <<EOF
---
BUNDLE_WITHOUT: "development:test"
EOF

# Create a symlink to point the current release at
# the app folder we've just created
sudo ln -s $APP_PATH $ROOT_PATH/current

# Set the ownership of the app folder
sudo sh -c "chown -R www-data: $ROOT_PATH"

# Set up the repo folder
sudo sh -c "chmod 777 $ROOT_PATH"
cd $ROOT_PATH
git clone $REPO repo
sudo sh -c "chmod 755 $ROOT_PATH"

# Set up virtual host
sudo tee /etc/nginx/sites-available/$APP_NAME.conf >/dev/null <<EOF
upstream puma_$APP_NAME {
  server unix:/$ROOT_PATH/var/run/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name $SERVER;
  root $ROOT_PATH/current/public;

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
sudo sh -c "echo $ROOT_PATH/current >> /etc/puma/puma.conf"

# Restart Nginx & Puma
sudo service puma-manager restart
sudo service nginx restart

# Run certbot to make sure we're providing https
sudo certbot

# Create database role & blank database for the app
# Assumes runner of this script is already setup as a postgres superuser
createuser $APP_NAME
createdb $APP_NAME -O $APP_NAME
psql -d $APP_NAME -c "GRANT pg_read_all_data, pg_write_all_data TO $APP_NAME;"

echo "Now add a password for the app database:"
echo "1) Start interactive postrgres shell: '$ psql'"
echo -e "2) Type: '\\password $APP_NAME'"
echo "3) Record the password in your app settings e.g. config/database.yml"

# Say bye
echo "All Done!"

# Test to see if it worked
#curl http://$SERVER
