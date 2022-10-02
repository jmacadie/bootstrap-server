#!/bin/bash

echo "Creating database for the app..."

APP_NAME=$1

# Automatically generate a random password for the login
PWORD=$(ruby -e "require 'sysrandom/securerandom'; puts SecureRandom.hex(20)")

# Create database role & blank database for the app
# Assumes runner of this script is already setup as a postgres superuser
createuser $APP_NAME >/dev/null
createdb $APP_NAME -O $APP_NAME >/dev/null
psql -d $APP_NAME -c "ALTER USER $APP_NAME WITH PASSWORD '$PWORD';" >/dev/null
psql -d $APP_NAME -c "GRANT pg_read_all_data, pg_write_all_data TO $APP_NAME;" >/dev/null

echo "*****************************************************"
echo "Record the postgres login in your app settings e.g. config/database.yml"
echo "User:     $APP_NAME"
echo "Password: $PWORD"
echo -e "*****************************************************\n"
