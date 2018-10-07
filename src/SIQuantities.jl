# isdefined(Base, :__precompile__) && __precompile__()


# module SIQuantitiesPkg

# using ..SIBaseUnitsPkg: SIBaseUnit, SIBaseUnits, scalar

export SIQuantity

struct SIQuantity{T<:Number,U<:SIBaseUnit}
    val::T
    SIQuantity(x::T,u::SIBaseUnit) where {T<:Number} = new{T,typeof(u)}(x)
end
SIQuantity(x::T,::Type{U}) where {T<:Number,U<:SIBaseUnit} = SIQuanity{T,U}(x)

SIScalar(x::T)   where {T<:Number} = SIQuantity{T,scalar}(x)
SIQuantity(x::T) where {T<:Number} = SIScalar(x)

import Base: show
function show(io::IO,x::SIQuantity{T,U}) where {T,U}
    show(io,x.val)
    print(io," ")
    show(io,U)
end

# end
