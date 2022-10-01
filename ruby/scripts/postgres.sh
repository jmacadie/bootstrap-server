#!/bin/bash

echo "Creating database for the app..."

APP_NAME=$1

# Create database role & blank database for the app
# Assumes runner of this script is already setup as a postgres superuser
createuser $APP_NAME >/dev/null
createdb $APP_NAME -O $APP_NAME >/dev/null
psql -d $APP_NAME -c "GRANT pg_read_all_data, pg_write_all_data TO $APP_NAME;" >/dev/null

echo "*****************************************************"
echo "Now add a password for the app database:"
echo "1) Start interactive postrgres shell: '$ psql'"
echo -e "2) Type: '\\password $APP_NAME'"
echo "3) Record the password in your app settings e.g. config/database.yml"
echo -e "*****************************************************\n"