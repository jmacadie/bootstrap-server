#!/bin/bash

echo "Creating folder structure for the app..."

ROOT_PATH=$1
APP_PATH=$2

# Create shell folders
sudo mkdir -p $ROOT_PATH
sudo mkdir -p $ROOT_PATH/releases
sudo mkdir -p $APP_PATH
sudo mkdir -p $ROOT_PATH/var
sudo mkdir -p $ROOT_PATH/var/run
sudo mkdir -p $ROOT_PATH/var/log
