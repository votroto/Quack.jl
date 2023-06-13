using Test

@testset "init" begin
    include("test_init.jl")
end

@testset "oracle" begin
    include("test_oracle.jl")
end