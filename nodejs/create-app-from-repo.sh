#!bin/bash

echo -n "Provide an app name > "
read APP_NAME
echo "Adding $APP_NAME ..."

echo -n "Provide a repository to clone > "
read REPO

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
sudo sh -c "cp -rf $HOME/.gitconfig ~$APP_NAME/.gitconfig"
sudo sh -c "chown -R $APP_NAME: ~$APP_NAME"

# Create a shell folder for the project
sudo mkdir -p /var/www/$APP_NAME
sudo sh -c "chown -R $USER: /var/www/$APP_NAME"
cd /var/www/$APP_NAME

# Clone the repo
git clone $REPO site

# Change the folder permissions
sudo sh -c "chown -R $APP_NAME: /var/www/$APP_NAME"

# Get paths for virtual host file
ROOT_PATH=/var/www/$APP_NAME/site/public
APP_PATH=$(cat package.json \
| grep "main" \
| cut -d':' -f2 \
| sed -e 's/^[[:space:]]*"\(.*\)",[[:space:]]*$/\1/')

# Set up virtual host
sudo tee /etc/nginx/sites-available/$APP_NAME.conf >/dev/null <<EOF
server {
  listen 80;
  server_name $SERVER;

  # Tell Nginx and Passenger where your app's 'public' directory is
  root $ROOT_PATH;

  # Turn on Passenger
  passenger_enabled on;
  passenger_app_type node;
  passenger_startup_file $APP_PATH;
}
EOF
sudo ln -s \
/etc/nginx/sites-available/$APP_NAME.conf \
/etc/nginx/sites-enabled/$APP_NAME.conf

# Restart Nginx
sudo service nginx restart

# Test to see if it worked
#curl http://$SERVER
