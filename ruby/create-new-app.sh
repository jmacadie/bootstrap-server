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
sudo sh -c "cp -rf $HOME/.bash/ ~$APP_NAME/.bash/"
sudo sh -c "cp -rf $HOME/.bashrc ~$APP_NAME/.bashrc"
sudo sh -c "cp -rf $HOME/.vimrc ~$APP_NAME/.vimrc"

# Create a shell folder with the right user permissions
sudo mkdir -p /var/www/$APP_NAME
sudo sh -c "chown -R $APP_NAME: /var/www/$APP_NAME"

# Set ruby version
sudo runuser -l $APP_NAME -c \
"rvm use ruby-2.2.1; \
\
cd /var/www/$APP_NAME; \
rails new $APP_NAME -B; \
\
cd $APP_NAME; \
bundle install --path vendor/bundle --without production; \
\
chmod 700 config db; \
chmod 600 config/database.yml config/secrets.yml"

# Find the location of ruby
RUBY_PATH=$(passenger-config about ruby-command | grep Nginx | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' | cut -d' ' -f2)

# Set up virtual host
ROOT_PATH=/var/www/$APP_NAME/$APP_NAME/public
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
sudo ln -s /etc/nginx/sites-available/$APP_NAME.conf /etc/nginx/sites-enabled/$APP_NAME.conf

# Restart Nginx
sudo service nginx restart

# Test to see if it worked
curl http://$SERVER
