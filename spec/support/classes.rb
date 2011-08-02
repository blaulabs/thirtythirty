class ThirtythirtyBase
  extend Thirtythirty
end

class ThirtythirtyTree < ThirtythirtyBase
  marshalled_accessor :persistent, :parent, :children
  attr_accessor :transient
end

class Uncompressed < ThirtythirtyBase
  marshalled_accessor :persistent
end

class Compressed < ThirtythirtyBase
  marshal_with_compression
  marshalled_accessor :persistent
end

class WithoutGetterSetter < ThirtythirtyBase
  marshal :ivar
end

class WithGetterOnly < ThirtythirtyBase
  marshal :ivar
  def ivar
    @ivar.nil? ? nil : @ivar.upcase
  end
end

class WithSetterOnly < ThirtythirtyBase
  marshal :ivar
  def ivar=(value)
    @ivar = value.nil? ? nil : value.upcase
  end
end
