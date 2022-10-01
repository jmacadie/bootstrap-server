#!/bin/bash

S=''
S_APP=''
while getopts 's:' FLAG; do
  case "${FLAG}" in
    s)
      S='true'
      shift
      S_APP="${OPTARG}"
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
./deploy.sh $ROOT_PATH $APP_NAME $S $S_APP
./puma_config.sh $ROOT_PATH $APP_PATH $S
./shell_app.sh $APP_PATH

# Create a symlink to point the current release at
# the app folder we've just created
sudo ln -s $APP_PATH $ROOT_PATH/current

# Set the ownership of the app folder
sudo chown -R www-data: $ROOT_PATH

./repo.sh $ROOT_PATH $REPO
./virtual_host.sh $ROOT_PATH $APP_NAME $SERVER
./systemd.sh $ROOT_PATH $APP_NAME
./postgres.sh $APP_NAME
