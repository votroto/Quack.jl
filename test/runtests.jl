using Test

@testset "everything" begin
    @testset "init" begin
        include("test_init.jl")
    end

    @testset "oracle" begin
        include("test_oracle.jl")
    end

    @testset "equilibrium" begin
        include("test_subgame.jl")
    end
end