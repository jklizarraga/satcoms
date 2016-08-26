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

export quantity, @quantity
unit{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}     ) =     SIUnit{  m,kg,s,A,K,mol,cd,rad,sr}()

function quantity{S}(T,quant::SIQuantity{S})
    quant.val == one(S) || error("Quantity value must be unity!")
    quantity(T,unit(quant))
end
quantity{m,kg,s,A,K,mol,cd,rad,sr}(T::(@compat Union{Type,TypeVar}),unit::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}

tup{  m,kg,s,A,K,mol,cd,rad,sr}(u::SIUnit{      m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)
tup{T,m,kg,s,A,K,mol,cd,rad,sr}(u::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)

macro quantity(expr,unit)
    esc(:(SIUnits.SIQuantity{$expr,SIUnits.tup($unit)...}))
end


################################### Units ######################################

immutable SIUnit{m,kg,s,A,K,mol,cd,rad,sr} <: Number
end

typealias UnitTuple NTuple{9,Int}

tup2u(tup::UnitTuple) = SIUnit{tup[1], tup[2], tup[3], tup[4], tup[5], tup[6], tup[7], tup[8], tup[9]}
    -(tup::UnitTuple) =      (-tup[1],-tup[2],-tup[3],-tup[4],-tup[5],-tup[6],-tup[7],-tup[8],-tup[9])

for op in (:-,:*,:+)
    @eval function $(op)(tup1::UnitTuple,tup2::UnitTuple)
        ($(op)(tup1[1],tup2[1]),$(op)(tup1[2],tup2[2]),$(op)(tup1[3],tup2[3]),$(op)(tup1[4],tup2[4]),$(op)(tup1[5],tup2[5]),
            $(op)(tup1[6],tup2[6]),$(op)(tup1[7],tup2[7]),$(op)(tup1[8],tup2[8]),$(op)(tup1[9],tup2[9]))
    end
end

################################################################################

import Base: length, getindex, next, float64, float, int, show, start, step, last, done, first, eltype, one, zero

### Defining new methods for the functions one() and zero():
# This first method is not parametric therefore it can be expressed as function
one(x::SIQuantity) = one(x.val)
# This second method is parametric therefore it has to use the parametric syntax.
# The fact that the argument has no name but does have a type is because is never used as indicated in Julia 0.4 manual (http://docs.julialang.org/en/release-0.4/manual/conversion-and-promotion/#defining-new-conversions)
one{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = one(T)

# > x = 6.0
# > quantity = SIQuantity{typeof(x),1,2,3,4,5,6,7,8,9}(x)
# SIQuantity{Float64,1,2,3,4,5,6,7,8,9}(6.0)
# > one(quantity)
# 1.0
# > typeof(one(quantity))
# Float64
# @ which one(quantity)
# one(x::SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}) at C:\Users\Juan Lizarraga\Documents\Satcoms\UnderstandingSIUnits.jl:136
#
# Therefore the method that is called is the first one. To invoke the second method then a DataType has to be passed as an argument.
#
# > one(SIQuantity{Int64,0,0,0,0,0,0,0,0,0})
# 1
# > typeof(one(SIQuantity{Int64,0,0,0,0,0,0,0,0,0}))
# Int64
# > @which one(SIQuantity{Int64,0,0,0,0,0,0,0,0,0})
# one{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) at C:\Users\Juan Lizarraga\Documents\Satcoms\UnderstandingSIUnits.jl:139

# No method has been defined for *(::Type{T}, ::SIUnit) therefore:
# > zero(quantity)
# no promotion exists for Float64 and SIUnit{1,2,3,4,5,6,7,8,9} in zero at string:1
# Thus a promotion rule has to be created or a new method defined:

# > promote_rule{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{T},y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}
# (Type{#T<:Number}, Type{Main.SIUnit{#m<:Any, #kg<:Any, #s<:Any, #A<:Any, #K<:Any, #mol<:Any, #cd<:Any, #rad<:Any, #sr<:Any}}) at string:1
# is ambiguous with:
#     promote_rule(Type{Bool}, Type{#T<:Number}) at bool.jl:9.
# To fix, define
#     promote_rule(Type{Bool}, Type{Main.SIUnit{#m<:Any, #kg<:Any, #s<:Any, #A<:Any, #K<:Any, #mol<:Any, #cd<:Any, #rad<:Any, #sr<:Any}})
# before the new definition.
# WARNING: New definition
#     promote_rule(Type{#T<:Number}, Type{Main.SIUnit{#m<:Any, #kg<:Any, #s<:Any, #A<:Any, #K<:Any, #mol<:Any, #cd<:Any, #rad<:Any, #sr<:Any}}) at string:1
# is ambiguous with:
#     promote_rule(Type{Base.Irrational{#s<:Any}}, Type{#T<:Number}) at irrationals.jl:11.
# To fix, define
#     promote_rule(Type{Base.Irrational{#s<:Any}}, Type{Main.SIUnit{#m<:Any, #kg<:Any, #s<:Any, #A<:Any, #K<:Any, #mol<:Any, #cd<:Any, #rad<:Any, #sr<:Any}})
# before the new definition.
#
# Therefore:
## (Note: It is to be noticed that as the units of the result depend on the operation then it makes no sense to keep the units and instead both operands are propomoted to a scalar.)
promote_rule{sym      ,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Irrational{sym}},y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = ScalarQuantity{Irrational{sym}}
promote_rule{          m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Bool           },y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = ScalarQuantity{Bool           }
promote_rule{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{T              },y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = ScalarQuantity{T              }
## The promotion rules need to be supported by the appropriate conversion methods:
convert{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}},val::Number                          ) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(convert(T,  val))
convert{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T                         }},  x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(    one(T)      )
convert{T<:Number                         }(::Type{SIQuantity{T                         }},  x::T                               ) = ScalarQuantity{T}(x)
convert{T<:Number,S<:Number               }(::Type{SIQuantity{T                         }},  x::S                               ) = convert(ScalarQuantity{T},convert(T,x))

# Same applies to SIQuantity:
## Promotions for operations between a basic type and a SIQuantity
promote_rule{sym,T      ,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Irrational{sym}},y::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(Irrational{sym},T)}
promote_rule{          S,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Bool           },y::Type{SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(           Bool,S)}
promote_rule{T<:Number,S,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{T              },y::Type{SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(              T,S)}
## Promotions for operations between two SIQuantities
promote_rule{T,S,m ,kg ,s ,A ,K ,mol ,cd ,rad ,sr                                   }(x::Type{SIQuantity{T                                  }},y::Type{SIQuantity{S,m ,kg ,s ,A ,K ,mol ,cd ,rad ,sr }}) = SIQuantity{promote_type(T,S)}
promote_rule{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(A::Type{SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}},B::Type{SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS}}) = SIQuantity{promote_type(T,S)}
promote_rule{T,  mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(A::Type{SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}},B::Type{SIUnit{      mS,kgS,sS,AS,KS,molS,cdS,radS,srS}}) = SIQuantity{T}
## The promotion rules need to be supported by the appropriate conversion methods:
convert{T<:Number,S,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T}},x::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(convert(T,x.val))
convert{T<:Number                           }(::Type{SIQuantity{T}},x::SIQuantity{T}                         ) = x
# Unlike most other types, the promotion of two identitical SIQuantities is
# not that type itself. As such, the promote_type behavior itself must be
# overridden by overloading the method. C.f. https://github.com/Keno/SIUnits.jl/issues/27
promote_type{T,m,kg,s,A,K,mol,cd,rad,sr}( ::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}, ::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{T}

# zero(x::SIQuantity) = zero(x.val) * unit(x)
#zero{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = zero(T) * SIUnit{m,kg,s,A,K,mol,cd,rad,sr}()


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

#SIRange{R<:Range}(r::R) = SIRange{typeof(r), eltype(r), 0,0,0,0,0,0,0,0,0}(r)

# unit{T,m,kg,s,A,K,mol,cd,rad,sr}(x::AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr}) =     SIUnit{  m,kg,s,A,K,mol,cd,rad,sr}()
# quantitydatatype{T,m,kg,s,A,K,mol,cd,rad,sr}(x::AbstractSIRange{T,m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}
