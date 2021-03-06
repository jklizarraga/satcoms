module Satcoms

export Degrees, atand

abstract type Angle end

struct Degrees{T<:Number} <: Angle
  val::T
end

# f(x::Real) = Base.Math.atand(x)
# atand(x::Real) = Degrees(f(x))

atand(x::Real) = Degrees(Base.Math.atand(x))


end # module
