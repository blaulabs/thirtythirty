require 'spec_helper'

describe Thirtythirty do
  
  describe "trying to dump an object" do

    it "should only dump attributes that should be exposed" do
      password = "VERY SECRET!"
      blog_post = BlogPost.new(:secret_password => password)
      marshalled_blog_post = Marshal.dump(blog_post)
      marshalled_blog_post.should_not match(Regexp.new(password))
    end

    it "should also serialize nested objects so that these objects can also be retrieved by loading the main object" do
      blog_post = BlogPost.new(:comments => [Comment.new(:author => 'tomj'), Comment.new(:author => 'bennyb')])
      marshalled_blog_post = Marshal.dump(blog_post)
      marshalled_blog_post.should match(/bennyb/)
      marshalled_blog_post.should match(/tomj/)
    end

  end
  
  describe "trying to load an object" do
    
    it "should return a fully deserialized object" do
      blog_post = BlogPost.new(:comments => [], :title => 'blau is happy')
      marshalled_blog_post = Marshal.dump(blog_post)
      deserialized_blog_post = Marshal.load(marshalled_blog_post)
      deserialized_blog_post.should be_kind_of(BlogPost)
      deserialized_blog_post.title.should == 'blau is happy'
    end

    it "should return a fully deserialized object and nested objects" do
      nice_comment = Comment.new(:author => 'tomj', :body => 'nice article, dude!')
      blog_post = BlogPost.new(:comments => [nice_comment])
      marshalled_blog_post = Marshal.dump(blog_post)
      deserialized_blog_post = Marshal.load(marshalled_blog_post)
      retrieved_comment = deserialized_blog_post.comments.first
      retrieved_comment.should be_kind_of(Comment)
      retrieved_comment.author.should == 'tomj'
      retrieved_comment.body.should == 'nice article, dude!'
    end

  end

end