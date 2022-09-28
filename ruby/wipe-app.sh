#!/bin/bash

echo "Select an app to remove (q to quit)"
echo "---------------------------------------------------"
i=0
DIRS=("")
for f in /var/www/*; do
  if [[ -d $f && ! -L $f ]]; then
    d=${f##*/}
    if [[ $d != "html" ]]; then
      i=$((i + 1))
      DIRS=("${DIRS[@]}" $d)
      echo "$i) $d"
    fi
  fi
done
echo "---------------------------------------------------"
echo -n "> "
read SEL

if [[ $SEL == "q" ]]; then
  echo "Nothing removed"
  echo "Bye!"
  exit 0
fi

APP_NAME=${DIRS[${SEL}]}

echo "Removing $APP_NAME ..."

# Kill & remove the puma service
sudo service puma-$APP_NAME stop
sudo service puma-$APP_NAME disable
sudo rm -f /etc/systemd/system/multi-user.target.wants/puma-$APP_NAME.service
sudo rm -f /etc/systemd/system/default.target.wants/puma-$APP_NAME.service
sudo rm -f /etc/systemd/system/puma-$APP_NAME.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Delete the virtual host file
sudo rm -f /etc/nginx/sites-enabled/$APP_NAME.conf
sudo rm -f /etc/nginx/sites-available/$APP_NAME.conf
sudo service nginx restart

# Delete the application folder
sudo rm -rf /var/www/$APP_NAME

# Ask about deleting database
echo -n "Delete associated database? (y/n) "
read RES

if [[ $RES == "y" ]]; then
  psql -c "DROP DATABASE IF EXISTS $APP_NAME;" &>/dev/null
  psql -c "DROP USER IF EXISTS $APP_NAME;" &>/dev/null
fi
