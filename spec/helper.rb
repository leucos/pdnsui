require 'ramaze'
require 'ramaze/spec/bacon'

require File.expand_path('../../app', __FILE__)

puts "Running specs using database #{DB.opts[:database]}\n"


