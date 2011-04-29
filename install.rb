# This is the post install hook for when Sfalma is installed as a plugin.
require 'fileutils'
  
# puts IO.read(File.join(File.dirname(__FILE__), 'README'))

config_file = File.expand_path("#{File.dirname(__FILE__)}/../../../config/sfalma.yml")
example_config_file = "#{File.dirname(__FILE__)}/sfalma.yml"

if File::exists? config_file
  puts "Sfalma config file already exists. Please ensure it is up-to-date with the current format."
  puts "See #{example_config_file}"
else  
  puts "Installing default Sfalma config."
  puts "  From #{example_config_file}"
  puts "For sfalma to work you need to configure your API key."
  puts "  See #{example_config_file}"
  puts "If you don't have an API key, get one at http://www.sfalma.com/."
  FileUtils.copy example_config_file, config_file
end
