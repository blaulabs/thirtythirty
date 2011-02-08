require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

Dir[File.expand_path '../support/*.rb', __FILE__].each {|f| require f}
