isdefined(Base, :__precompile__) && __precompile__()

module SIQuantities

  using SIBaseUnits

  export SIQuantity

  immutable SIQuantity{T<:Number,m,kg,s,A,K,mol,cd,rad,sr} <: Number
      val::T
  end

  # Unitless (i.e. scalar) quantities are aliased as ScalarQuantity
  typealias ScalarQuantity{T} SIQuantity{T,0,0,0,0,0,0,0,0,0}

  SIQuantity{T<:Number}(x::T) = ScalarQuantity{T}(x)

  import Base: show
  function show{T,m,kg,s,A,K,mol,cd,rad,sr}(io::IO,x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
      show(io,x.val)
      print(io," ")
      show(io,unit(x))
  end

  # The function "unit()" returns the SIUnit of a SIQuantity.
  unit{T,m,kg,s,A,K,mol,cd,rad,sr}(::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}) = SIUnit{m,kg,s,A,K,mol,cd,rad,sr}()

  export siquantity, @siquantity

  # The following method of the function "siquantity()" converts a DataType SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr} into a SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}
  # To avoid losing data this is only allowed if the siquantity is 1.
  # The function declaration takes advantage of:
  # julia> isa(SIQuantity{Float64,0,0,0,0,0,0,0,0,0}(1), SIQuantities.SIQuantity{Float64})
  # true
  # julia> isa(SIQuantity{Float64,1,2,3,4,5,6,7,8,9}(1), SIQuantities.SIQuantity{Float64})
  # true
  # See: http://docs.julialang.org/en/release-0.4/manual/types/#vararg-tuple-types
  function siquantity{S}(T,quant::SIQuantity{S})
      quant.val == one(S) || error("Quantity value must be unity!")
      siquantity(T,unit(quant))
  end
  # The following method of the function "siquantity(T,SIUnit{})" receives a DataType SIUnit{} and returns the corresponding DataType SIQuanity{T,SIUnit}
  siquantity{m,kg,s,A,K,mol,cd,rad,sr}(T::TypeVar,::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}

  # The follwoing methods of the function "tup()" extract the UnitTuple of a SIQuantity{}
  tup{T,m,kg,s,A,K,mol,cd,rad,sr}(::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}) = (m,kg,s,A,K,mol,cd,rad,sr)

  # The following macro creates a SIQuantity from a TypeVar T and a SIUnit
  # julia> unit = SIUnit{100,4,3,2,1,-1,-2,-3,-4}()
  # julia> @siquantity(Float64, unit)
  # SIQuantities.SIQuantity{Float64,100,4,3,2,1,-1,-2,-3,-4}
  macro siquantity(expr,unit)
      esc(:(SIQuantities.SIQuantity{$expr,SIBaseUnits.tup($unit)...}))
  end

  ##############################################################################
  ###################### Promotion and conversion ##############################
  ##############################################################################
  import Base: promote_rule, promote_type, convert
  # SIUnits:
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
  # To fix, define:
  #     promote_rule(Type{Base.Irrational{#s<:Any}}, Type{Main.SIUnit{#m<:Any, #kg<:Any, #s<:Any, #A<:Any, #K<:Any, #mol<:Any, #cd<:Any, #rad<:Any, #sr<:Any}})
  # before the new definition.
  #
  # Therefore:
  promote_rule{sym      ,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Irrational{sym}},y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{Irrational{sym},m,kg,s,A,K,mol,cd,rad,sr}
  promote_rule{          m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Bool           },y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{Bool           ,m,kg,s,A,K,mol,cd,rad,sr}
  promote_rule{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{T              },y::Type{SIUnit{m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{T              ,m,kg,s,A,K,mol,cd,rad,sr}
  ## The promotion rules need to be supported by the appropriate conversion methods:
  convert{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}},val::Number                          ) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(convert(T,  val))
  convert{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T                         }},  x::SIUnit{m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(    one(T)      )
  convert{T<:Number                         }(::Type{SIQuantity{T                         }},  x::T                               ) = ScalarQuantity{T}(x)
  convert{T<:Number,S<:Number               }(::Type{SIQuantity{T                         }},  x::S                               ) = convert(ScalarQuantity{T},convert(T,x))

  # SIQuantity:
  ## Promotions for operations between a basic type and a SIQuantity:
  promote_rule{sym,T      ,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Irrational{sym}},y::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(Irrational{sym},T),m,kg,s,A,K,mol,cd,rad,sr}
  promote_rule{          S,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{Bool           },y::Type{SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(           Bool,S),m,kg,s,A,K,mol,cd,rad,sr}
  promote_rule{T<:Number,S,m,kg,s,A,K,mol,cd,rad,sr}(x::Type{T              },y::Type{SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{promote_type(              T,S),m,kg,s,A,K,mol,cd,rad,sr}
  ## Promotions for operations between two SIQuantities:
  ## (Note: It is to be noticed that as the units of the result depend on the operation then it makes no sense to keep the units and instead both operands are propomoted to a scalar.)
  promote_rule{T,S,m ,kg ,s ,A ,K ,mol ,cd ,rad ,sr                                   }(x::Type{SIQuantity{T                                  }},y::Type{SIQuantity{S,m ,kg ,s ,A ,K ,mol ,cd ,rad ,sr }}) = SIQuantity{promote_type(T,S)}
  promote_rule{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(A::Type{SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}},B::Type{SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS}}) = SIQuantity{promote_type(T,S)}
  promote_rule{T,  mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(A::Type{SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}},B::Type{SIUnit{      mS,kgS,sS,AS,KS,molS,cdS,radS,srS}}) = SIQuantity{T}
  # Unlike most other types, the promotion of two identitical SIQuantities is
  # not that type itself. As such, the promote_type behavior itself must be
  # overridden by overloading the method. C.f. https://github.com/Keno/SIUnits.jl/issues/27
  promote_type{T,m,kg,s,A,K,mol,cd,rad,sr}( ::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}, ::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = SIQuantity{T}
  ## The promotion rules need to be supported by the appropriate conversion methods:
  convert{T<:Number,S,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T}},x::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr}) = SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(convert(T,x.val))
  convert{T<:Number                           }(::Type{SIQuantity{T}},x::SIQuantity{T}                         ) = x

  function convert{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(::Type{SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}},val::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      if mS != mT || kgS != kgT || sS != sT || AS != AT || KS != KT || molS != molT || cdS != cdT || radS != radT || srS != srT
          error("Dimension mismatch in convert. Attempted to convert a ($(repr(SIUnit{mS,kgS,sS,AS,KS,molS,cdS,radS,srS}))) to ($(repr(SIUnit{mT,kgT,sT,AT,KT,molT,cdT,radT,srT})))")
      end
      SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(convert(T,val.val))
  end

  ##############################################################################
  ################################## Operators #################################
  ##############################################################################
  import Base: ==, +, -, *, /, //, ^ #.+, .-, .*, ./
  import Base: sqrt, abs, isless, isfinite, isreal, real, imag, isnan, float64, float, int, mod, one, zero, conj, inv #length, getindex, next, start, step, last, done, first, eltype,

  for op in (:/,://)

      @eval function ($op){T}(x::Number,y::SIQuantity{T})
          val = ($op)(x,y.val)
          unitTuple = -tup(y)
          return SIQuantity{typeof(val),unitTuple...}(val)
      end

      @eval function ($op)(x::SIQuantity,y::SIQuantity)
          val = $(op)(x.val,y.val)
          unitTuple = tup(x)-tup(y)
          return SIQuantity{typeof(val),unitTuple...}(val)
      end

      @eval $(op){T}(x::SIQuantity{T},y::SIUnit       ) = SIQuantity{T,( tup(unit(x))-tup(y))...}(         x.val)
      @eval $(op){T}(y::SIUnit       ,x::SIQuantity{T}) = SIQuantity{T,(-tup(unit(x))+tup(y))...}(($op)(1,x.val))

      # There is no need to define (:*,:/,://) between x::Number and y::Union{SIUnit,SIQuantity} because x is promoted to SIQuantity{typeof(x),0,0,0,0,0,0,0,0,0}(x) and then the defined methods apply.
      #@eval $(op)(x::Number,y::SIUnit) = SIQuantity{typeof(x),-(tup(y))...}(        x )
      #@eval $(op)(y::SIUnit,x::Number) = SIQuantity{typeof(x), (tup(y))...}(($op)(1,x))

  end

  function +{T,S,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},y::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr})
      val = x.val+y.val
      return SIQuantity{typeof(val),m,kg,s,A,K,mol,cd,rad,sr}(val)
  end

  # The following method will only be called when the above method cannot be called because the units of the operands are different.
  function +{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(x::SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT},y::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      error("Unit mismatch. Got ($(repr(unit(x)))) + ($(repr(unit(y))))")
  end

  function -{T,S,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},y::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr})
      val = x.val-y.val
      return SIQuantity{typeof(val),m,kg,s,A,K,mol,cd,rad,sr}(val)
  end

  # The following method will only be called when the above method cannot be called because the units of the operands are different.
  function -{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(x::SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT},y::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      error("Unit mismatch. Got ($(repr(unit(x)))) - ($(repr(unit(y))))")
  end

  function -{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
      val = -(x.val)
      return SIQuantity{typeof(val),m,kg,s,A,K,mol,cd,rad,sr}(val)
  end

  function ^{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},i::Integer)
      # if i == 0
      #     return one(T)
      # end
      val = x.val^i
      return SIQuantity{typeof(val),m*i,kg*i,s*i,A*i,K*i,mol*i,cd*i,rad*i,sr*i}(val)
  end

  function ^{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},r::Rational)
      # if r == 0
      #     return one(T)
      # end
      val = x.val^r
      return SIQuantity{typeof(val),convert(Int,m*r),convert(Int,kg*r),convert(Int,s*r),convert(Int,A*r),convert(Int,K*r),convert(Int,mol*r),convert(Int,cd*r),convert(Int,rad*r),convert(Int,sr*r)}(val)
  end

  ^{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},r::AbstractFloat) = x^rationalize(r)

  # The following method will only be called when the above method cannot be called because the units of the operands are different.
  function ^{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(x::SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT},y::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      error("Can not raise a number to a unitful quantity. Got ($(repr(unit(x))))^($(repr(unit(y))))")
  end

  ^{T,S,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},y::SIQuantity{S,0,0,0,0,0,0,0,0}) = x^(y.val)

  ==(   x::SIQuantity   ,y::SIQuantity   ) = (tup(x) == tup(y)) && (x.val  == y.val )
  =={T}(x::SIQuantity{T},y::SIUnit       ) = (tup(x) == tup(y)) && (x.val  == one(T))
  =={T}(x::SIUnit       ,y::SIQuantity{T}) = (tup(x) == tup(y)) && (one(T) == y.val )

  function sqrt{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
      val = sqrt(x.val)
      return SIQuantity{typeof(val),convert(Int,m/2),convert(Int,kg/2),convert(Int,s/2),convert(Int,A/2), convert(Int,K/2),convert(Int,mol/2),convert(Int,cd/2),convert(Int,rad/2),convert(Int,rad/2)}(val)
  end

  function abs{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
      return SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(abs(x.val))
  end

  function inv{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
      val = inv(x.val)
      return SIQuantity{typeof(val),-m,-kg,-s,-A,-K,-mol,-cd,-rad,-sr}(val)
  end

  # function isfinite{T,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr})
  #     isfinite(x.val)
  # end

  isfinite(x::SIQuantity) = isfinite(x.val)
     isnan(x::SIQuantity) = isnan(x.val)
    isreal(x::SIQuantity) = isreal(x.val)
      real(x::SIQuantity) = typeof(x)(real(x.val))
      imag(x::SIQuantity) = typeof(x)(imag(x.val))

  #The following methods are specific cases of the general case below.
  # function isless{T}(x::SIQuantity{T,0,0,0,0,0,0,0,0,0}, y::SIQuantity{T,0,0,0,0,0,0,0,0,0})
  #     return isless(x.val,y.val)
  # end
  # function isless{T,S}(x::SIQuantity{T,0,0,0,0,0,0,0,0,0}, y::SIQuantity{S,0,0,0,0,0,0,0,0,0})
  #     return isless(x.val,y.val)
  # end
  #General case:
  function isless{T,S,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},y::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr})
      return isless(x.val,y.val)
  end
  function isless{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(x::SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT},y::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      error("Unit mismatch. Got isless($(repr(unit(x))),$(repr(unit(y))))")
  end
  # The following methods are not necessary as the y::Real will be promoted to SIQuantity{typeof(y),0,0,0,0,0,0,0,0,0}(y)
  # function isless{T}(x::SIQuantity{T,0,0,0,0,0,0,0,0,0}, y::Real)
  #     return isless(x.val,y)
  # end
  # function isless{T}(x::Real, y::SIQuantity{T,0,0,0,0,0,0,0,0,0})
  #     return isless(x,y.val)
  # end

  function mod{T,S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS,mT,kgT,sT,AT,KT,molT,cdT,radT,srT}(x::SIQuantity{T,mT,kgT,sT,AT,KT,molT,cdT,radT,srT},y::SIQuantity{S,mS,kgS,sS,AS,KS,molS,cdS,radS,srS})
      error("Unit mismatch. Got mod($(repr(unit(x))),$(repr(unit(y))))")
  end

  function mod{T,S,m,kg,s,A,K,mol,cd,rad,sr}(x::SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},y::SIQuantity{S,m,kg,s,A,K,mol,cd,rad,sr})
      val = mod(x.val,y.val)
      return SIQuantity{typeof(val),m,kg,s,A,K,mol,cd,rad,sr}(val)
  end

  import Base: sin, cos, tan, cot, sec, csc
  for func in (:sin,:cos,:tan,:cot,:sec,:csc)
      @eval $func{T}(θ::SIQuantity{T,0,0,0,0,0,0,0,1,0}) = $func(θ.val)
  end

  # Forwarding methods that do not affect units
  conj(x::SIQuantity) = typeof(x)(conj(x.val))

  float64(x::SIQuantity) = float64(x.val)
    float(x::SIQuantity) =   float(x.val)
      int(x::SIQuantity) =     int(x.val)

  to_q{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}},val::T     ) = (0 == m == kg == s == A == K == mol == cd == rad == sr) ? val : SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}(val)

  *{T}(x::SIUnit       ,y::SIQuantity{T}) = SIQuantity{T        ,(tup(x)+tup(y))...}(y.val)
  *{T}(y::SIQuantity{T},x::SIUnit       ) = SIQuantity{T        ,(tup(x)+tup(y))...}(y.val)
  *(   x::Irrational   ,y::SIUnit       ) = siquantity(typeof(x),y)(x)
  function *(x::SIQuantity,y::SIQuantity)
      val = x.val * y.val
      return SIQuantity{typeof(val),(tup(x)+tup(y))...}(val)
  end

  # The following method takes advantage of the fact:
  # julia> isa(SIQuantity{Float64,0,0,0,0,0,0,0,0,0}(1), SIQuantities.SIQuantity)
  # true
  # julia> isa(SIQuantity{Float64,1,2,3,4,5,6,7,8,9}(1), SIQuantities.SIQuantity)
  # true
  # For example it is called with:
  # julia> one(SIQuantity{Float64,1,2,3,4,5,6,7,8,9}(100))
  one(x::SIQuantity) = one(x.val)
  # This second method works in the same way, but is called with the DataType
  # For example it is called with:
  # julia> one(SIQuantity{Float64,1,2,3,4,5,6,7,8,9})
  one{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = one(T)
  # This first method works over quantities of type SIQuantity
  zero(x::SIQuantity) = zero(x.val) * unit(x)
  # This second method works over the DataType SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}
  zero{T,m,kg,s,A,K,mol,cd,rad,sr}(::Type{SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}}) = zero(T) * SIUnit{m,kg,s,A,K,mol,cd,rad,sr}()

  # export SIPrefix, Meter, KiloGram, Second, Ampere, Kelvin, Mole, Candela, Radian, Steradian,
  #        Yocto, Zepto, Atto, Femto, Pico, Nano, Micro, Milli, Centi, Deci,
  #        Deca, Hecto, Kilo, Mega, Giga, Tera, Peta, Exa, Zetta, Yotta,
  #        Joule, Coulomb, Volt, Farad, Newton, Ohm,  Siemens, Hertz, Watt, Pascal,
  #        Gram, CentiMeter
  #
  # # Definition of the SI prefixes:
  # const Yocto      = (1//10^24)SIPrefix
  # const Zepto      = (1//10^21)SIPrefix
  # const Atto       = (1//10^18)SIPrefix
  # const Femto      = (1//10^15)SIPrefix
  # const Pico       = (1//10^12)SIPrefix
  # const Nano       = (1//10^09)SIPrefix
  # const Micro      = (1//10^06)SIPrefix
  # const Milli      = (1//10^03)SIPrefix
  # const Centi      = (1//10^02)SIPrefix
  # const Deci       = (1//10^01)SIPrefix
  # const Deca       = (   10^01)SIPrefix
  # const Hecto      = (   10^02)SIPrefix
  # const Kilo       = (   10^03)SIPrefix
  # const Mega       = (   10^06)SIPrefix
  # const Giga       = (   10^09)SIPrefix
  # const Tera       = (   10^12)SIPrefix
  # const Peta       = (   10^15)SIPrefix
  # const Exa        = (   10^18)SIPrefix
  # const Zetta      = (   10^21)SIPrefix
  # const Yotta      = (   10^24)SIPrefix
  #
  # # Definition of commonly used units for convenience:
  # const CentiMeter = Centi*Meter
  # const Gram       = (1//1000)KiloGram

end # module
