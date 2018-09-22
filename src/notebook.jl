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
