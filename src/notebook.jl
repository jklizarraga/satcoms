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
import Base: ==, +, -, *, /, ÷, ^, \, %, rem, mod, rem2pi, mod2pi
import Base: sin, cos, tan, cot, sec, csc, sinc, cosc, sinpi, cospi
import Base: convert, promote_rule, show

abstract type Angle end

asciiRepresentation = Dict("Degrees"=>"º"   , "Radians"=>"rad")
 htmlRepresentation = Dict("Degrees"=>"&deg", "Radians"=>"rad")

for angularUnits in (:Degrees, :Radians)
  angularUnits = :Degrees
  macroexpand(Main,
    quote @eval begin
                  struct $angularUnits{T<:Number} <: Angle
                    val::T
                  end

                  convert(::Type{T}               , x::$angularUnits{T}) where {T<:Number}           = x.val
                  convert(::Type{$angularUnits{T}}, x::$angularUnits{S}) where {T<:Number,S<:Number} = $angularUnits(T(x.val))

                  promote_rule(::Type{$angularUnits{T}},::Type{$angularUnits{S}}) where {T<:Number,S<:Number} = $angularUnits{promote_type(T,S)}

                  Base.show(io::IO,                     x::$angularUnits{T}) where {T} = print(io, x.val, asciiRepresentation[$(String(angularUnits))])
                  Base.show(io::IO, ::MIME"text/plain", x::$angularUnits{T}) where {T} = print(io, "Angle in ",$(String(angularUnits)),"{$T}: ", x, "\n")
                  Base.show(io::IO, ::MIME"text/html" , x::$angularUnits{T}) where {T} = print(io, x.val, htmlRepresentation[$(String(angularUnits))] ," [<code>",$(String(angularUnits)),"{$T}</code>]")
              end
    end)
end

using Main.Angles
x = Degrees(5)
y = Degrees(5.0)
z = Radians(0.03)

x + y
x + z

include("SIBaseUnits.jl")
include("SIQuantities.jl")
using SIBaseUnits
using SIQuantities

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
