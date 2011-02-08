require "json"
require "base64"

module Thirtythirty

  # Activates marshalling for the given attributes - you have to implement getters/setters yourself!
  def marshal(*attributes)
    configure_marshalling(attributes)
  end

  # Activates marshalling for the given attributes and generates getters - you have to implement setters yourself!
  def marshalled_reader(*attributes)
    attr_reader *configure_marshalling(attributes)
  end

  # Activates marshalling for the given attributes and generates setters - you have to implement getters yourself!
  def marshalled_writer(*attributes)
    attr_writer *configure_marshalling(attributes)
  end

  # Activates marshalling for the given attributes and generates getters/setters.
  def marshalled_accessor(*attributes)
    attr_accessor *configure_marshalling(attributes)
  end

private

  def configure_marshalling(attributes)
    unless defined?(@marshalled_attributes)
      extend ClassMethods
      send :include, InstanceMethods
      @marshalled_attributes = []
    end
    attributes = attributes.flatten.map(&:to_s).uniq
    @marshalled_attributes = (@marshalled_attributes | attributes).sort.freeze
    attributes.map(&:to_sym)
  end

  module ClassMethods

    attr_reader :marshalled_attributes

  protected

    def _load(dumped)
      data = JSON.parse(dumped)
      obj = new
      marshalled_attributes.each do |attr|
        obj.send(:"#{attr}=", Marshal.load(Base64.decode64(data[attr])))
      end
      obj
    end

  end

  module InstanceMethods

    def _dump(*args)
      build_marshalled_attributes_hash {|v| Base64.encode64(Marshal.dump(v))}.to_json
    end

    def marshalled_attributes
      build_marshalled_attributes_hash {|v| retrieve_marshalled_attributes_of(v)}
    end

  private

    def build_marshalled_attributes_hash(&block)
      self.class.marshalled_attributes.inject({}) do |hash, attr|
        value = self.send(attr.to_sym)
        hash[attr.to_sym] = block.call(value)
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
