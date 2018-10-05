# METAPROGRAMMING
#
# @eval $(ex) == eval(ex)
#
#
# AST: (call f x) -> Expr(:call, :f, :x)
# import Base: x, y	-> AST: (import (: (. Base) (. x) (. y))) -> Expr(:import, (:(:), (:., :Base), (:., :x), (:., :y)))

operations = ("+","-")

ex1 = :(import Base: +)
eval(ex1)
ex2 = :(import Base: $(:+))
eval(ex2)
ex3 = :(import Base: $(join(operations,", ")))
eval(ex3)
ex4 = :(import Base: +,-)
eval(ex4)
ex5 = :(import Base: $((:+,:-)...))
eval(ex5)
ex6 = :(import Base: $(:+),$(:-))
eval(ex6)

macroexpand(Main, quote @eval import Base: +, - end)
macroexpand(Main, quote @eval $(ex4) end)
macroexpand(Main, quote @eval $(ex6) end)

import Base: $((:+,:-))

# struct Degrees{T<:Number} <: Angle
#   val::T
# end
#
# convert(::Type{T}         , x::Degrees{T}) where {T<:Number}           = x.val
# convert(::Type{Degrees{T}}, x::Degrees{S}) where {T<:Number,S<:Number} = Degrees(T(x.val))
#
# promote_rule(::Type{Degrees{T}},::Type{Degrees{S}}) where {T<:Number,S<:Number} = Degrees{promote_type(T,S)}
#
# struct Radians{T<:Number} <: Angle
#   val::T
# end
#
# convert(::Type{T}         , x::Radians{T}) where {T<:Number}           = x.val
# convert(::Type{Radians{T}}, x::Radians{S}) where {T<:Number,S<:Number} = Radians(T(x.val))
#
# promote_rule(::Type{Radians{T}},::Type{Radians{S}}) where {T<:Number,S<:Number} = Radians{promote_type(T,S)}

#
# for op in (:+, :-)
#   @eval $op(x::Radians, y::Radians) = Radians($op(x.val, y.val))
#   @eval $op(x::Degrees, y::Degrees) = Degrees($op(x.val, y.val))
# end
#
# for op in (:*, :/, :÷, :^)
#   @eval $op(x::Radians, scalar::Number) = Radians($op(x.val, scalar))
#   @eval $op(x::Degrees, scalar::Number) = Degrees($op(x.val, scalar))
# end
#
# for op in (:*, :\)
#   @eval $op(scalar::Number, x::Radians) = Radians($op(scalar,x.val))
#   @eval $op(scalar::Number, x::Degrees) = Degrees($op(scalar,x.val))
# end

abstract type Angle end

asciiRepresentation = Dict("Degrees"=>"º"   , "Radians"=>"rad")
 htmlRepresentation = Dict("Degrees"=>"&deg", "Radians"=>"rad")

for angularUnits in (:Degrees, :Radians)
  @eval begin
          export $angularUnits

          struct $angularUnits{T<:Real} <: Angle
            val::T
          end

          convert(::Type{T}               , x::$angularUnits{T}) where {T<:Real}           = x.val
          convert(::Type{$angularUnits{T}}, x::$angularUnits{S}) where {T<:Real,S<:Real} = $angularUnits(T(x.val))

          promote_rule(::Type{$angularUnits{T}},::Type{$angularUnits{S}}) where {T<:Real,S<:Real} = $angularUnits{promote_type(T,S)}

          # Pretty printing
          Base.show(io::IO,                     x::$angularUnits{T}) where {T} = print(io, x.val, asciiRepresentation[$(String(angularUnits))])
          Base.show(io::IO, ::MIME"text/plain", x::$angularUnits{T}) where {T} = print(io, "Angle in ",$(String(angularUnits)),"{$T}: ", x, "\n")
          Base.show(io::IO, ::MIME"text/html" , x::$angularUnits{T}) where {T} = print(io, x.val, htmlRepresentation[$(String(angularUnits))] ," [<code>",$(String(angularUnits)),"{$T}</code>]")
        end
end

f(x::Real) = Base.Math.atand(x)
atand(x::Real) = test.Degrees(f(x))
atand(0)

using Main.Angles
x = Degrees(5)
y = Degrees(5.0)
z = Radians(0.03)

x + y
x + z

# isdefined(Base, :__precompile__) && __precompile__()

baremodule TestModule

using Base
export teststruct

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

# struct teststruct{T<:Int, S<:Float64}
#   x::T
#   y::S
# end

struct teststruct{t}
  teststruct{T}() where T = isa(T, Int) ? new() : error("teststruct can only be constructed with integers")
end
# (::Type{teststruct{t}})() where {t<:Int} = teststruct{t}()
# (::Type{teststruct{t}})() where {t>:Int} = errormessage("Error")
# teststruct(t::T) where {T<:Int} = teststruct{t}
# teststruct(t::T) where {T>:Int} = errormessage("Error")

end

using Main.TestModule
teststruct{1}()
teststruct{1.5}()

baremodule TestModule

using Base
export teststruct

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

teststruct = Tuple{Vararg{Int,7}}


end

using Main.TestModule
teststruct(0,0,0,0,0,0,0)


include("./Satcoms/src/SIBaseUnits.jl")
using Main.SIBaseUnits
Main.SIBaseUnits.SIBaseUnit{0,0}()


include("SIBaseUnits.jl")
include("SIQuantities.jl")
using SIBaseUnits
using SIQuantities

u = :m
m_i = 5
sy = Symbol(u,"_i")
io = stdout

@eval $(println(u,"=")) # -- m=
@macroexpand @eval $(println(u,"=")) # --> :((Base.Core).eval(Main, println(u, "=")))
@eval $(quote println(u,"=") end) # --> m=
@macroexpand @eval $(quote println(u,"=") end)  # --> :((Base.Core).eval(Main, $(Expr(:copyast, :($(QuoteNode(quote
                                                #         #= none:1 =#
                                                #         println(u, "=")
                                                #     end)))))))

@eval $(println(u,"=",sy)) # --> m=m_i
@macroexpand @eval $(println(u,"=",sy)) # :((Base.Core).eval(Main, println(u, "=", sy)))
@eval $(quote println(u,"=",$sy) end) # m=5
@macroexpand @eval $(quote println(u,"=",$sy) end) # :((Base.Core).eval(Main, (Core._expr)(:block, $(QuoteNode(:(#= none:1 =#))), (Core._expr)(:call, :println, :u, "=", sy))))
@eval $(quote println(u,"=",$(Symbol(u,"_i"))) end) # m=5
@macroexpand @eval $(quote println(u,"=",$(Symbol(u,"_i"))) end)

function f(io::IO, m_i::Int, kg_i::Int, s_i::Int, A_i::Int, K_i::Int, mol_i::Int, cd_i::Int)
  for u in (:m,:kg,:s,:A,:K,:mol,:cd)
      print(@macroexpand @eval println(io,u,"="))
      print("   ")
      print(@macroexpand @eval println($io,$u,"="))
      print("   ")
      println(u)
      @eval println($io,u,"=")
  end
end

extup = (:(x = 3),:(y = 5))
ex = quote $(extup...) end
eval(ex)

exarr = [:(x = 3),:(y = 5)]
push!(exarr, :(x+y))
ex = quote $(tuple(exarr...)...) end
eval(ex)

u = :m
m = 5
:(print(u))
:(print($u))

include("./Angles.jl")
using Main.Angles
x = Degrees(1:2:10)
Base.IteratorSize(typeof(x))
Base.IteratorSize(AbstractRange{Real})

# :((Base.Core).eval(Main, (Core._expr)(:block, $(QuoteNode(:(#= none:1 =#))), (Core._expr)(:call, :println, :u, "=", sy))))
# :((Base.Core).eval(Main, (Core._expr)(:block, $(QuoteNode(:(#= none:1 =#))), (Core._expr)(:call, :println, :u, "=", Symbol(u, "_i")))))

limit = 1e7
@time [^(SIUnit{1,2,3,4,5,6,7,8,9}(),20) for i=1:limit]
@time [SIBaseUnits.power(SIUnit{1,2,3,4,5,6,7,8,9}(),20) for i=1:limit]

unit = SIUnit{100,4,3,2,1,-1,-2,-3,-4}()
val = 15
quant = SIQuantity{typeof(val),1,2,3,4,5,6,7,8,9}(val)

siquantity(TypeVar(:Float64), unit)
typeof(unit)
typeof(typeof(unit))

@siquantity(Float64, unit)

val = 1.0
quant = SIQuantity{typeof(val),1,2,3,4,5,6,7,8,9}(val)
siquantity(TypeVar(:Int64), quant)

val = 100
quant = SIQuantity{typeof(val),1,2,3,4,5,6,7,8,9}(val)
@which(one(quant))
@which(one(SIQuantity{typeof(val),1,2,3,4,5,6,7,8,9}))

# macro parametersandvalues(tup...)
#     ex = esc(quote
#             parameter = $(map(x -> string(x),tup))
#             value     = $tup
#          end)
#     return ex
# end

# This macro is capable of generating specialised code when called with the "actual"
# arguments (values not parameters) at execution time. However, the value of the
# parameters is not available at parse time therefore a macro generating generic
# code is needed.
# macro buildnumandden(units, val)
#     evaluationstring = ""
#     u = eval(units)
#     v = eval(val)
#
#     for index = 1:length(v)
#         if v[index] != 0
#              leadingstring = (v[index] > 0) ?  "num" : "den"
#                 unitstring = "\\text{$(u[index])\}"
#            trainlingstring = (abs(v[index]) == 1) ? " " : "^{$(abs(v[index]))}"
#                 codestring = "push!($leadingstring,\"$(string(unitstring,trainlingstring))\")"
#           evaluationstring = string(evaluationstring, codestring, "\n")
#         end
#     end
#     #println(evaluationstring)
#     return parse("quote\n$evaluationstring\nend")
# end


include("./src/Angles.jl")
using Main.Angles
for op in Main.Angles.operationsTrigoInverse
  @eval $op(x::Real) = Main.Angles.$op(x)
end
