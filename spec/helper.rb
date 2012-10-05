require 'ramaze'
require 'ramaze/spec/bacon'
require 'nokogiri'

require File.expand_path('../../app', __FILE__)

def noko_text(path)
  Nokogiri::HTML(last_response.body).css(path).text
end

puts "Running specs using database #{DB.opts[:database]}\n"


