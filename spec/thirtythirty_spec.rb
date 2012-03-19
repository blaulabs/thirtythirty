# -*- encoding : utf-8 -*-
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

  describe "combined marshalling" do

    subject do
      Class.new(ThirtythirtyBase) do
        attr_reader :untouched
        def untouched=(untouched)
          @untouched = untouched.upcase
        end
        marshal :untouched
        marshalled_accessor :touched
      end
    end

    it "should add given attributes to marshalled attributes (symbolized, unique, frozen)" do
      subject.marshalled_attributes.should =~ [:touched, :untouched]
      subject.marshalled_attributes.should be_frozen
    end

    it "should generate a reader and a writer for attribute touched" do
      obj = subject.new
      obj.should respond_to(:touched)
      obj.should respond_to(:touched)
    end

    it "should not regenerate reader and writer for attribute untouched" do
      obj = subject.new
      obj.untouched = "down"
      obj.untouched.should == "DOWN"
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

  describe ".marshal_with_compression/#marshalling_compression_level" do

    subject { Class.new(ThirtythirtyBase) }

    it "should default to nil" do
      subject.marshal # needs to be done to activate custom marshalling at all
      subject.marshalling_compression_level.should be_nil
    end

    it "should be settable" do
      subject.marshal_with_compression Zlib::BEST_SPEED
      subject.marshalling_compression_level.should == Zlib::BEST_SPEED
    end

    it "should default to Zlib::BEST_COMPRESSION" do
      subject.marshal_with_compression
      subject.marshalling_compression_level.should == Zlib::BEST_COMPRESSION
    end

  end

  describe "marshalling (#_dump/._load)" do

    subject { ThirtythirtyTree.new }

    it "should dump a string" do
      Marshal.dump(subject).should be_a(String)
    end

    it "should restore a ThirtythirtyTree" do
      Marshal.load(Marshal.dump(subject)).should be_a(ThirtythirtyTree)
    end

    it "should dump/restore marshalled attributes" do
      subject.persistent = "data"
      restored = Marshal.load(Marshal.dump(subject))
      restored.persistent.should == "data"
    end

    it "should not dump/restore unmarshalled attributes" do
      subject.transient = "data"
      restored = Marshal.load(Marshal.dump(subject))
      restored.transient.should be_nil
    end

    context "with marshalled instance variable without getter/setter" do

      subject { WithoutGetterSetter.new }

      it "should dump/restore instance variable when nil" do
        restored = Marshal.load(Marshal.dump(subject))
        restored.instance_variable_get(:"@ivar").should be_nil
      end

      it "should dump/restore instance variable when set" do
        subject.instance_variable_set(:"@ivar", "value")
        restored = Marshal.load(Marshal.dump(subject))
        restored.instance_variable_get(:"@ivar").should == "value"
      end

    end

    context "with marshalled instance variable without setter" do

      subject { WithGetterOnly.new }

      it "should dump accessor value/restore instance variable" do
        subject.instance_variable_set(:"@ivar", "value")
        subject.ivar.should == "VALUE"
        restored = Marshal.load(Marshal.dump(subject))
        restored.instance_variable_get(:"@ivar").should == "VALUE"
        restored.ivar.should == "VALUE"
      end

    end

    context "with marshalled instance variable without getter" do

      subject { WithSetterOnly.new }

      it "should dump instance variable/restore accessor value" do
        subject.instance_variable_set(:"@ivar", "value")
        restored = Marshal.load(Marshal.dump(subject))
        restored.instance_variable_get(:"@ivar").should == "VALUE"
      end

    end

    context "with a single relation" do

      before do
        subject.parent = ThirtythirtyTree.new
      end

      it "should restore a ThirtythirtyTree" do
        Marshal.load(Marshal.dump(subject)).parent.should be_a(ThirtythirtyTree)
      end

      it "should dump/restore marshalled attributes" do
        subject.parent.persistent = "data"
        restored = Marshal.load(Marshal.dump(subject))
        restored.parent.persistent.should == "data"
      end

      it "should not dump/restore unmarshalled attributes" do
        subject.parent.transient = "data"
        restored = Marshal.load(Marshal.dump(subject))
        restored.parent.transient.should be_nil
      end

    end

    context "with a collection relation" do

      before do
        subject.children = [ThirtythirtyTree.new]
      end

      it "should restore an array of ThirtythirtyTrees" do
        children = Marshal.load(Marshal.dump(subject)).children
        children.should be_a(Array)
        children.size.should == 1
        children.first.should be_a(ThirtythirtyTree)
      end

      it "should dump/restore marshalled attributes" do
        subject.children.first.persistent = "data"
        restored = Marshal.load(Marshal.dump(subject))
        restored.children.first.persistent.should == "data"
      end

      it "should not dump/restore unmarshalled attributes" do
        subject.children.first.transient = "data"
        restored = Marshal.load(Marshal.dump(subject))
        restored.children.first.transient.should be_nil
      end

    end

    context "with compression" do

      it "compressed version should be smaller than the uncompressed version and generally work" do
        obj = Uncompressed.new
        obj.persistent = "loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo text"
        uncompressed = Marshal.dump(obj)
        obj = Compressed.new
        obj.persistent = "loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo text"
        compressed = Marshal.dump(obj)
        compressed.size.should < uncompressed.size

        restored = Marshal.load(compressed)
        restored.should be_a(Compressed)
        restored.persistent.should == "loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo text"
      end

      it "bla" do
        b = ThirtythirtyTree2.new
        b.persistent = 1

        dumped = Marshal.dump(b)
        ThirtythirtyTree2.marshalled_accessor :attr4
        lambda { Marshal.load dumped }.should_not raise_error(TypeError)
      end

    end

  end

  describe "inheritance" do

    it "should have the same marshalled attributes as the parent" do
      Class.new(ThirtythirtyTree).marshalled_attributes.should == ThirtythirtyTree.marshalled_attributes
    end

    it "should be able to add it's own marshalled attributes" do
      Class.new(ThirtythirtyTree) do
        marshalled_accessor :another_persistent
      end.marshalled_attributes.should == ThirtythirtyTree.marshalled_attributes + [:another_persistent]
    end

    it "should have the same compression level as the parent" do
      Class.new(Compressed).marshalling_compression_level.should == Compressed.marshalling_compression_level
    end

    it "should be able to set it's own compression level" do
      Class.new(Uncompressed) do
        marshal_with_compression Zlib::BEST_COMPRESSION
      end.marshalling_compression_level.should == Zlib::BEST_COMPRESSION
    end

  end

end
