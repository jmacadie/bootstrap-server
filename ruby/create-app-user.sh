#!bin/bash

echo -n "Provide a username > "
read uname
echo "Hello, $uname"

sudo adduser $uname

# Ensure inbound and outbound SSH keys are installed as per current user
sudo sh -c "mkdir -p ~$uname/.ssh"
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~$uname/.ssh/authorized_keys"
sudo sh -c "cat $HOME/.ssh/id_rsa >> ~$uname/.ssh/id_rsa"
sudo sh -c "chown -R $uname: ~$uname/.ssh"
sudo sh -c "chmod 700 ~$uname/.ssh"
sudo sh -c "chmod 600 ~$uname/.ssh/*"
