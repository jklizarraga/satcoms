# isdefined(Base, :__precompile__) && __precompile__()

baremodule SIBaseUnits

using Base
import Base: +, -, *, /, \, ^, inv
import Base: show
export SIBaseUnit, scalar, meter, m, kilogram, kg, seconds, s, ampere, A, kelvin, K, mole, mol, candela, cd
export +, -, *, /, \, ^

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

const UnitTuple = NTuple{7,Int}

struct SIBaseUnit{m,kg,s,A,K,mol,cd}
    SIBaseUnit{m,kg,s,A,K,mol,cd}() where {m,kg,s,A,K,mol,cd} = isa((m,kg,s,A,K,mol,cd), NTuple{7,Int}) ? new() : error("An SIBaseUnit{m,kg,s,A,K,mol,cd} can only be constructed with integers")
end
SIBaseUnit(m::Int,kg::Int,s::Int,A::Int,K::Int,mol::Int,cd::Int) = SIBaseUnit{m,kg,s,A,K,mol,cd}()

const scalar         = SIBaseUnit(0,0,0,0,0,0,0)
const meter    = m   = SIBaseUnit(1,0,0,0,0,0,0)
const kilogram = kg  = SIBaseUnit(0,1,0,0,0,0,0)
const second   = s   = SIBaseUnit(0,0,1,0,0,0,0)
const ampere   = A   = SIBaseUnit(0,0,0,1,0,0,0)
const kelvin   = K   = SIBaseUnit(0,0,0,0,1,0,0)
const mole     = mol = SIBaseUnit(0,0,0,0,0,1,0)
const candela  = cd  = SIBaseUnit(0,0,0,0,0,0,1)

# sibaseunit_tuple(::Type{SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = (m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i)
# sibaseunit_tuple(     ::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} ) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = (m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i)
# As working with SIBaseUnits is equivalent to work with the corresponding tuples, then all the operations are defied over the tuples.

+(x::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i},y::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = x # x and y are singletons therefore x==y.
-(x::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i},y::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = x # x and y are singletons therefore x==y.

*(x::SIBaseUnit{m1,kg1,s1,A1,K1,mol1,cd1},y::SIBaseUnit{m2,kg2,s2,A2,K2,mol2,cd2}) where {m1,kg1,s1,A1,K1,mol1,cd1,m2,kg2,s2,A2,K2,mol2,cd2} = SIBaseUnit{m1+m2,kg1+kg2,s1+s2,A1+A2,K1+K2,mol1+mol2,cd1+cd2}() # x and y are singletons therefore x==y.
/(x::SIBaseUnit{m1,kg1,s1,A1,K1,mol1,cd1},y::SIBaseUnit{m2,kg2,s2,A2,K2,mol2,cd2}) where {m1,kg1,s1,A1,K1,mol1,cd1,m2,kg2,s2,A2,K2,mol2,cd2} = SIBaseUnit{m1-m2,kg1-kg2,s1-s2,A1-A2,K1-K2,mol1-mol2,cd1-cd2}() # x and y are singletons therefore x==y.
\(x::SIBaseUnit{m1,kg1,s1,A1,K1,mol1,cd1},y::SIBaseUnit{m2,kg2,s2,A2,K2,mol2,cd2}) where {m1,kg1,s1,A1,K1,mol1,cd1,m2,kg2,s2,A2,K2,mol2,cd2} = SIBaseUnit{m2-m1,kg2-kg1,s2-s1,A2-A1,K2-K1,mol2-mol1,cd2-cd1}() # x and y are singletons therefore x==y.

^(::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}, i::Integer) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = SIBaseUnit{m_i*i,kg_i*i,s_i*i,A_i*i,K_i*i,mol_i*i,cd_i*i}()

inv(::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i} = SIBaseUnit{-m_i,-kg_i,-s_i,-A_i,-K_i,-mol_i,-cd_i}()

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

   # The code above generates the code under when called with @generateshowcode("_i", m,kg,s,A,K,mol,cd)
   #   m_i ≠ 0 && print(io, "m"  , (  m_i == 1 ? ' ' : tosuperscript(  m_i)))
   #  kg_i ≠ 0 && print(io, "kg" , ( kg_i == 1 ? ' ' : tosuperscript( kg_i)))
   #   s_i ≠ 0 && print(io, "s"  , (  s_i == 1 ? ' ' : tosuperscript(  s_i)))
   #   A_i ≠ 0 && print(io, "A"  , (  A_i == 1 ? ' ' : tosuperscript(  A_i)))
   #   K_i ≠ 0 && print(io, "K"  , (  K_i == 1 ? ' ' : tosuperscript(  K_i)))
   # mol_i ≠ 0 && print(io, "mol", (mol_i == 1 ? ' ' : tosuperscript(mol_i)))
   #  cd_i ≠ 0 && print(io, "cd" , ( cd_i == 1 ? ' ' : tosuperscript( cd_i)))

end

function show(io::IO,u::SIBaseUnit{m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}) where {m_i,kg_i,s_i,A_i,K_i,mol_i,cd_i}
   @generateshowcode("_i", m,kg,s,A,K,mol,cd)
end

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

end
