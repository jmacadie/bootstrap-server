#!/bin/bash
#https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-22-04-quickstart

sudo apt-get install postgresql postgresql-contrib libpq-dev

# Create role for current user (replace X), need a DB with the same name
sudo -u postgres createuser -s $USER
sudo -u postgres createdb $USER
