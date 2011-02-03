require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

Dir[File.expand_path '../support/*.rb', __FILE__].each {|f| require f}


class Base
  extend Thirtythirty
end

class BlogPost < Base
  marshal :title, :description, :comments

  attr_accessor :title, :description, :comments, :secret_password
  def initialize(attributes={})
    self.title = attributes[:title] || 'My first blog post'
    self.description = attributes[:description] || "This is a very short description of the things i've done yesterday"
    self.comments = attributes[:comments] || [Comment.new, Comment.new(:author => 'bennyb', :comment => 'Ponies and Unicorns!')]
    self.secret_password = attributes[:secret_password] || "SECRET!"
  end
end

class Comment < Base
  marshal :author, :body, :date
  attr_accessor :author, :body, :date
  def initialize(attributes={})
    self.author = attributes[:author] || 'tomj'
    self.body = attributes[:body] || "Very nice article!"
    self.date = attributes[:date] || Time.now
  end
end
