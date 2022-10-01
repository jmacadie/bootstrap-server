#!/bin/bash

echo "Linking source code for the app..."

ROOT_PATH=$1
REPO=$2

# Set up the repo folder
sudo chmod 777 $ROOT_PATH
cd $ROOT_PATH
git clone $REPO repo &>/dev/null
sudo chmod 755 $ROOT_PATH
