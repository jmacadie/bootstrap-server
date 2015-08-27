# Set up virtual host
APP_NAME=test_app
SERVER=ruby.julianrimet.com
ROOT_PATH=/var/www/$APP_NAME/public
RUBY_PATH=/path/to/ruby
sudo tee /etc/nginx/sites-available/$APP_NAME.conf >/dev/null <<EOF
server {
  listen 80;
  server_name $SERVER;

  # Tell Nginx and Passenger where your app's 'public' directory is
  root $ROOT_PATH;

  # Turn on Passenger
  passenger_enabled on;
  passenger_ruby $RUBY_PATH;
  ruby_env development;
}
EOF
