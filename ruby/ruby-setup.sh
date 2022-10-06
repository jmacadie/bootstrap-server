#!/bin/bash

sudo apt-get install ruby-full gcc build-essential

sudo gem install bundler
sudo gem install puma
sudo gem install sinatra
sudo gem install sd_notify # for the systemd system
sudo gem install sysrandom # for all the random strings we'll generate


