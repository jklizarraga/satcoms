# Benchmarking

include("Angles.jl")
using Main.Angles
using Statistics
S = 10
N = 10000
t = zeros(Float64,S)
tref = zeros(Float64,S)
for i in 1:S
    s  = 2^i

    m1 = rand(s,s)
    m2 = rand(s,s)
    m3 = (m1)deg
    m4 = (m2)deg
    @elapsed m1+m2
    @elapsed m3+m4

    for j in 1:N
      tref[i] += @elapsed m1+m2
      t[i]    += @elapsed m3+m4
    end

    tref[i] /= N
    t[i] /= N

end
println(t./tref)
println(mean(t./tref))

# Results for S=10, N=1000
# [0.963113, 0.996702, 0.719338, 1.21352, 1.03335, 0.971611, 0.992234, 0.772692, 0.998298, 1.00277]
# 0.966362453606228
# Results for S=10, N=10000
# [0.987338, 0.989298, 0.497516, 1.18991, 0.931941, 0.981512, 1.00617, 1.29759, 1.00667, 0.999558]
# 0.9887505207007307

include("SIQuantities.jl")


# METAPROGRAMMING
#
# @eval $(ex) == eval(ex)
#
#
# AST: (call f x) -> Expr(:call, :f, :x)
# import Base: x, y	-> AST: (import (: (. Base) (. x) (. y))) -> Expr(:import, (:(:), (:., :Base), (:., :x), (:., :y)))

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

# IMPORTANT: The error is to put the @eval in the for-block of a FUNCTION! Remeber macros are expanded at compilation time not at runtime.s
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

# Expressions can be cascaded in an array of expressions and then converted to a tuple for execution. Maybe a begin-block or the ";" could do the trick also.
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

# struct teststruct{T}
#   teststruct{T}() where T = isa(T, Int) ? new() : error("teststruct can only be constructed with integers")
# end

struct teststruct{m<:Int,kg<:Int,s<:Int,A<:Int,K<:Int,mol<:Int,cd<:Int}
  # teststruct{T}() where T = isa(T, Int) ? new() : error("teststruct can only be constructed with integers")
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

# Usage in REPL:
include("Angles.jl")
using Main.Angles
for op in Main.Angles.operationsInverse
  @eval $op(x::Real) = Main.Angles.$op(x)
end

############################

using Units
SIQuantity(0, scalar)
Units.SIQuantitiesPkg.SIQuantity(0, Units.SIBaseUnitsPkg.scalar)
SIQuanity(x::T,u::SIBaseUnit) where {T<:Number} = Units.SIQuantitiesPkg.SIQuanity{T,typeof(u)}(x)
Units.SIQuantitiesPkg.ScalarQuantity(0)

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
