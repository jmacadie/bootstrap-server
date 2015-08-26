# Part 2 - run part 1 first!

# Install latest version of ruby
rvm install ruby
rvm --default use ruby

# Install specific version of ruby
#rvm install ruby-2.2.2
#rvm --default use ruby-2.2.2

# Install bundler
gem install bundler --no-rdoc --no-ri

# Install Node.js
sudo apt-get install -y nodejs && sudo ln -sf /usr/bin/nodejs /usr/local/bin/node

# Install Phusion PGP key and add HTTPS support for APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

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

# Install rails (specific version)
gem install rails -v 4.2.2
