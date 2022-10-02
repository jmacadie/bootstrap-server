#!/bin/bash

printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
echo "Creating systemd service for puma app instance..."
echo "......."

ROOT_PATH=$1
APP_NAME=$2

# Set up systemd job to run puma server for this app
sudo tee /etc/systemd/system/puma-$APP_NAME.service >/dev/null <<EOF
[Unit]
Description=Puma HTTP Server
After=network.target

# Uncomment for socket activation (see below)
# Requires=puma.socket

[Service]
# Puma supports systemd's \`Type=notify\` and watchdog service
# monitoring, if the [sd_notify](https://github.com/agis/ruby-sdnotify) gem is installed,
# as of Puma 5.1 or later.
# On earlier versions of Puma or JRuby, change this to \`Type=simple\` and remove
# the \`WatchdogSec\` line.
Type=notify

# If your Puma process locks up, systemd's watchdog will restart it within seconds.
WatchdogSec=10

# Preferably configure a non-privileged user
User=www-data

# The path to your application code root directory.
WorkingDirectory=$ROOT_PATH/current

# Helpful for debugging socket activation, etc.
# Environment=PUMA_DEBUG=1

# SystemD will not run puma even if it is in your path. You must specify
# an absolute URL to puma. For example /usr/local/bin/puma
# Alternatively, create a binstub with \`bundle binstubs puma --path ./sbin\` in the WorkingDirectory
ExecStart=/usr/local/bin/puma --environment deployment --config $ROOT_PATH/current/puma.rb

# Variant: Rails start.
# ExecStart=/<FULLPATH>/bin/puma -C <YOUR_APP_PATH>/config/puma.rb ../config.ru

# Variant: Use \`bundle exec --keep-file-descriptors puma\` instead of binstub
# Variant: Specify directives inline.
# ExecStart=/<FULLPATH>/puma -b tcp://0.0.0.0:9292 -b ssl://0.0.0.0:9293?key=key.pem&cert=cert.pem

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload >/dev/null
sudo systemctl enable puma-$APP_NAME.service &>/dev/null

# Restart Nginx & Puma
sudo service puma-$APP_NAME start >/dev/null
sudo service nginx restart >/dev/null

# Check service status
# sudo systemctl status puma-x.service
# sudo journalctl -xeu puma-x.service
