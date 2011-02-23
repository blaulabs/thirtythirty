class Compressed < ThirtythirtyBase
  marshal_with_compression
  marshalled_accessor :persistent
end
