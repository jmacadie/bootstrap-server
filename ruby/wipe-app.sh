echo -n "Provide an app name > "
read APP_NAME
echo "Removing $APP_NAME ..."

sudo sh -c "rm -f /etc/nginx/sites-enabled/$APP_NAME.conf"
sudo sh -c "rm -f /etc/nginx/sites-available/$APP_NAME.conf"
sudo sh -c "rm -rf /var/www/$APP_NAME"
sudo sh -c "sed -i '/$APP_NAME/d' /etc/puma/puma.conf"
