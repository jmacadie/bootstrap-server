echo -n "Provide an app name > "
read APP_NAME
echo "Removing $APP_NAME ..."

sudo userdel $APP_NAME
sudo rm -f /etc/ngingx/sites-enabled/$APP_NAME.conf
sudo rm -f /etc/ngingx/sites-available/$APP_NAME.conf
sudo rm -rf /var/www/$APP_NAME
