require 'spec_helper'

describe Thirtythirty do

  describe ".marshal" do

    subject do
      cls = Class.new(ThirtythirtyBase) do
        marshal :attr1, :attr3
        marshal [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (stringified, unique, sorted, frozen)" do
      subject.marshalled_attributes.should == %w(attr1 attr2 attr3)
      subject.marshalled_attributes.should be_frozen
    end

  end

  describe ".marshalled_reader" do

    subject do
      Class.new(ThirtythirtyBase) do
        marshalled_reader :attr1, :attr3
        marshalled_reader [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (stringified, unique, sorted, frozen)" do
      subject.marshalled_attributes.should == %w(attr1 attr2 attr3)
      subject.marshalled_attributes.should be_frozen
    end

    %w(attr1 attr2 attr3).each do |attr|

      it "should generate a reader for attribute #{attr} (but no writer)" do
        obj = subject.new
        obj.should respond_to(attr.to_sym)
        obj.should_not respond_to(:"#{attr}=")
      end

    end

  end

  describe ".marshalled_writer" do

    subject do
      Class.new(ThirtythirtyBase) do
        marshalled_writer :attr1, :attr3
        marshalled_writer [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (stringified, unique, sorted, frozen)" do
      subject.marshalled_attributes.should == %w(attr1 attr2 attr3)
      subject.marshalled_attributes.should be_frozen
    end

    %w(attr1 attr2 attr3).each do |attr|

      it "should generate a writer for attribute #{attr} (but no reader)" do
        obj = subject.new
        obj.should_not respond_to(attr.to_sym)
        obj.should respond_to(:"#{attr}=")
      end

    end

  end

  describe ".marshalled_accessor" do

    subject do
      Class.new(ThirtythirtyBase) do
        marshalled_accessor :attr1, :attr3
        marshalled_accessor :attr1, :attr2
      end
    end

    it "should add given attributes to marshalled attributes (stringified, unique, sorted, frozen)" do
      subject.marshalled_attributes.should == %w(attr1 attr2 attr3)
      subject.marshalled_attributes.should be_frozen
    end

    %w(attr1 attr2 attr3).each do |attr|

      it "should generate a reader and a writer for attribute #{attr}" do
        obj = subject.new
        obj.should respond_to(attr.to_sym)
        obj.should respond_to(:"#{attr}=")
      end

    end

  end

  describe "marshalling" do

    describe "#_dump" do

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

    describe "._load" do

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

end
