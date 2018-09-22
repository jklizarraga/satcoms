isdefined(Base, :__precompile__) && __precompile__()

module SIUnits

  include("SIUnit.jl")
  include("SIQuantity.jl")
  include("SIRange.jl")

end
