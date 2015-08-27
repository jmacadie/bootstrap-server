#!/bin/bash

set -e

echo "Moving base config files"

cp -rf .bash/ ~/.bash/
cp -f .bashrc ~/.bashrc
cp -f .vimrc ~/.vimrc

sudo cp -rf .bash/ ~root/.bash/
sudo cp -f .bashrc ~root/.bashrc
sudo cp -f .vimrc ~root/.vimrc
