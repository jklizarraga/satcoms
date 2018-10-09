# isdefined(Base, :__precompile__) && __precompile__()

# module SIBaseUnitsPkg

# using ..Units: SIUnits

import Base: +, -, *, /, \, ^, inv
import Base: show

export SIBaseUnit, SIBaseUnits, scalar, meter, m, kilogram, kg, seconds, s, ampere, A, kelvin, K, mole, mol, candela
export +, -, *, /, \, ^

# eval(x) = Core.eval(Mod, x)
# include(p) = Base.include(Mod, p)

const UnitTuple = NTuple{7,Int}

struct SIBaseUnit{m,kg,s,A,K,mol,cd}
    SIBaseUnit{m,kg,s,A,K,mol,cd}() where {m,kg,s,A,K,mol,cd} = isa((m,kg,s,A,K,mol,cd), NTuple{7,Int}) ? new() : error("An SIBaseUnit{m,kg,s,A,K,mol,cd} can only be constructed with integers")
end
SIBaseUnit(m::Int,kg::Int,s::Int,A::Int,K::Int,mol::Int,cd::Int) = SIBaseUnit{m,kg,s,A,K,mol,cd}

const scalar         = SIBaseUnit{0,0,0,0,0,0,0}
const meter    = m   = SIBaseUnit{1,0,0,0,0,0,0}
const kilogram = kg  = SIBaseUnit{0,1,0,0,0,0,0}
const second   = s   = SIBaseUnit{0,0,1,0,0,0,0}
const ampere   = A   = SIBaseUnit{0,0,0,1,0,0,0}
const kelvin   = K   = SIBaseUnit{0,0,0,0,1,0,0}
const mole     = mol = SIBaseUnit{0,0,0,0,0,1,0}
const candela  = cd  = SIBaseUnit{0,0,0,0,0,0,1}

siArrayBase    = ["m","kg","s","A","K","mol","cd"]
suffixVariable = [""  ,"1","2"]
suffixTuple    = ["_i","1","2"]

# Generate variables siArray, siArray1, siArray2, siTuple, siTuple1, siTuple2, siUnit, siUnit1, siUnit2
for i in 1:length(suffixVariable)
   siArrayX, siTupleX, siUnitX  = Symbol("siArray"*suffixVariable[i]), Symbol("siTuple"*suffixVariable[i]), Symbol("siUnit" *suffixVariable[i])
   @eval $siArrayX = siArrayBase.*$(suffixTuple[i])
   @eval $siTupleX = tuple(Symbol.($siArrayX)...)
   @eval $siUnitX  = :(SIBaseUnit{$(($siTupleX)...)})
end

for op in (:+,:-)
   @eval $op(x::Type{$siUnit},y::Type{$siUnit}) where {$(siTuple...)} = $siUnit
   @eval $op(x::Type{$siUnit},y::$siUnit      ) where {$(siTuple...)} = $siUnit
   @eval $op(x::$siUnit      ,y::Type{$siUnit}) where {$(siTuple...)} = $siUnit
   @eval $op(x::$siUnit      ,y::$siUnit      ) where {$(siTuple...)} = $siUnit
end

siTuple1Tuple2 = (siTuple1...,siTuple2...)

resultExpression(siTupleArray::Array{String,1}) = Meta.parse("SIBaseUnit{"*join(siTupleArray, ",")*"}")

siUnitResult = Dict( :* => resultExpression(siArray1 .* "+" .* siArray2), # -> :((m1 + m2, kg1 + kg2, s1 + s2, A1 + A2, K1 + K2, mol1 + mol2, cd1 + cd2))
                     :/ => resultExpression(siArray1 .* "-" .* siArray2),
                     :\ => resultExpression(siArray2 .* "-" .* siArray1))

for op in (:*, :/, :\)
   @eval $op( ::Type{$siUnit1}, ::Type{$siUnit2}) where {$(siTuple1Tuple2...)} = $(siUnitResult[op])
   @eval $op( ::Type{$siUnit1},y::$siUnit2      ) where {$(siTuple1Tuple2...)} = $(siUnitResult[op])
   @eval $op(x::$siUnit1      , ::Type{$siUnit2}) where {$(siTuple1Tuple2...)} = $(siUnitResult[op])
   @eval $op(x::$siUnit1      ,y::$siUnit2      ) where {$(siTuple1Tuple2...)} = $(siUnitResult[op])
end

siUnitResult = resultExpression(siArray.*"*i")
@eval ^(::Type{$siUnit}, i::Integer) where {$(siTuple...)} = $siUnitResult
@eval ^(     ::$siUnit , i::Integer) where {$(siTuple...)} = $siUnitResult
siUnitResult = resultExpression("Int(".*siArray.*"*i)")
@eval ^(::Type{$siUnit}, i::Rational) where {$(siTuple...)} = $siUnitResult
@eval ^(     ::$siUnit , i::Rational) where {$(siTuple...)} = $siUnitResult

siUnitResult = resultExpression("-".*siArray)
@eval inv(::Type{$siUnit}) where {$(siTuple...)} = $siUnitResult
@eval inv(     ::$siUnit ) where {$(siTuple...)} = $siUnitResult

export joule, coulomb, volt, farad, newton, ohm, hertz, siemens, watt, pascal
# Definition of the SI derived units:
const joule      = kilogram*meter^2/second^2
const coulomb    = ampere*second
const volt       = joule/coulomb
const farad      = coulomb^2/joule
const newton     = kilogram*meter/second^2
const ohm        = volt/ampere
const hertz      = inv(second)
const siemens    = inv(ohm)
const watt       = joule/second
const pascal     = newton/meter^2

# Pretty Printing - Text
#
# This is an auxiliary function used by the show() function.
# This function takes the number::Int and gets its string representation using repr().
# It then applies to each caracter in the string the function in the Do-Block using the map() function.
# The function in the Do-Block changes each character for its equivalent in UNICODE superscript form.
# (https://docs.julialang.org/en/v1/base/strings/#Base.repr-Tuple{Any})
# (https://docs.julialang.org/en/v1.0.0/manual/functions/#Do-Block-Syntax-for-Function-Arguments-1)

tosuperscript(number::Int) = map(repr(number)) do c
   c  ==  '-' ? '\u207b' :
   c  ==  '1' ? '\u00b9' :
   c  ==  '2' ? '\u00b2' :
   c  ==  '3' ? '\u00b3' :
   c  ==  '4' ? '\u2074' :
   c  ==  '5' ? '\u2075' :
   c  ==  '6' ? '\u2076' :
   c  ==  '7' ? '\u2077' :
   c  ==  '8' ? '\u2078' :
   c  ==  '9' ? '\u2079' :
   c  ==  '0' ? '\u2070' :
   # c  ==  '+' ? '\u207a' :
   # c  ==  '.' ? '\u22c5' :
   error("Unexpected Chatacter")
end

macro generateshowcode(suffix, tupleOfUnits...) # ... denotes a variable number of arguments.
   expressionsArray = []
   for unit in tupleOfUnits
      functionParameter = Symbol(unit,suffix)
      ex = esc(:($functionParameter ≠ 0 && print(io, $(String(unit)), ($functionParameter == 1 ? ' ' : tosuperscript($functionParameter)))))
      push!(expressionsArray, ex)
   end

   return quote $(tuple(expressionsArray...)...) end

end

function show(io::IO,::Type{SIBaseUnit{0,0,0,0,0,0,0}})
   print("(scalar)")
end

show(io::IO,::SIBaseUnit{0,0,0,0,0,0,0}) = show(io, Type{SIBaseUnit{0,0,0,0,0,0,0}})

function show(io::IO,::Type{SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}
   @generateshowcode("_i", m,kg,s,A,K,mol,cd)
end

@eval show(io::IO,::SIBaseUnit{$siTuple}) where {$(siTuple...)} = show(io, Type{SIBaseUnit{$siTuple}})

macro generatenumeratoranddenominatorcode(suffix, tupleOfUnits...)
   expressionsArray = []
   for unit in tupleOfUnits
      functionParameter = Symbol(unit,suffix)
      unitString  = "\\text{$unit}"
      latexString = :($unitString * (abs($functionParameter) == 1 ? "\\," : "^{" * string(abs($functionParameter)) * "}"))
      ex = esc(:($functionParameter ≠ 0 && ($functionParameter ≥ 1 ? num *= $latexString : den *= $latexString)))
      push!(expressionsArray, ex)
   end

   return quote $(tuple(expressionsArray...)...) end
end

export latexstring
function latexstring(u::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}
   num = ""
   den = ""
   out = ""

   @generatenumeratoranddenominatorcode("_i", m,kg,s,A,K,mol,cd)

   if !isempty(den)
      (length(den)>1 && den[end-1:end]=="\\,") ? den=den[1:end-2] : nothing
      if isempty(num)
         out = "\$\\frac{1}{" * den * "}\$"
      else
         (length(num)>1 && num[end-1:end]=="\\,") ? num=num[1:end-2] : nothing
         out = "\$\\frac{" * num * "}{" * den * "}\$"
      end
   else
      (length(num)>1 && num[end-1:end]=="\\,") ? num=num[1:end-2] : nothing
      out = "\$" * num * "\$"
   end
   return out

end

#end #module
