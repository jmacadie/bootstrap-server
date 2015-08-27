#!bin/bash

echo -n "Provide an app name > "
read APP_NAME
echo "Adding $APP_NAME ..."

echo -n "Provide a server name > "
read SERVER

sudo adduser $APP_NAME

# Ensure inbound and outbound SSH keys are installed as per current user
sudo sh -c "mkdir -p ~$APP_NAME/.ssh"
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~$APP_NAME/.ssh/authorized_keys"
sudo sh -c "cat $HOME/.ssh/id_rsa >> ~$APP_NAME/.ssh/id_rsa"
sudo sh -c "chown -R $APP_NAME: ~$APP_NAME/.ssh"
sudo sh -c "chmod 700 ~$APP_NAME/.ssh"
sudo sh -c "chmod 600 ~$APP_NAME/.ssh/*"

# Move config files (so experience is the same)
sudo sh -c "cp -rf ../.bash/ ~$APP_NAME/.bash/"
sudo sh -c "cp -rf ../.bashrc ~$APP_NAME/.bashrc"
sudo sh -c "cp -rf ../.vimrc ~$APP_NAME/.vimrc"

# Create the app
rails new /var/www/$APP_NAME -B
chown -R $APP_NAME: /var/www/$APP_NAME

# Log in as the new user
sudo -u $APP_NAME -H bash -l

# Set ruby version
rvm use ruby-2.2.1

# Run Bundle install
cd /var/www/$APP_NAME
bundle install --path vendor/bundle

# Tighten security on sensitive bits
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml

# Find the location of ruby
RUBY_PATH=$(passenger-config about ruby-command | grep Nginx | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' | cut -d' ' -f2)

# Exit from new user
exit

# Set up virtual host
SERVER=ruby.julianrimet.com
ROOT_PATH=/var/www/$APP_NAME/public
sudo tee /etc/nginx/sites-available/test.conf >/dev/null <<EOF
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

# Restart Nginx
sudo service nginx restart

# Test to see if it worked
curl http://$SERVER
