#!/bin/sh

# Create a new debian server on [Digital Ocean]

# Log in as root (if used a SSH key during creation then obviously will need to
# use that)

# Update everything
apt-get update
apt-get upgrade

# Set timezone
apt-get install ncurses-term # needed for putty term settings
dpkg-reconfigure tzdata

# Install sudo
apt-get install sudo

# Install vim and git
apt-get install vim git

# Sort out access
# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-debian-8
# ==============================================================================

# Create user
adduser X
# Will be prompted to porvide password and important details like room number

# Add user to sudoers
usermod -aG sudo X

# Add SSH keys for user
# -------------------------------------

# Switch to user
su - X

# Create SHH directory
mkdir .ssh
chmod 700 .ssh

# Create keys file
vim .ssh/authorized_keys
# paste in public key - will start with "ssh-rsa AAAA..."
chmod 600 .ssh/authorized_keys

# Back to root
exit

# Remove all access bar SSH from non-root
# -------------------------------------

vim /etc/ssh/sshd_config
# Change following lines:
#
#   PermitRootLogin yes
#   -> PermitRootLogin no
#
#   #PasswordAuthentication yes
#   -> PasswordAuthentication no
#
#   UsePAM yes
#   -> UsePAM no

# Restart SSH
systemctl restart ssh

# Log-off current session
logout

# Log back in as new user
# Can now only log in as new user with SSH keys

# Sort out git
# ==============================================================================

mkdir ~/code
cd ~/code

# Clone this repo
# Have to use https as not set up SSH yet
git clone https://github.com/jmacadie/bootstrap-server.git
