#!/bin/bash

sudo apt-get install nginx

# install certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo service nginx start
sudo systemctl status nginx.service
