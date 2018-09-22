f1{T}(x::T, t::Type{T}) = x, T, t
f2{T}(x::T, t::Type   ) = x, T, t
f3{T}(x::T, t::DataType   ) = x, T, t

isa(Float64, Type)
isa(DataType, Type)
isa(Float64, DataType)
isa(8.0, Float64)

# Important !!! :
isa(Int64, Type{Int64})
isa(Float64, Float64)
is (Float64, Float64)
isa(8.0, Type{Float64})
