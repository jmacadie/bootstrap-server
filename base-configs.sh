#!/bin/bash

set -e

echo "Moving base config files"

cp -r .bash/ ~/.bash/

rm -f ~/.bashrc
cp .bashrc ~/.bashrc

rm -f ~/.vimrc
cp .vimrc ~/.vimrc
