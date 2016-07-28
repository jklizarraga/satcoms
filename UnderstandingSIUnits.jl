using Compat

import Base: ==, +, -, *, /, .+, .-, .*, ./, //, ^
import Base: promote_rule, promote_type, convert, show, mod

# Each combination of (T,m,kg,s,A,K,mol,cd,rad,sr) yields a different DataType:
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Float64,1,2,3,4,5,6,7,8,9}
# true
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Number,1,2,3,4,5,6,7,8,9}
# false
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Float64,0,0,0,0,0,0,0,0,0}
# false
# A specific instance of the DataType SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr} may be created in 2 ways:
# Explicitly: var = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(x::Number)
#   If (typeof(x) != T) or (typeof(x) cannot be promoted to T) then InexactError()
# Implicitly: var = SIQuantity(x::Number)
#   In which case a SIQuantity{typeof(x),0,0,0,0,0,0,0,0,0} will be created.

immutable SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr} <: Number
    val::T
end

# The typealias and the constructor definition
typealias UnitQuantity{T} SIQuantity{T,0,0,0,0,0,0,0,0,0}

SIQuantity{T<:Number}(x::T) = UnitQuantity{T}(x)

immutable SIUnit{m,kg,s,A,K,mol,cd,rad,sr} <: Number
end

abstract SIRanges{T,m,kg,s,A,K,mol,cd,rad,sr} <: Range{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}

immutable SIRange{R<:Range,T<:Real,m,kg,s,A,K,mol,cd,rad,sr} <: SIRanges{T,m,kg,s,A,K,mol,cd,rad,sr}
    val::R
end

typealias UnitTuple NTuple{9,Int}

      unit{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIRanges{T,m,kg,s,A,K,mol,cd,rad,sr}) =     SIUnit{  m,kg,s,A,K,mol,cd,rad,sr}()
  quantity{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIRanges{T,m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}
