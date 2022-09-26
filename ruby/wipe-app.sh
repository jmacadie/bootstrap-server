echo -n "Provide an app name > "
read APP_NAME
echo "Removing $APP_NAME ..."

sudo sh -c "rm -f /etc/nginx/sites-enabled/$APP_NAME.conf"
sudo sh -c "rm -f /etc/nginx/sites-available/$APP_NAME.conf"
sudo sh -c "rm -rf /var/www/$APP_NAME"
sudo sh -c "sed -i '/$APP_NAME/d' /etc/puma/puma.conf"

echo -n "Delete associated database? (y/n)"
read RES

if [[ $RES == "y" ]]; then
  psql -c "DROP DATABASE IF EXISTS $APP_NAME;"
  psql -c "DROP USER IF EXISTS $APP_NAME;"
fi

