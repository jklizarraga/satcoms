#using SIBaseUnits

x = SIBaseUnits.SIUnit{100,4,3,2,1,-1,-2,-3,-4}()

# This is an auxiliary macro to be used in the writemime() method below. It uses the
# "num" and "den" variables from the calling function scope.
# In summary the macro takes x corresponding to the exponent of each of the base units
# and depending on whether it is positive or negative it adds it to the nominator or
# denominator string ""\\text{",$(string(x)),"\}". regarding the exponent if it is
# +/- 1 then it adds an empty space otherwise it adds the string "^{",abs($x),"}"
# macro l(x)
#     esc(quote
#           $x != 0 && push!($x>0?num:den,string("\\text{",$(string(x)),"\}",abs($x) == 1 ? " " : string("^{",abs($x),"}")))
#         end)
# end
#
# function Base.Multimedia.writemime{m,kg,s,A,K,mol,cd,rad,sr}(io::IO,::MIME"text/mathtex+latex",x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr})
#     num = ASCIIString[]
#     den = ASCIIString[]
#     @l m
#     @l kg
#     @l s
#     @l A
#     @l K
#     @l mol
#     @l cd
#     @l rad
#     @l sr
#     if !isempty(den)
#         if isempty(num)
#             write(io,"\\frac{1}{",join(den,"\\;"),"}")
#         else
#             write(io,"\\frac{",join(num,"\\;"),"}{",join(den,"\\;"),"}")
#         end
#     else
#         write(io,join(num,"\\;"))
#     end
#
# end

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

# The template code line that needs to be "copied" 9 times is:
#   paramName != 0 && push!(paramName>0?num:den,string("\\text{",paramNameString,"}",abs(paramName) == 1 ? " " : string("^{",abs(paramName),"}")))
# For example: paramName = m; paramNameString = "m"
#   m != 0 && push!(m >0?num:den,string("\\text{","m","}",abs(m) == 1 ? " " : string("^{",abs(m),"}")))
macro generatenumanddencode(unittup...)
    evaluationstring = ASCIIString[]

    push!(evaluationstring, "quote")
    for unit in unittup
        codeline = "$unit != 0 && push!($unit>0?num:den,string(\"\\\\text{$unit}\",abs($unit) == 1 ? \"\" : string(\"^{\",abs($unit),\"}\")))"
        push!(evaluationstring, codeline)
    end
    push!(evaluationstring, "end")

    return eval(parse(join(evaluationstring, "\n")))
end

function latexstring{m,kg,s,A,K,mol,cd,rad,sr}(::SIBaseUnits.SIUnit{m,kg,s,A,K,mol,cd,rad,sr})
    num = ASCIIString[]
    den = ASCIIString[]
    out = ""

    @generatenumanddencode(m,kg,s,A,K,mol,cd,rad,sr)

    if !isempty(den)
        if isempty(num)
            out = string("\\frac{1}{",join(den,"\\;"),"}")
        else
            out = string("\\frac{",join(num,"\\;"),"}{",join(den,"\\;"),"}")
        end
    else
        out = string(join(num,"\\;"))
    end
    return out
end

println(latexstring(x))
