#!/bin/sh

# Install Node from the NodeSource APT repository
sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates &&
  curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_0.12 &&
  sudo bash setup-nodejs &&
  sudo apt-get install -y nodejs build-essential

# Clean up
rm setup-nodejs

# Install Phusion PGP key and add HTTPS support for APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7

# Add Phusion APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx
sudo apt-get install -y nginx-extras passenger

# Enable Passenger Nginx module
sudo sed -i "s/# passenger_root/passenger_root/g" /etc/nginx/nginx.conf
sudo sed -i "s/# passenger_ruby/passenger_ruby/g" /etc/nginx/nginx.conf

# Restart Nginx
sudo service nginx restart

# Check it went OK
echo Checking everything intsalled correctly
sudo passenger-config validate-install
sudo passenger-memory-stats
