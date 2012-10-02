# This file contains your application, it requires dependencies and necessary parts of 
# the application.
#
# It will be required from either `config.ru` or `start.rb`
require 'rubygems'
require 'ramaze'

require "bundler/setup"

# Make sure that Ramaze knows where you are
Ramaze.options.roots = [__DIR__]

# Require environnemet settings
require __DIR__('config/environment')
require __DIR__('config/database')
require __DIR__('config/dns')

# Initialize controllers and models
require __DIR__('helper/init')
require __DIR__('model/init')
require __DIR__('controller/init')
require __DIR__('api/init')
