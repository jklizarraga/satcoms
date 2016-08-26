#include("SIUnit.jl")

immutable SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr} <: Number
    val::T
end

typealias ScalarQuantity{T} SIQuantity{T,0,0,0,0,0,0,0,0,0}

SIQuantity{T<:Number}(x::T) = ScalarQuantity{T}(x)

# The function "unit()" returns the SIUnit of a SIQuantity.
unit{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}) = SIUnit{m,kg,s,A,K,mol,cd,rad,sr}()

export quantity, @quantity

# The following method of the function "quantity()" converts a DataType ScalarQuantity{S} into a ScalarQuantity{T}
function quantity{S}(T,quant::SIQuantity{S})
    quant.val == one(S) || error("Quantity value must be unity!")
    quantity(T,unit(quant))
end
# The following method of the function "quantity(T,SIUnit{})" receives a DataType SIUnit{} and returns the corresponding DataType SIQuanity{T,SIUnit}
quantity{m,kg,s,A,K,mol,cd,rad,sr}(T::TypeVar,unit::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}

# The follwoing methods of the function "tup()" extract the UnitTuple of a SIUnit{} or a SIQuantity{}
tup{  m,kg,s,A,K,mol,cd,rad,sr}(u::SIUnit{      m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)
tup{T,m,kg,s,A,K,mol,cd,rad,sr}(u::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)

# The following macro
macro quantity(expr,unit)
    esc(:(SIUnits.SIQuantity{$expr,SIUnits.tup($unit)...}))
end
