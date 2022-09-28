#!/bin/bash
#https://github.com/sinatra/sinatra-recipes/blob/master/deployment/nginx_proxied_to_unicorn.md
#https://gist.github.com/0x263b/683c5d09b1cbf4240884491696eb5e46

echo -n "Provide an app name          > "
read APP_NAME
#echo "Adding $APP_NAME..."

echo -n "Provide a server name        > "
read SERVER

echo -n "Provide a repo to pull from  > "
read REPO

scripts/add_app.sh $APP_NAME $SERVER $REPO

echo -n "Create a staging app? (y/n)  > "
read STG

if [[ $STG == "y" ]]; then
  echo -n "  Provide a staging app name (${APP_NAME}_stg) > "
  read STG_NAME
  if [[ -z $STG_NAME ]]; then
  STG_NAME="${APP_NAME}_stg"
  fi

  echo -n "  Provide a server name (staging.${SERVER}) > "
  read STG_SERVER
  if [[ -z $STG_SERVER ]]; then
    STG_SERVER="staging.${SERVER}"
  fi

  scripts/add_app.sh -s $APP_NAME $STG_NAME $STG_SERVER $REPO
fi

# Run certbot to make sure we're providing https
sudo certbot

# Say bye
echo "All Done!"

# Test to see if it worked
#curl http://$SERVER
