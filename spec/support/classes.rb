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
