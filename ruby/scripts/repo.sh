#!/bin/bash

ROOT_PATH=$1
REPO=$2

# Set up the repo folder
sudo sh -c "chmod 777 $ROOT_PATH"
cd $ROOT_PATH
git clone $REPO repo
sudo sh -c "chmod 755 $ROOT_PATH"
