#!/bin/bash

APP_PATH=$1

# Set up rackup config for this app
sudo tee $APP_PATH/config.ru >/dev/null <<EOF
require File.expand_path '../myapp.rb', __FILE__
run MyApp
EOF

# Set up shell appplication file
sudo tee $APP_PATH/myapp.rb >/dev/null <<EOF
require "rubygems"
require "sinatra/base"

class MyApp < Sinatra::Base

  get '/' do
    'You rock! Love Ruby, Puma and Nginx'
  end

end
EOF

# Set up Gemfile
sudo tee $APP_PATH/Gemfile >/dev/null <<EOF
source 'https://rubygems.org'

gem 'puma'
gem 'sinatra'
EOF

# Set bundle config to only install production gems
sudo mkdir -p $APP_PATH/.bundle
sudo tee $APP_PATH/.bundle/config >/dev/null <<EOF
---
BUNDLE_WITHOUT: "development:test"
EOF
