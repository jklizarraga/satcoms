module Units

# export SIQuanity, SIBaseUnit, scalar

abstract type Unit                      end

abstract type Length            <: Unit end
abstract type Mass              <: Unit end
abstract type Time              <: Unit end
abstract type ElectricalCurrent <: Unit end
abstract type Temperature       <: Unit end
abstract type AmountOfSubstance <: Unit end
abstract type LuminousIntensity <: Unit end


include("Angles.jl")
include("SIBaseUnits.jl")
include("SIQuantities.jl")

end # module
