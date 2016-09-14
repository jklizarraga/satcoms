isdefined(Base, :__precompile__) && __precompile__()

module SIBaseUnits

  import Base: ==, +, -, *, /, //, ^
  import Base: show, inv, writemime

  export SIUnit

  immutable SIUnit{m,kg,s,A,K,mol,cd,rad,sr} <: Number
  end

  typealias UnitTuple NTuple{9,Int}

  # Function to extract the UnitTuple corresponding to the SIUnit:
  tup{m,kg,s,A,K,mol,cd,rad,sr}(::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)
  # Function to convert a UnitTuple into a SIUnit (DataType):
  tup2u(tup::UnitTuple) = SIUnit{tup[1], tup[2], tup[3], tup[4], tup[5], tup[6], tup[7], tup[8], tup[9]}()
  # Definition of the "-" operator for a single UnitTuple:
      -(tup::UnitTuple) =      (-tup[1],-tup[2],-tup[3],-tup[4],-tup[5],-tup[6],-tup[7],-tup[8],-tup[9])

  # Metaprogramming block to define the addition(+), subtraction(-) and
  # multiplication(*) between 2 UnitTuples to be used as the base for the
  # operations between SIUnit(s):
  for op in (:+,:-,:*)
      @eval function $(op)(tup1::UnitTuple,tup2::UnitTuple)
                return ($(op)(tup1[1],tup2[1]),$(op)(tup1[2],tup2[2]),$(op)(tup1[3],tup2[3]),$(op)(tup1[4],tup2[4]),$(op)(tup1[5],tup2[5]),$(op)(tup1[6],tup2[6]),$(op)(tup1[7],tup2[7]),$(op)(tup1[8],tup2[8]),$(op)(tup1[9],tup2[9]))
            end

      @eval function $(op)(tup::UnitTuple, i::Integer)
                return ($(op)(tup[1],i),$(op)(tup[2],i),$(op)(tup[3],i),$(op)(tup[4],i),$(op)(tup[5],i),$(op)(tup[6],i),$(op)(tup[7],i),$(op)(tup[8],i),$(op)(tup[9],i))
            end

      @eval function $(op)(i::Integer,tup::UnitTuple)
                return ($(op)(i,tup[1]),$(op)(i,tup[2]),$(op)(i,tup[3]),$(op)(i,tup[4]),$(op)(i,tup[5]),$(op)(i,tup[6]),$(op)(i,tup[7]),$(op)(i,tup[8]),$(op)(i,tup[9]))
            end
  end

  # Definition of the operations between SIUnit(s)
  for op in (:/,://)
      @eval $(op)(x::SIUnit,y::SIUnit) = tup2u(tup(x)-tup(y))
  end

  # The followig method yields the same LLVM code as:
  # inv{m,kg,s,A,K,mol,cd,rad,sr}(::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIUnit{-m,-kg,-s,-A,-K,-mol,-cd,-rad,-sr}()
  inv(x::SIUnit) = tup2u(-tup(x))

  ==(x::SIUnit,y::SIUnit) = (tup(x) == tup(y))
   *(x::SIUnit,y::SIUnit) = tup2u(tup(x)+tup(y))

  function ^{m,kg,s,A,K,mol,cd,rad,sr}(x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr},i::Integer)
      return SIUnit{m*i,kg*i,s*i,A*i,K*i,mol*i,cd*i,rad*i,sr*i}()
  end

  export SIPrefix, Meter, KiloGram, Second, Ampere, Kelvin, Mole, Candela, Radian, Steradian
  # Definition of the SI base units:
  const SIPrefix   = SIUnit{0,0,0,0,0,0,0,0,0}()
  const Meter      = SIUnit{1,0,0,0,0,0,0,0,0}()
  const KiloGram   = SIUnit{0,1,0,0,0,0,0,0,0}()
  const Second     = SIUnit{0,0,1,0,0,0,0,0,0}()
  const Ampere     = SIUnit{0,0,0,1,0,0,0,0,0}()
  const Kelvin     = SIUnit{0,0,0,0,1,0,0,0,0}()
  const Mole       = SIUnit{0,0,0,0,0,1,0,0,0}()
  const Candela    = SIUnit{0,0,0,0,0,0,1,0,0}()
  const Radian     = SIUnit{0,0,0,0,0,0,0,1,0}()
  const Steradian  = SIUnit{0,0,0,0,0,0,0,0,1}()

  export Joule, Coulomb, Volt, Farad, Newton, Ohm, Hertz, Siemens, Watt, Pascal
  # Definition of the SI derived units:
  const Joule      = KiloGram*Meter^2/Second^2
  const Coulomb    = Ampere*Second
  const Volt       = Joule/Coulomb
  const Farad      = Coulomb^2/Joule
  const Newton     = KiloGram*Meter/Second^2
  const Ohm        = Volt/Ampere
  const Hertz      = inv(Second)
  const Siemens    = inv(Ohm)
  const Watt       = Joule/Second
  const Pascal     = Newton/Meter^2

  # Pretty Printing - Text

  # This is an auxiliary function to be used in the show() function.
  # This function applies the function defined in the do-block to each
  # element of the content of the string representation of "i".
  # (http://docs.julialang.org/en/release-0.4/stdlib/strings/#Base.repr)
  # (http://www.juliabloggers.com/using-blocks-in-julia/)
  superscript(i) = map(repr(i)) do c
     c   ==  '-' ? '\u207b' :
     c   ==  '1' ? '\u00b9' :
     c   ==  '2' ? '\u00b2' :
     c   ==  '3' ? '\u00b3' :
     c   ==  '4' ? '\u2074' :
     c   ==  '5' ? '\u2075' :
     c   ==  '6' ? '\u2076' :
     c   ==  '7' ? '\u2077' :
     c   ==  '8' ? '\u2078' :
     c   ==  '9' ? '\u2079' :
     c   ==  '0' ? '\u2070' :
     error("Unexpected Chatacter")
  end

  # This is an auxiliary function to be used in the show() function.
  # Only print a space if there are nonzero units coming after this one
  function spacing(idx::Int, x::SIUnit)
     # ntuple(f::Function, n): Create a tuple of length n, computing each element as f(i), where i is the index of the element.
     unitTuple = tup(x)
     (unitTuple[idx+1:end] == ntuple((i)->0, length(unitTuple)-idx)) ? "" : " "
  end

  macro generateshowcode(unittup...)
      evaluationstring = ASCIIString[]

      push!(evaluationstring, "begin")
      for (index,unit) in enumerate(unittup[1:end-1])
          codeline = "$unit != 0 && print(io, \"$unit\", ($unit == 1 ? spacing($index,x) : superscript($unit)))"
          push!(evaluationstring, codeline)
      end
      push!(evaluationstring, "$(unittup[end]) != 0 && print(io, \"$(unittup[end])\", ($(unittup[end]) == 1 ? \"\" : superscript($(unittup[end]))))")
      push!(evaluationstring, "end")

      return parse(join(evaluationstring, "\n"))

  end

  # This function shows (i.e. prints) the units using the SI unit symbol and unicode
  # characters for the superscript.
  function show{m,kg,s,A,K,mol,cd,rad,sr}(io::IO,x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr})

    # The following code is generated by the macro under:
    #  m   != 0 && print(io, "m"  , (m   == 1 ? spacing(1,x) : superscript(m  )))
    #  kg  != 0 && print(io, "kg" , (kg  == 1 ? spacing(2,x) : superscript(kg )))
    #  s   != 0 && print(io, "s"  , (s   == 1 ? spacing(3,x) : superscript(s  )))
    #  A   != 0 && print(io, "A"  , (A   == 1 ? spacing(4,x) : superscript(A  )))
    #  K   != 0 && print(io, "K"  , (K   == 1 ? spacing(5,x) : superscript(K  )))
    #  mol != 0 && print(io, "mol", (mol == 1 ? spacing(6,x) : superscript(mol)))
    #  cd  != 0 && print(io, "cd" , (cd  == 1 ? spacing(7,x) : superscript(cd )))
    #  rad != 0 && print(io, "rad", (rad == 1 ? spacing(8,x) : superscript(rad)))
    #  sr  != 0 && print(io, "sr" , (sr  == 1 ? ""           : superscript(sr )))

     @generateshowcode(m,kg,s,A,K,mol,cd,rad,sr)
     return nothing
  end

  # Pretty Printing - LaTeX
  using TexExtensions

  import Base: writemime

  # The template code line that needs to be "copied" 9 times is:
  #   paramName != 0 && push!(paramName>0?num:den,string("\\text{",paramNameString,"}",abs(paramName) == 1 ? " " : string("^{",abs(paramName),"}")))
  # For example: paramName = m; paramNameString = "m"
  #   m != 0 && push!(m >0?num:den,string("\\text{","m","}",abs(m) == 1 ? " " : string("^{",abs(m),"}")))
  macro generatenumanddencode(unittup...)
      evaluationstring = ASCIIString[]

      push!(evaluationstring, "begin")
      for unit in unittup
          codeline = "$unit != 0 && push!($unit>0?num:den,string(\"\\\\text{$unit}\",abs($unit) == 1 ? \"\" : string(\"^{\",abs($unit),\"}\")))"
          push!(evaluationstring, codeline)
      end
      push!(evaluationstring, "end")

      return parse(join(evaluationstring, "\n"))
  end

  # This function creates the LaTeX string corresponding to the SIUnit
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

  function Base.Multimedia.writemime{m,kg,s,A,K,mol,cd,rad,sr}(io::IO,::MIME"text/mathtex+latex",x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr})
      write(io, latexstring(x))
  end

end #module

#Original code that was removed:

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

  # # This function does the same as tup(). May it be removed?
  # function sidims{m,kg,s,A,K,mol,cd,rad,sr}(::SIUnit{m,kg,s,A,K,mol,cd,rad,sr})
  #     return (m,kg,s,A,K,mol,cd,rad,sr)
  # end
  #
  # export @prettyshow
  #
  # macro prettyshow(unit,string)
  #     # Reminder: esc() escapes the expression that is passed as argument.
  #     # Reminder: quote() is used for building expressions.
  #     esc(quote function Base.show(io::IO,::SIBaseUnits.SIUnit{SIBaseUnits.sidims($(unit))...})
  #                   print(io,$(string))
  #               end
  #               function Base.Multimedia.writemime(io::IO,::MIME"text/mathtex+latex",::SIBaseUnits.SIUnit{SIBaseUnits.sidims($(unit))...})
  #                   Base.Multimedia.writemime(io,MIME("text/mathtex+latex"),$(string))
  #               end
  #         end)
  # end
