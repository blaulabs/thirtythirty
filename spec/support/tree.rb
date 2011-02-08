class ThirtythirtyTree < ThirtythirtyBase
  marshalled_accessor :persistent, :parent, :children
  attr_accessor :transient
end
