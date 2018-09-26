isdefined(Base, :__precompile__) && __precompile__()

module Angles

operationsUnary         = (:+, :-, :rem2pi, :mod2pi)
operationsBetweenAngles = (:+, :-)
operationsAngleScalar   = (:*, :/, :÷, :^, :%, :rem, :mod)
operationsScalarAngle   = (:*, :\)
operationsComparison    = (Symbol("=="), :≠, :<, :≤, :>, :≥)
operationsTrigonometric = (:sin, :cos, :tan, :cot, :sec, :csc, :sinc, :cosc, :sinpi, :cospi)

operations = unique((operationsUnary..., operationsBetweenAngles..., operationsAngleScalar..., operationsScalarAngle..., operationsComparison..., operationsTrigonometric...))

for op in operations
  @eval import Base: $op
  @eval export $op
end

import Base: convert, promote_rule, show

abstract type Angle end

asciiRepresentation = Dict("Degrees"=>"º"   , "Radians"=>"rad")
 htmlRepresentation = Dict("Degrees"=>"&deg", "Radians"=>"rad")

for angularUnits in (:Degrees, :Radians)
  @eval begin
          export $angularUnits

          struct $angularUnits{T<:Number} <: Angle
            val::T
          end

          convert(::Type{T}               , x::$angularUnits{T}) where {T<:Number}           = x.val
          convert(::Type{$angularUnits{T}}, x::$angularUnits{S}) where {T<:Number,S<:Number} = $angularUnits(T(x.val))

          promote_rule(::Type{$angularUnits{T}},::Type{$angularUnits{S}}) where {T<:Number,S<:Number} = $angularUnits{promote_type(T,S)}

          # Pretty printing
          Base.show(io::IO,                     x::$angularUnits{T}) where {T} = print(io, x.val, asciiRepresentation[$(String(angularUnits))])
          Base.show(io::IO, ::MIME"text/plain", x::$angularUnits{T}) where {T} = print(io, "Angle in ",$(String(angularUnits)),"{$T}: ", x, "\n")
          Base.show(io::IO, ::MIME"text/html" , x::$angularUnits{T}) where {T} = print(io, x.val, htmlRepresentation[$(String(angularUnits))] ," [<code>",$(String(angularUnits)),"{$T}</code>]")
        end
end

# Conversion between the different angles.
convert(::Type{Radians{T}}, x::Degrees) where {T<:Number} = Radians(x.val * (π / 180.))
convert(::Type{Degrees{T}}, x::Radians) where {T<:Number} = Degrees(x.val * (π \ 180.))

promote_rule(::Type{Degrees{T}},::Type{Radians{S}}) where {T<:Number,S<:Number} = Radians{promote_type(T,S)}

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
  @eval $op(x::T, scalar::Number) where {T<:Angle} = T($op(x.val, scalar))
end

for op in operationsScalarAngle
  @eval $op(scalar::Number, x::T) where {T<:Angle} = T($op(scalar,x.val))
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

end
