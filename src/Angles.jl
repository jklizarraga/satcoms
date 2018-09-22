isdefined(Base, :__precompile__) && __precompile__()

module Angles

  import Base: ==, +, -, *, /, .+, .-, .*, ./, //, ^
  import Base: promote_rule, promote_type, convert, show, mod

  immutable Degrees{T::Number} <: Number
    val::T
  end

  immutable Radians{T::Number} <: Number
    val::T
  end

  
end
