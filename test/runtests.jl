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

    @testset "nash" begin
        include("test_nash.jl")
    end

    @testset "e2e" begin
        include("test_e2e.jl")
    end
end