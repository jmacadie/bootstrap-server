#!bin/bash

echo -n "Provide an app name > "
read APP_NAME
echo "Adding $APP_NAME ..."

echo -n "Provide a server name > "
read SERVER

sudo adduser $APP_NAME

# Ensure inbound and outbound SSH keys are installed as per current user
sudo sh -c "mkdir -p ~$APP_NAME/.ssh"
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~$APP_NAME/.ssh/authorized_keys"
sudo sh -c "cat $HOME/.ssh/id_rsa >> ~$APP_NAME/.ssh/id_rsa"
sudo sh -c "chown -R $APP_NAME: ~$APP_NAME/.ssh"
sudo sh -c "chmod 700 ~$APP_NAME/.ssh"
sudo sh -c "chmod 600 ~$APP_NAME/.ssh/*"

# Move config files (so experience is the same)
sudo sh -c "cp -rf $HOME/.bash/ ~$APP_NAME/.bash/"
sudo sh -c "cp -rf $HOME/.bashrc ~$APP_NAME/.bashrc"
sudo sh -c "cp -rf $HOME/.vimrc ~$APP_NAME/.vimrc"

# Create a shell folder for the project
sudo mkdir -p /var/www/$APP_NAME
sudo sh -c "chown -R $USER: /var/www/$APP_NAME"
cd /var/www/$APP_NAME
mkdir site
cd site

# Create some folders & files we'll need
mkdir views
mkdir views/layouts
mkdir views/partials
mkdir public
mkdir public/css
mkdir public/img
mkdir public/js
mkdir public/qa
mkdir public/vendor
mkdir lib
touch credentials.js
touch $APP_NAME.js

# Create a .gitignore
cat <<EOF > .gitignore
# Ignore packages installed by npm
node_modules*

# Don't store credentials in repo
credentials.js

# Don't commit log files
log

# Don't store ssl certs in repo
ssl
EOF

# Initialse the project and install express & handlebars
npm init
npm install --save express
npm install --save express-handlebars

# Write a very basic app.js main file
cat <<EOF >> $APP_NAME.js
var express = require('express');
var app = express();

// Set up handlebars view engine
var handlebars = require('express-handlebars')
                    .create({ defaultLayout:'main' });
app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');

app.set('port', process.env.PORT || 3000);

// Routes
app.get('/', function (req, res){
  res.render('home');
});

// Custom 404 page
app.use(function(req, res){
  res.status(404);
  res.render('404');
});

// Custom 500 page
app.use(function(req, res){
  res.status(500);
  res.render('500');
});

app.listen(app.get('port'), function(){
  console.log('Express Started on http://localhost:' + app.get('port') +
              '; Press Ctrl + c to terminate.');
});
EOF

# Write a basic layout file
cat <<EOF > views/layouts/main.handlebars
<!doctype html>
<head>
  <title>$APP_NAME</title>
</head>
<body>
  {{{body}}}
</body>
</html>
EOF

# Write some basic views
echo "Hello, World!" > views/home.handlebars
echo "404 - Not Found" > views/404.handlebars
echo "500 - Server Error" > views/500.handlebars

# Change the folder permissions
sudo sh -c "chown -R $APP_NAME: /var/www/$APP_NAME"

# Set up virtual host
ROOT_PATH=/var/www/$APP_NAME/site/public
sudo tee /etc/nginx/sites-available/$APP_NAME.conf >/dev/null <<EOF
server {
  listen 80;
  server_name $SERVER;

  # Tell Nginx and Passenger where your app's 'public' directory is
  root $ROOT_PATH;

  # Turn on Passenger
  passenger_enabled on;
  passenger_app_type node;
  passenger_startup_file $APP_NAME.js;
}
EOF
sudo ln -s \
/etc/nginx/sites-available/$APP_NAME.conf \
/etc/nginx/sites-enabled/$APP_NAME.conf

# Restart Nginx
sudo service nginx restart

# Test to see if it worked
#curl http://$SERVER
