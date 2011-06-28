module Thirtythirty

  # Activates marshalling for the given attributes - you have to implement getters/setters yourself!
  def marshal(*attributes)
    unless defined?(@marshalled_attributes)
      extend ClassMethods
      send :include, InstanceMethods
      @marshalled_attributes = []
    end
    attributes_to_add = attributes.flatten.map(&:to_sym).uniq
    added_attributes = attributes_to_add - @marshalled_attributes
    @marshalled_attributes = (@marshalled_attributes | attributes_to_add)
    added_attributes
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

  def marshal_with_compression(level = Zlib::BEST_COMPRESSION)
    marshal
    @marshalling_compression_level = level
  end

private

  module ClassMethods

    def marshalled_attributes
      ((superclass.respond_to?(:marshalled_attributes) ? superclass.marshalled_attributes : []) + (@marshalled_attributes || [])).uniq.freeze
    end

    def marshalling_compression_level
      @marshalling_compression_level || (superclass.respond_to?(:marshalling_compression_level) ? superclass.marshalling_compression_level : nil)
    end

  protected

    def _load(dumped)
      uncompressed = Zlib::Inflate.inflate(dumped) rescue dumped
      data = Marshal.load(uncompressed)
      obj = new
      marshalled_attributes.each do |attr|
        obj.send(:"#{attr}=", Marshal.load(data[attr]))
      end
      obj
    end

  end

  module InstanceMethods

    def _dump(*args)
      dumped = Marshal.dump(build_marshalled_attributes_hash {|v| Marshal.dump(v)})
      dumped = Zlib::Deflate.deflate(dumped, self.class.marshalling_compression_level) if self.class.marshalling_compression_level
      dumped
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
