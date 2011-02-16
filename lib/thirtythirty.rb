module Thirtythirty

  # Activates marshalling for the given attributes - you have to implement getters/setters yourself!
  def marshal(*attributes)
    unless defined?(@marshalled_attributes)
      extend ClassMethods
      send :include, InstanceMethods
      @marshalled_attributes = []
    end
    @marshalled_attributes = (@marshalled_attributes.map | attributes.flatten.map(&:to_sym).uniq).freeze
  end

  # Activates marshalling for the given attributes and generates getters - you have to implement setters yourself!
  def marshalled_reader(*attributes)
    attr_reader *marshal(attributes)
  end

  # Activates marshalling for the given attributes and generates setters - you have to implement getters yourself!
  def marshalled_writer(*attributes)
    attr_writer *marshal(attributes)
  end

  # Activates marshalling for the given attributes and generates getters/setters.
  def marshalled_accessor(*attributes)
    attr_accessor *marshal(attributes)
  end

private

  module ClassMethods

    attr_reader :marshalled_attributes

  protected

    def _load(dumped)
      data = Marshal.load(dumped)
      obj = new
      marshalled_attributes.each do |attr|
        obj.send(:"#{attr}=", Marshal.load(data[attr]))
      end
      obj
    end

  end

  module InstanceMethods

    def _dump(*args)
      Marshal.dump(build_marshalled_attributes_hash {|v| Marshal.dump(v)})
    end

    def marshalled_attributes
      build_marshalled_attributes_hash {|v| retrieve_marshalled_attributes_of(v)}
    end

  private

    def build_marshalled_attributes_hash(&block)
      self.class.marshalled_attributes.inject({}) do |hash, attr|
        value = self.send(attr)
        hash[attr] = block.call(value)
        hash
      end
    end

    def retrieve_marshalled_attributes_of(obj)
      if obj.is_a?(Array)
        obj.map {|v| retrieve_marshalled_attributes_of(v)}
      elsif obj.respond_to?(:marshalled_attributes)
        obj.marshalled_attributes
      else
        obj
      end
    end

  end

end
