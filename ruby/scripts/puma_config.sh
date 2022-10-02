#!/bin/bash

echo "Adding config file for puma service for the app..."

ROOT_PATH=$1
APP_PATH=$2
S=$3

# Set up puma config for this app
if [[ $S == 'true' ]]; then
sudo tee $APP_PATH/puma.rb >/dev/null <<EOF
ENV['APP_ENV'] = 'staging'
EOF
else
sudo tee $APP_PATH/puma.rb >/dev/null <<EOF
ENV['APP_ENV'] = 'production'
EOF
fi

sudo tee -a $APP_PATH/puma.rb >/dev/null <<EOF

ENV['SESSION_SECRET'] = '<REPLACE_ME>'

threads 1, 6
# I'm too tight to pay for any more than a single-core server
# so run puma in single user mode
workers 0

root = "$ROOT_PATH"

bind "unix://#{root}/var/run/puma.sock"

stdout_redirect "#{root}/var/log/puma.stdout.log", "#{root}/var/log/puma.stderr.log", true

pidfile "#{root}/var/run/puma.pid"
state_path "#{root}/var/run/state"

rackup "#{root}/current/config.ru"
EOF

# Automatically generate a session secret
SECRET=$(ruby -e "require 'sysrandom/securerandom'; puts SecureRandom.hex(64)")
sudo sed -i "s/<REPLACE_ME>/$SECRET/g" $APP_PATH/puma.rb
