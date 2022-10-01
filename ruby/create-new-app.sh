#!/bin/bash
#https://github.com/sinatra/sinatra-recipes/blob/master/deployment/nginx_proxied_to_unicorn.md
#https://gist.github.com/0x263b/683c5d09b1cbf4240884491696eb5e46

# Test if packages are installed first
dpkg --get-selections | grep "^ruby.*install$" >/dev/null
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "Need to install ruby..."
  ./ruby-setup.sh
fi
dpkg --get-selections | grep "^nginx.*install$" >/dev/null
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "Need to install Nginx..."
  ./nginx-setup.sh
fi
dpkg --get-selections | grep "^postgres.*install$" >/dev/null
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "Need to install PostgreSQL..."
  ./postgres-setup.sh
fi

read -p "Provide an app name          > " APP_NAME
read -p "Provide a server name        > " SERVER
read -p "Provide a repo to pull from  > " REPO

scripts/add_app.sh $APP_NAME $SERVER $REPO

read -p "Create a staging app? (y/n)  > " STG

if [[ $STG == "y" ]]; then
  read -p "  Provide a staging app name (${APP_NAME}_stg) > " STG_NAME
  if [[ -z $STG_NAME ]]; then
  STG_NAME="${APP_NAME}_stg"
  fi

  read -p "  Provide a server name (staging.${SERVER}) > " STG_SERVER
  if [[ -z $STG_SERVER ]]; then
    STG_SERVER="staging.${SERVER}"
  fi

  scripts/add_app.sh -s $APP_NAME $STG_NAME $STG_SERVER $REPO
fi

# Run certbot to make sure we're providing https
sudo certbot --nginx

# Say bye
echo "All Done!"

# Test to see if it worked
#curl http://$SERVER
