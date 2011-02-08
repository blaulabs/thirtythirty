require 'spec_helper'

describe Thirtythirty do

  describe ".marshal" do

    subject do
      cls = Class.new(ThirtythirtyBase) do
        marshal :attr1, "attr3"
        marshal [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (symbolized, unique, frozen)" do
      subject.marshalled_attributes.should =~ [:attr1, :attr2, :attr3]
      subject.marshalled_attributes.should be_frozen
    end

  end

  describe ".marshalled_reader" do

    subject do
      Class.new(ThirtythirtyBase) do
        marshalled_reader :attr1, "attr3"
        marshalled_reader [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (symbolized, unique, frozen)" do
      subject.marshalled_attributes.should =~ [:attr1, :attr2, :attr3]
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
        marshalled_writer :attr1, "attr3"
        marshalled_writer [:attr1, :attr2]
      end
    end

    it "should add given attributes to marshalled attributes (symbolized, unique, frozen)" do
      subject.marshalled_attributes.should =~ [:attr1, :attr2, :attr3]
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
        marshalled_accessor :attr1, "attr3"
        marshalled_accessor :attr1, :attr2
      end
    end

    it "should add given attributes to marshalled attributes (symbolized, unique, frozen)" do
      subject.marshalled_attributes.should =~ [:attr1, :attr2, :attr3]
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

  describe "#marshalled_attributes" do

    it "should give all marshalled attributes" do
      obj = ThirtythirtyTree.new
      obj.persistent = "p"
      obj.transient = "t"
      obj.marshalled_attributes.should == {:persistent => "p", :parent => nil, :children => nil}
    end

    it "should recursively give marshalled attributes of a single relation" do
      obj = ThirtythirtyTree.new
      obj.persistent = "middle"
      obj.parent = ThirtythirtyTree.new
      obj.parent.persistent = "parent"
      obj.marshalled_attributes.should == {
        :persistent => "middle",
        :parent => {:persistent => "parent", :parent => nil, :children => nil},
        :children => nil
      }
    end

    it "should recursively give marshalled attributes of a collection relation" do
      obj = ThirtythirtyTree.new
      obj.persistent = "middle"
      obj.children = [ThirtythirtyTree.new]
      obj.children.first.persistent = "child1"
      obj.marshalled_attributes.should == {
        :persistent => "middle",
        :parent => nil,
        :children => [{:persistent => "child1", :parent => nil, :children => nil}]
      }
    end

  end

  describe "marshalling (#_dump/._load)" do

    before do
      @obj = ThirtythirtyTree.new
    end

    it "should dump a string" do
      Marshal.dump(@obj).should be_a(String)
    end

    it "should restore a ThirtythirtyTree" do
      Marshal.load(Marshal.dump(@obj)).should be_a(ThirtythirtyTree)
    end

    it "should dump/restore marshalled attributes" do
      @obj.persistent = "data"
      restored = Marshal.load(Marshal.dump(@obj))
      restored.persistent.should == "data"
    end

    it "should not dump/restore unmarshalled attributes" do
      @obj.transient = "data"
      restored = Marshal.load(Marshal.dump(@obj))
      restored.transient.should be_nil
    end

    context "with a single relation" do

      before do
        @obj.parent = ThirtythirtyTree.new
      end

      it "should restore a ThirtythirtyTree" do
        Marshal.load(Marshal.dump(@obj)).parent.should be_a(ThirtythirtyTree)
      end

      it "should dump/restore marshalled attributes" do
        @obj.parent.persistent = "data"
        restored = Marshal.load(Marshal.dump(@obj))
        restored.parent.persistent.should == "data"
      end

      it "should not dump/restore unmarshalled attributes" do
        @obj.parent.transient = "data"
        restored = Marshal.load(Marshal.dump(@obj))
        restored.parent.transient.should be_nil
      end

    end

    context "with a collection relation" do

      before do
        @obj.children = [ThirtythirtyTree.new]
      end

      it "should restore an array of ThirtythirtyTrees" do
        children = Marshal.load(Marshal.dump(@obj)).children
        children.should be_a(Array)
        children.size.should == 1
        children.first.should be_a(ThirtythirtyTree)
      end

      it "should dump/restore marshalled attributes" do
        @obj.children.first.persistent = "data"
        restored = Marshal.load(Marshal.dump(@obj))
        restored.children.first.persistent.should == "data"
      end

      it "should not dump/restore unmarshalled attributes" do
        @obj.children.first.transient = "data"
        restored = Marshal.load(Marshal.dump(@obj))
        restored.children.first.transient.should be_nil
      end

    end

  end

end
