using Compat

import Base: ==, +, -, *, /, .+, .-, .*, ./, //, ^
import Base: promote_rule, promote_type, convert, show, mod

# Each combination of (T,m,kg,s,A,K,mol,cd,rad,sr) yields a different DataType:
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Float64,1,2,3,4,5,6,7,8,9}
# > true
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Number,1,2,3,4,5,6,7,8,9}
# > false
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9} <: SIQuantity{Float64,0,0,0,0,0,0,0,0,0}
# > false
# A specific instance of the DataType SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr} may be created in 2 ways:
# Explicitly: var = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(x::Number)
#   If (typeof(x) != T) or (typeof(x) cannot be promoted to T) then InexactError()
# Implicitly: var = SIQuantity(x::Number)
#   In which case a SIQuantity{typeof(x),0,0,0,0,0,0,0,0,0} will be created.

immutable SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr} <: Number
    val::T
end

# Up to this point:
# element = SIQuantity(6.0)
# > MethodError: `convert` has no method matching convert(::Type{SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}}, ::Float64)
# > This may have arisen from a call to the constructor SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(...),
# > since type constructors fall back to convert methods.
# > Closest candidates are:
# >   call{T}(::Type{T}, ::Any)
# >   convert{T<:Number}(::Type{T<:Number}, !Matched::Char)
# >   convert{T<:Number}(::Type{T<:Number}, !Matched::Base.Dates.Period)
#   ...
# x = 6.0
# element = SIQuantity{typeof(x),0,0,0,0,0,0,0,0,0}(x)
# >SIQuantity{Float64,0,0,0,0,0,0,0,0,0}(6.0)
# Works! Ranges

########################## Functions vs Constructors ###########################

# Here a funny behavior of Julia. The following lines define an outer constructor:
#
# typealias ScalarQuantity{T} SIQuantity{T,0,0,0,0,0,0,0,0,0}
#
# SIQuantity{T<:Number}(x::T) = ScalarQuantity{T}(x)
#
# @which SIQuantity(8.0)
# > call(::Type{SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}}, x::T<:Number) at none: 1

#  Alternatively, an equivalent function may be defined:
#
# SIQuantity(x::Number) = SIQuantity{typeof(x),0,0,0,0,0,0,0,0,0}(x)
#
# which is equivalent to: SIQuantity{T<:Number}(x::T) = SIQuantity{T,0,0,0,0,0,0,0,0,0}(x)
#
# If the previous constructor (line 43) is not defined then:
#
# @which SIQuantity(8.0)
# > call(::Type{SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}}, x::Number) at none: 1

# But if both are defined (lines 43 and 48) then:
#
# @which SIQuantity(8.0)
# > call(::Type{SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}}, x::T<:Number) at none: 1
#
# Therefore:

typealias ScalarQuantity{T} SIQuantity{T,0,0,0,0,0,0,0,0,0}

SIQuantity{T<:Number}(x::T) = ScalarQuantity{T}(x)

################################## Ranges ######################################

# The following block can be expresed in a more concise way:
abstract AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr} <: Range{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}

immutable SIRange{R<:Range,T<:Real,m,kg,s,A,K,mol,cd,rad,sr} <: AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr}
    val::R
end

# The following line produces the following error:
#
# r = 1.0:6.0;
# siRange = SIRange{typeof(r), eltype(r), 0,0,0,0,0,0,0,0,0}(r)
# > Error showing value of type SIRange{FloatRange{Float64},Float64,0,0,0,0,0,0,0,0,0}:
# >   ERROR: StackOverflowError:
# >    in length at abstractarray.jl:61 (repeats 2 times)
#
# However, if the output is suppressed in the REPL by adding a semicolon there is no error:
#
# siRange = SIRange{typeof(r), eltype(r), 0,0,0,0,0,0,0,0,0}(r);
#
# > typeof(siRange)
# SIRange{FloatRange{Float64},Float64,0,0,0,0,0,0,0,0,0}
#
# > siRange.val
# 1.0:1.0:6.0

# The following line produces the following error:
# siRange = SIRange(r)
# > MethodError: `convert` has no method matching convert(::Type{SIRange{R<:Range{T},T<:Number,m,kg,s,A,K,mol,cd,rad,sr}}, ::FloatRange{Float64})
# > This may have arisen from a call to the constructor SIRange{R<:Range{T},T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(...),
# > since type constructors fall back to convert methods.
# > Closest candidates are:
# >   call{T}(::Type{T}, ::Any)
# >   convert{T}(::Type{T}, !Matched::T)
# >  in call at essentials.jl:56
# >  in include_string at loading.jl:288
# >  in eval at C:\Users\Juan Lizarraga\.julia\v0.4\Atom\src\Atom.jl:3
# >  [inlined code] from C:\Users\Juan Lizarraga\.julia\v0.4\Atom\src\eval.jl:39
# >  in anonymous at C:\Users\Juan Lizarraga\.julia\v0.4\Atom\src\eval.jl:108
# >  in withpath at C:\Users\Juan Lizarraga\.julia\v0.4\Requires\src\require.jl:37
# >  in withpath at C:\Users\Juan Lizarraga\.julia\v0.4\Atom\src\eval.jl:53
# >  [inlined code] from C:\Users\Juan Lizarraga\.julia\v0.4\Atom\src\eval.jl:107
# >  in anonymous at task.jl:58

# For convenience an outer constructor can be defined:

SIRange{R<:Range}(r::R) = SIRange{typeof(r), eltype(r), 0,0,0,0,0,0,0,0,0}(r)

################################### Units ######################################

immutable SIUnit{m,kg,s,A,K,mol,cd,rad,sr} <: Number
end

            unit{T,m,kg,s,A,K,mol,cd,rad,sr}(x::AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr}) =     SIUnit{  m,kg,s,A,K,mol,cd,rad,sr}()
quantitydatatype{T,m,kg,s,A,K,mol,cd,rad,sr}(x::AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}

typealias UnitTuple NTuple{9,Int}

################################################################################

import Base: length, getindex, next, float64, float, int, show, start, step, last, done, first, eltype, one, zero

one(x::SIQuantity) = one(x.val)
one{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = one(T)
zero(x::SIQuantity) = zero(x.val) * unit(x)
zero{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = zero(T) * SIUnit{m,kg,s,A,K,mol,cd,rad,sr}()
