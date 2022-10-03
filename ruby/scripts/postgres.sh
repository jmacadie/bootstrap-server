#!/bin/bash

printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
echo "Creating database for the app..."
echo "........"

APP_NAME=$1

# Automatically generate a random password for the login
PWORD=$(ruby -e "require 'sysrandom/securerandom'; puts SecureRandom.hex(20)")

# Create database role & blank database for the app
# Assumes runner of this script is already setup as a postgres superuser
createuser $APP_NAME >/dev/null
createdb $APP_NAME -O $APP_NAME >/dev/null
psql -c "ALTER USER $APP_NAME WITH PASSWORD '$PWORD';" >/dev/null
psql -d $APP_NAME -c "GRANT pg_read_all_data, pg_write_all_data TO $APP_NAME;" >/dev/null

# Add password access for this user, to this database
sudo find /etc/postgresql -type f -name "pg_hba.conf" \
          -exec /bin/bash \
          -c 'sed -ri "s/(TYPE  DATABASE        USER            ADDRESS                 METHOD)/\1\nlocal   $1         $1                         scram-sha-256/g" $2' bash $APP_NAME {} \;

sudo service postgresql restart

printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
printf "\033[1A" # Move cursor one line up
printf "\033[K"  # Delete to end of line
echo "*****************************************************"
echo "Record the postgres login in your app settings e.g. config/database.yml"
echo "User:     $APP_NAME"
echo "Password: $PWORD"
echo -e "*****************************************************\n"
