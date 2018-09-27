# Usage:
# include("./src/Angles.jl")
# using Main.Angles
# for op in Main.Angles.operationsTrigoInverse
#   @eval $op(x::Real) = Main.Angles.$op(x)
# end

isdefined(Base, :__precompile__) && __precompile__()

baremodule Angles

using Base

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

const operationsUnary         = (:+, :-, :rem2pi, :mod2pi)
const operationsBetweenAngles = (:+, :-)
const operationsAngleScalar   = (:*, :/, :÷, :^, :%, :rem, :mod)
const operationsScalarAngle   = (:*, :\)
const operationsComparison    = (Symbol("=="), :≠, :<, :≤, :>, :≥)
const operationsTrigonometric = ( :sin,  :cos,  :tan,  :csc,  :sec,  :cot)
const operationsTrigoInvRad   = (:asin, :acos, :atan, :acsc, :asec, :acot)
const operationsTrigoInvDeg   = Symbol.(operationsTrigoInvRad,"d")
const operationsTrigoInverse  = (operationsTrigoInvRad..., operationsTrigoInvDeg...)
const operationsTrigoOther    = (:sinpi, :cospi, :sinc, :cosc, :sincos)

const operations = unique((operationsUnary..., operationsBetweenAngles..., operationsAngleScalar..., operationsScalarAngle..., operationsComparison..., operationsTrigonometric..., operationsTrigoOther...))

for op in operations
  @eval import Base: $op
  @eval export $op
end

for op in operationsTrigoInverse
  @eval export $op
end

export operationsTrigoInverse

import Base: deg2rad, rad2deg
import Base: convert, promote_rule, show

abstract type Angle end

asciiRepresentation = Dict("Degrees"=>"º"   , "Radians"=>"rad")
 htmlRepresentation = Dict("Degrees"=>"&deg", "Radians"=>"rad")

for angularUnits in (:Degrees, :Radians)
  @eval begin
          export $angularUnits

          struct $angularUnits{T<:Real} <: Angle
            val::T
          end

          convert(::Type{T}               , x::$angularUnits{T}) where {T<:Real}           = x.val
          convert(::Type{$angularUnits{T}}, x::$angularUnits{S}) where {T<:Real,S<:Real} = $angularUnits(T(x.val))

          promote_rule(::Type{$angularUnits{T}},::Type{$angularUnits{S}}) where {T<:Real,S<:Real} = $angularUnits{promote_type(T,S)}

          # Pretty printing
          Base.show(io::IO,                     x::$angularUnits{T}) where {T} = print(io, x.val, asciiRepresentation[$(String(angularUnits))])
          Base.show(io::IO, ::MIME"text/plain", x::$angularUnits{T}) where {T} = print(io, "Angle in ",$(String(angularUnits)),"{$T}: ", x, "\n")
          Base.show(io::IO, ::MIME"text/html" , x::$angularUnits{T}) where {T} = print(io, x.val, htmlRepresentation[$(String(angularUnits))] ," [<code>",$(String(angularUnits)),"{$T}</code>]")
        end
end

# Conversion between the different angles.
deg2rad(x::Degrees) = Radians(deg2rad(x.val))
rad2deg(x::Radians) = Degrees(rad2deg(x.val))
convert(::Type{Radians{T}}, x::Degrees) where {T<:Real} = deg2rad(x)
convert(::Type{Degrees{T}}, x::Radians) where {T<:Real} = rad2deg(x)

promote_rule(::Type{Degrees{T}},::Type{Radians{S}}) where {T<:Real,S<:Real} = Radians{promote_type(T,S)}

# New methods for the operations.

## Arithmetic operators
### Unary operators
+(x::T) where {T<:Angle} = x
-(x::T) where {T<:Angle} = T(-x.val)

rem2pi(x::T, r::RoundingMode) where {T<:Angle} = T(rem2pi(x.val,r))
mod2pi(x::T                 ) where {T<:Angle} = T(mod2pi(x.val  ))

### Operations between angles
for op in operationsBetweenAngles
  @eval $op(x::T, y::T) where {T<:Angle         } = T($op(x.val, y.val))
  @eval $op(x::T, y::S) where {T<:Angle,S<:Angle} = $op(promote(x,y)...)
end

### Operations with scalars
for op in operationsAngleScalar
  @eval $op(x::T, scalar::Real) where {T<:Angle} = T($op(x.val, scalar))
end

for op in operationsScalarAngle
  @eval $op(scalar::Real, x::T) where {T<:Angle} = T($op(scalar,x.val))
end

## Comparison (between angles) operations
for op in operationsComparison
  @eval $op(x::T    , y::T    ) where {T<:Angle} = $op(x.val,y.val)
  @eval $op(x::Angle, y::Angle)                  = $op(promote(x,y)...)
end

## Trigonometric functions
for fun in operationsTrigonometric
  @eval $fun(x::Radians) = $fun(x.val)
  @eval $fun(x::Degrees) = $(Symbol(fun,'d'))(x.val)
end

for fun in operationsTrigoInvRad
  @eval $fun(x::Real) = Radians(Base.Math.$fun(x))
end

for fun in operationsTrigoInvDeg
  @eval $fun(x::Real) = Degrees(Base.Math.$fun(x))
end

atan( y::Real, x::Real) = Radians(Base.Math.atan( x,y))
atand(y::Real, x::Real) = Degrees(Base.Math.atand(x,y))

for fun in operationsTrigoOther
  @eval $fun(x::Radians) = $fun(x.val)
end

sincos(x::Degrees) = (sin(x),cos(x))

# Syntactic sugar
const degrees = deg = º = Degrees
const radians = rad = Radians
export degrees, deg, º, radians, rad

*(x::Real, y::Type{T}) where {T<:Angle} = T(x)

end
