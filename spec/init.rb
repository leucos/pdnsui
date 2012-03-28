require 'simplecov'

# Load the existing files
Dir.glob('spec/**/*.rb').each do |spec_file|
  unless File.basename(spec_file) == 'init.rb' and File.basename(spec_file) == 'helper.rb'
    require File.expand_path(spec_file)
  end
end
