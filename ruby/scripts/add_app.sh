#!/bin/bash

staging=''
source_app=''
while getopts 's:' flag; do
  case "${flag}" in
    s)
      staging='true'
      shift
      source_app="${OPTARG}"
      shift
      ;;
  esac
done

APP_NAME=$1
SERVER=$2
REPO=$3

ROOT_PATH=/var/www/$APP_NAME
DATE_STAMP=`date +%Y%m%d-%H%M%S`
APP_PATH=$ROOT_PATH/releases/$DATE_STAMP

# Change to this script's folder
cd "${0%/*}"

./folders.sh $ROOT_PATH $APP_PATH
./deploy.sh $ROOT_PATH $APP_NAME $staging $source_app
./puma_config.sh $ROOT_PATH $APP_PATH
./shell_app.sh $APP_PATH

# Create a symlink to point the current release at
# the app folder we've just created
sudo ln -s $APP_PATH $ROOT_PATH/current

# Set the ownership of the app folder
sudo sh -c "chown -R www-data: $ROOT_PATH"

./repo.sh $ROOT_PATH $REPO
./virtual_host.sh $ROOT_PATH $APP_NAME $SERVER
./systemd.sh $ROOT_PATH $APP_NAME
./postgres.sh $APP_NAME
