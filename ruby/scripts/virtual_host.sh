#!/bin/bash

echo "Creating virtual host for the app..."

ROOT_PATH=$1
APP_NAME=$2
SERVER=$3

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
