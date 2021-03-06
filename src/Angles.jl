# Usage in REPL:
# include("./src/Angles.jl")
# using Main.Angles
# for op in Main.Angles.operationsInverse
#   @eval $op(x::Real) = Main.Angles.$op(x)
# end

isdefined(Base, :__precompile__) && __precompile__()

baremodule Angles

using Base

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

const operationsUnary_angle          = (:+, :-, :mod2pi, :abs, :abs2, :√, :∛, :floor, :ceil, :trunc, :zero) # rem2pi has to be treated separately
const operationsUnary_scalar         = (:inv, :sign, :signbit, :isinteger, :isinf, :isfinite, :isnan, :one)
const operationsBetweenAngles_angle  = (:+, :-)
const operationsBetweenAngles_scalar = (:/, :\)
const operationsAngleScalar          = (:*, :/, :÷, :^, :%, :mod, :fld, :cld) # :rem already covered by :%
const operationsScalarAngle          = (:*, :\)
const operationsComparison           = (Symbol("=="), :≠, :<, :≤, :>, :≥, :isless)
const operationsTrigonometric        = ( :sin,  :cos,  :tan,  :csc,  :sec,  :cot)
const operationsTrigoInvRad          = (:asin, :acos, :atan, :acsc, :asec, :acot)
const operationsTrigoInvDeg          = Symbol.(operationsTrigoInvRad,"d")
const operationsTrigoInverse         = (operationsTrigoInvRad..., operationsTrigoInvDeg...)
const operationsInverse              = (operationsTrigoInverse..., :anlge)
const operationsTrigoOther           = (:sinpi, :cospi, :sinc, :cosc, :sincos)
const operationsOther                = (:rem2pi, :round, :isapprox)

const operations = unique((operationsUnary_angle...,
                           operationsUnary_scalar...,
                           operationsBetweenAngles_angle...,
                           operationsBetweenAngles_scalar...,
                           operationsAngleScalar...,
                           operationsScalarAngle...,
                           operationsComparison...,
                           operationsTrigonometric...,
                           operationsTrigoOther...,
                           operationsOther...))

for op in operations
  @eval import Base: $op
  @eval export $op
end

for op in operationsInverse
  @eval export $op
end

export operationsInverse

import Base: deg2rad, rad2deg
import Base: convert, promote_rule, show
import Base: iterate, IteratorSize, IteratorEltype, eltype, length, size, step

abstract type Angle{T<:Real} <: Number end
abstract type AngleRange{T<:Real} end

const asciiRepresentation = Dict("Degrees"=>"º"   , "Radians"=>"rad")
const  htmlRepresentation = Dict("Degrees"=>"&deg", "Radians"=>"rad")

for angularUnits in (:Degrees, :Radians)
  angularRange = Symbol(angularUnits,"Range")

  @eval begin
        # Singleton angular units
        export $angularUnits

        struct $angularUnits{T} <: Angle{T where T<:Real}
          val::T
        end

        $angularUnits(a::Nothing) = nothing

        convert(::Type{T}               , x::$angularUnits{T}) where {T<:Real}         = x.val
        convert(::Type{$angularUnits{T}}, x::$angularUnits{S}) where {T<:Real,S<:Real} = $angularUnits(T(x.val))
        convert(::Type{$angularUnits{T}}, x::S               ) where {T<:Real,S<:Real} = $angularUnits(T(x    ))

        promote_rule(::Type{$angularUnits{T}},::Type{$angularUnits{S}}) where {T<:Real,S<:Real} = $angularUnits{promote_type(T,S)}

        # Pretty printing
        Base.show(io::IO,                     x::$angularUnits{T}) where {T} = print(io, x.val, asciiRepresentation[$(String(angularUnits))])
        Base.show(io::IO, ::MIME"text/plain", x::$angularUnits{T}) where {T} = print(io, "Angle in ",$(String(angularUnits)),"{$T}: ", x, "\n")
        Base.show(io::IO, ::MIME"text/html" , x::$angularUnits{T}) where {T} = print(io, x.val, htmlRepresentation[$(String(angularUnits))] ," [<code>",$(String(angularUnits)),"{$T}</code>]")

        # Support to arrays

        $angularUnits(a::T) where {T<:AbstractArray{S,D} where {S<:Real,D}} = ($angularUnits).(a)

        # Ranges
        export $angularRange

        struct $angularRange{T} <: AngleRange{T where T<:Real}
          r::S where {S<:AbstractRange{T}}
        end

        # Possible improvement
        # struct $angularRange{T} <: AngleRange{T where T<:Real}
        #   r::AbstractRange{T}
        # end

        # $angularUnits(r::S) where {S <: AbstractRange{T} where T <: Real} = ($angularUnits).(r)
        $angularUnits(r::AbstractRange{<:Real}) = $angularRange{eltype(r)}(r)

        function iterate(rangeOfAngle::$angularRange{T}) where {T<:Real}
           result = iterate(rangeOfAngle.r)
           result ≠ nothing ? (return ($angularUnits(result[1]), result[2])) : (return nothing)
        end

        function iterate(rangeOfAngle::$angularRange{T}, state) where {T<:Real}
          result = iterate(rangeOfAngle.r, state)
          result ≠ nothing ? (return ($angularUnits(result[1]), result[2])) : (return nothing)
        end

        step(rangeOfAngle::$angularRange{T}) where {T<:Real} = $angularUnits(step(rangeOfAngle.r))
        getindex(rangeOfAngle::$angularRange{T}, inds...) where {T<:Real} = $angularUnits(getindex(rangeOfAngle.r, inds...))

        Base.eltype(        ::Type{$angularRange{T}}) where {T<:Real} = $angularUnits{T}
        Base.IteratorSize(  ::Type{$angularRange{T}}) where {T<:Real} = Base.IteratorSize(AbstractRange{Real})
        Base.IteratorEltype(::Type{$angularRange{T}}) where {T<:Real} = Base.HasEltype()
        Base.length( rangeOfAngle::$angularRange{T} ) where {T<:Real} = length(rangeOfAngle.r)
        Base.size(   rangeOfAngle::$angularRange{T} ) where {T<:Real} = size(rangeOfAngle.r)

        end

  # New methods for the operations.

  ## Arithmetic operators
  ### Unary operators
  for op in operationsUnary_angle
    @eval $op(x::$angularUnits{T}) where {T<:Real} = $angularUnits($op(x.val))
  end

  ### Operations with scalars
  for op in operationsAngleScalar
    @eval $op(x::$angularUnits, scalar::Real) = $angularUnits($op(x.val, scalar))
  end

  for op in operationsScalarAngle
    @eval $op(scalar::Real, x::$angularUnits) = $angularUnits($op(scalar,x.val))
  end

  @eval zero(::Type{$angularUnits{T}}) where {T<:Real} = $angularUnits(T(0))
  @eval round( x::$angularUnits, r::RoundingMode) = $angularUnits(round( x.val,r))
  @eval isapprox(x::$angularUnits, y::$angularUnits; kvarag...) = isapprox(x.val, y.val; kvarag...)

  @eval begin
        *(m::M            ,  ::Type{$angularUnits}) where {M<:AbstractArray{S,D} where {S<:Real,D}} = ($angularUnits).(m)
        *(r::R            ,  ::Type{$angularUnits}) where {R<:AbstractRange{<:Real}} = $angularUnits(r)
        *(r::R            , x::$angularUnits      ) where {R<:AbstractRange{<:Real}} = $angularUnits(r * x.val)
        *(x::$angularUnits, r::R                  ) where {R<:AbstractRange{<:Real}} = $angularUnits(x.val * r)
        end
end

# Conversion between the different angles.
deg2rad(x::Degrees) = Radians(deg2rad(x.val))
rad2deg(x::Radians) = Degrees(rad2deg(x.val))
convert(::Type{Radians{T}}, x::Degrees) where {T<:Real} = deg2rad(x)
convert(::Type{Degrees{T}}, x::Radians) where {T<:Real} = rad2deg(x)

promote_rule(::Type{Degrees{T}},::Type{Radians{S}}) where {T<:Real,S<:Real} = Radians{promote_type(T,S)}

# New methods for the operations
rem2pi(x::Degrees, r::RoundingMode) = Degrees(rem2pi(deg2rad(x.val),r))
rem2pi(x::Radians, r::RoundingMode) = Radians(rem2pi(x.val,r))

## Arithmetic operators
### Unary operators
for op in operationsUnary_scalar
  @eval $op(x::T) where {T<:Angle} = $op(x.val)
end
one(::Type{Angle{T}}) where {T<:Real} = T(1)
isapprox(x::Angle, y::Angle; kvarag...) = isapprox(promote(x,y)...; kvarag...)

### Operations between angles producing an angle
for op in operationsBetweenAngles_angle
  @eval $op(x::T, y::T) where {T<:Angle         } = T($op(x.val, y.val))
  @eval $op(x::T, y::S) where {T<:Angle,S<:Angle} = $op(promote(x,y)...)
end

### Operations between angles producing a scalar
for op in operationsBetweenAngles_scalar
  @eval $op(x::T, y::T) where {T<:Angle         } = $op(x.val, y.val)
  @eval $op(x::T, y::S) where {T<:Angle,S<:Angle} = $op(promote(x,y)...)
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

angle( x::Complex) = Radians(Base.Math.angle(x))
angled(x::Complex) = Degrees(Base.Math.angle(x))

for fun in operationsTrigoOther
  @eval $fun(x::Radians) = $fun(x.val)
end

sincos(x::Degrees) = (sin(x),cos(x))

# Syntactic sugar
const degrees = deg = º = ° = Degrees
const radians = rad         = Radians
export degrees, deg, º, °, radians, rad

*(x::Real, y::Type{T}) where {T<:Angle} = T(x)

end
