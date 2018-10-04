# baremodule AngleTest
#
# using Base
# export Degrees, atand
#
# abstract type Angle end
#
# struct Degrees{T<:Number} <: Angle
#   val::T
# end
#
# atand(x::Real) = Degrees(Base.Math.atand(x))
#
# end

module AngleTest

import Base
export Degrees, atand

abstract type Angle end

struct Degrees{T<:Number} <: Angle
  val::T
end

atand(x::Real) = Degrees(Base.Math.atand(x))

end
