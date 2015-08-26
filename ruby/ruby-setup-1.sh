#!/bin/sh

# Prepare the system
sudo apt-get update
sudo apt-get install -y curl gnupg build-essential

# Install RVM
sudo gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | sudo bash -s stable
sudo usermod -aG rvm `whoami`

# Sort out RVMsudo
if sudo grep -q secure_path /etc/sudoers
then
  sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secire_path.sh" && echo Environment variable installed
fi

# Logout: need to log off and on for part 2
logout
