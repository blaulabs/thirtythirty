require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

require File.expand_path '../support/thirtythirty_base.rb', __FILE__
Dir[File.expand_path '../support/*.rb', __FILE__].each {|f| require f}
