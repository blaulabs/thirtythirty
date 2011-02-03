require "json"

module Thirtythirty

  def marshal(*attributes)
    extend ClassMethods
    send :include, InstanceMethods
    @marshalled_attributes = attributes
  end

  module ClassMethods

    attr_reader :marshalled_attributes

  protected

    def _load(dumped)
      data = JSON.parse(dumped)
      obj = new
      marshalled_attributes.each do |attr|
        obj.send(:"#{attr}=", Marshal.load(data[attr.to_s]))
      end
      obj
    end

  end

  module InstanceMethods

    def _dump(*args)
      self.class.marshalled_attributes.inject({}) do |hash, attr|
        hash[attr] = Marshal.dump(self.send(attr.to_sym))
        hash
      end.to_json
    end

  end

end
