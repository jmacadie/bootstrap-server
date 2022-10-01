#! /bin/bash

echo "Adding deployment script for the app..."

ROOT_PATH=$1
APP_NAME=$2
S=$3
S_APP=$4

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
sudo cp -r \$ROOT_PATH/current/.bundle/ \$APP_PATH/.bundle

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

# Install any changed gems
cd $ROOT_PATH/current
sudo bundle install
sudo chown www-data: Gemfile.lock
EOF

if [[ $S == 'true' ]]; then
sudo tee -a $ROOT_PATH/deploy.sh >/dev/null <<EOF

# Clone main DB back to staging DB
psql -c "DROP DATABASE IF EXISTS $APP_NAME;" >/dev/null
psql -c "CREATE DATABASE $APP_NAME;" >/dev/null
pg_dump $S_APP | psql $APP_NAME >/dev/nul
EOF
fi

sudo tee -a $ROOT_PATH/deploy.sh >/dev/null <<EOF

# Restart Puma
sudo service puma-$APP_NAME restart
EOF

# Make script executable by anyone
sudo chmod 777 $ROOT_PATH/deploy.sh
