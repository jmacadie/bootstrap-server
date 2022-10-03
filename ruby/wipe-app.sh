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
read -p "> " SEL

if [[ $SEL == "q" || $SEL == "" ]]; then
  echo "Nothing removed"
  echo "Bye!"
  exit 0
fi

APP_NAME=${DIRS[${SEL}]}

echo "Removing $APP_NAME ..."

# Kill & remove the puma service
sudo service puma-$APP_NAME stop &>/dev/null
sudo service puma-$APP_NAME disable &>/dev/null
sudo rm -f /etc/systemd/system/multi-user.target.wants/puma-$APP_NAME.service
sudo rm -f /etc/systemd/system/default.target.wants/puma-$APP_NAME.service
sudo rm -f /etc/systemd/system/puma-$APP_NAME.service
sudo systemctl daemon-reload &>/dev/null
sudo systemctl reset-failed &>/dev/null

# Delete the virtual host file
sudo rm -f /etc/nginx/sites-enabled/$APP_NAME.conf
sudo rm -f /etc/nginx/sites-available/$APP_NAME.conf
sudo service nginx restart &>/dev/null

# Delete the application folder
sudo rm -rf /var/www/$APP_NAME

# Ask about deleting database
read -p "Delete associated database? (y/n) " RES
if [[ $RES == "y" ]]; then
  psql -c "DROP DATABASE IF EXISTS $APP_NAME;" &>/dev/null
  psql -c "DROP USER IF EXISTS $APP_NAME;" &>/dev/null

  # Delete this apps access from the postgres settings
  sudo find /etc/postgresql -type f -name "pg_hba.conf" \
            -exec /bin/bash \
              -c 'sed -i "/\s$1\s/d" $2' bash $APP_NAME {} \;

  sudo service postgresql restart
fi
