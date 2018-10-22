# isdefined(Base, :__precompile__) && __precompile__()


# module SIQuantitiesPkg

# using ..SIBaseUnitsPkg: SIBaseUnit, SIBaseUnits, scalar

const operationsUnary_siQuantity              = (:+, :-, :abs, :abs2, :√, :∛, :floor, :ceil, :trunc, :zero) # inv() is an exception because the units have also to be inverted.
const operationsUnary_info                    = (:sign, :signbit, :isinteger, :isinf, :isfinite, :isnan) # one() is an exception because returns a scalar in the sense of Physics
const operationsBetweenSiQuantities_sameUnits = (:+, :-)
const operationsBetweenSiQuantities_anyUnits  = (:*, :/, :\)
const operationsSiQuantityScalar              = (:*, :/, :÷, :%, :mod, :fld, :cld) # :rem already covered by :%
const operationsScalarSiQuantity              = (:*, :\)
const operationsComparison                    = (Symbol("=="), :≠, :<, :≤, :>, :≥, :isless)
const operationsOther                         = (:inv, :one, :^, :round, :isapprox)

const operations = unique((operationsUnary_siQuantity...,
                           operationsUnary_info...,
                           operationsBetweenSiQuantities_sameUnits...,
                           operationsBetweenSiQuantities_anyUnits...,
                           operationsSiQuantityScalar...,
                           operationsScalarSiQuantity...,
                           operationsComparison...,
                           operationsOther...))

for op in operations
    @eval import Base: $op
    @eval export $op
end

export SIQuantity, SIScalar

struct SIQuantity{T<:Real,U<:SIBaseUnit} <: Number
    val::T
    SIQuantity(x::T,::Type{U}) where {T<:Real,U<:SIBaseUnit} = new{T,U}(x)
end
SIQuantity(x::Real,u::SIBaseUnit) = SIQuantity(x, typeof(u))

  SIScalar(x::Real) = SIQuantity(x,scalar)
SIQuantity(x::Real) = SIScalar(x)

SIBaseUnit{m,kg,s,A,K,mol,cd}(x::Real) where {m,kg,s,A,K,mol,cd} = SIQuantity(x,SIBaseUnit{m,kg,s,A,K,mol,cd})

*(x::Real,  ::Type{U}) where {U<:SIBaseUnit} = SIQuantity(x,U)
*(x::Real, u::U      ) where {U<:SIBaseUnit} = SIQuantity(x,U)

for op in operationsUnary_siQuantity
    @eval $op(x::SIQuantity{T,U}) where {T<:Real,U<:SIBaseUnit} = SIQuantity($op(x.val),U)
end

  inv(x::SIQuantity{T,U}                 ) where {T<:Real,U<:SIBaseUnit} = SIQuantity(inv(x.val),inv(U))
round(x::SIQuantity{T,U}, r::RoundingMode) where {T<:Real,U<:SIBaseUnit} = SIQuantity(round(x.val,r), U)

for op in operationsUnary_info
    @eval $op(x::SIQuantity{T,U}) where {T<:Real,U<:SIBaseUnit} = $op(x.val)
end

one(x::SIQuantity{T,U}) where {T<:Real,U<:SIBaseUnit} = SIQuantity(one(x.val),scalar)

for op in operationsBetweenSiQuantities_sameUnits
    @eval $op(x::SIQuantity{T,U}, y::SIQuantity{S,U}) where {T<:Real,U<:SIBaseUnit,S<:Real} = SIQuantity($op(x.val,y.val),U)
end

for op in operationsBetweenSiQuantities_anyUnits
    @eval $op(x::SIQuantity{T,U}, y::SIQuantity{S,V}) where {T<:Real,U<:SIBaseUnit,S<:Real,V<:SIBaseUnit} = SIQuantity($op(x.val,y.val),$op(U,V))
end

for op in operationsSiQuantityScalar
    @eval $op(x::SIQuantity{T,U}, y::Real) where {T<:Real,U<:SIBaseUnit} = SIQuantity($op(x.val,y),U)
end
\(x::SIQuantity{T,U}, y::Real) where {T<:Real,U<:SIBaseUnit} = SIQuantity(x.val\y,inv(U))
^(x::SIQuantity{T,U}, y::Union{Integer,Rational}) where {T<:Real,U<:SIBaseUnit} = SIQuantity(x.val^y,U^y)

for op in operationsScalarSiQuantity
    @eval $op(y::Real, x::SIQuantity{T,U}) where {T<:Real,U<:SIBaseUnit} = SIQuantity($op(x.val,y),U)
end
/(y::Real, x::SIQuantity{T,U}) where {T<:Real,U<:SIBaseUnit} = SIQuantity(y/x.val,inv(U))

for op in operationsComparison
    @eval $op(x::SIQuantity{T,U}, y::SIQuantity{S,U}) where {T<:Real,U<:SIBaseUnit,S<:Real} = $op(x.val,y.val)
end

isapprox(x::SIQuantity{T,U}, y::SIQuantity{S,U}; kvarag...) where {T<:Real,U<:SIBaseUnit,S<:Real} = isapprox(x.val, y.val; kvarag...)

import Base: show
function show(io::IO,x::SIQuantity{T,U}) where {T,U}
    show(io,x.val)
    print(io," ")
    show(io,U)
end

function show(io::IO, ::MIME"text/plain", x::SIQuantity{T,U}) where {T,U}
    print("{"); show(T); print("} ")
    show(io,x.val)
    print(io," ")
    show(io,U)
end

# Support to arrays

SIQuantity(a::T,::Type{U}) where {T<:AbstractArray{S,D} where {S<:Real,D},U<:SIBaseUnit} = SIQuantity.(a,U)
SIBaseUnit{m,kg,s,A,K,mol,cd}(a::T) where {m,kg,s,A,K,mol,cd, T<:AbstractArray{S,D} where {S<:Real,D}} = SIQuantity.(a,SIBaseUnit(m,kg,s,A,K,mol,cd))
*(a::T,  ::Type{U} ) where {T<:AbstractArray{S,D} where {S<:Real,D},U<:SIBaseUnit} = SIQuantity.(a,U)
*(a::T, u::U       ) where {T<:AbstractArray{S,D} where {S<:Real,D},U<:SIBaseUnit} = SIQuantity.(a,U)

import Base: iterate, IteratorSize, IteratorEltype, eltype, length, size, step, getindex
export SIQuantityRange

struct SIQuantityRange{T<:Real, U<:SIBaseUnit}
    r::AbstractRange{T}
    SIQuantityRange(r::AbstractRange{T},::Type{U}) where {T<:Real,U<:SIBaseUnit} = new{T,U}(r)
end
SIQuantityRange(r::AbstractRange{T},u::U) where {T<:Real,U<:SIBaseUnit} = SIQuantityRange(r,U)

SIBaseUnit{m,kg,s,A,K,mol,cd}(r::AbstractRange{<:Real}) where {m,kg,s,A,K,mol,cd} = SIQuantityRange(r,SIBaseUnit(m,kg,s,A,K,mol,cd))

function iterate(rangeOfSIQuantities::SIQuantityRange{T,U}) where {T<:Real,U<:SIBaseUnit}
    result = iterate(rangeOfSIQuantities.r)
    result ≠ nothing ? (return (U(result[1]), result[2])) : (return nothing)
end

function iterate(rangeOfSIQuantities::SIQuantityRange{T,U}, state) where {T<:Real,U<:SIBaseUnit}
    result = iterate(rangeOfSIQuantities.r, state)
    result ≠ nothing ? (return (U(result[1]), result[2])) : (return nothing)
end

step(rangeOfSIQuantities::SIQuantityRange{T,U}) where {T<:Real,U<:SIBaseUnit} = U(step(rangeOfSIQuantities.r))
getindex(rangeOfSIQuantities::SIQuantityRange{T,U}, inds...) where {T<:Real,U<:SIBaseUnit} = U(getindex(rangeOfSIQuantities.r, inds...))

Base.eltype(                   ::Type{SIQuantityRange{T,U}}) where {T<:Real,U<:SIBaseUnit} = SIQuantityRange{T,U}
Base.IteratorSize(             ::Type{SIQuantityRange{T,U}}) where {T<:Real,U<:SIBaseUnit} = Base.IteratorSize(AbstractRange{Real})
Base.IteratorEltype(           ::Type{SIQuantityRange{T,U}}) where {T<:Real,U<:SIBaseUnit} = Base.HasEltype()
Base.length(rangeOfSIQuantities::SIQuantityRange{T,U}      ) where {T<:Real,U<:SIBaseUnit} = length(rangeOfSIQuantities.r)
Base.size(  rangeOfSIQuantities::SIQuantityRange{T,U}      ) where {T<:Real,U<:SIBaseUnit} = size(rangeOfSIQuantities.r)

# end
