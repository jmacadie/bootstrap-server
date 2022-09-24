#!/bin/bash

sudo apt-get install nginx

sudo service nginx start
systemctl status nginx.service
