using Test

@testset "everything" begin
    @testset "e2e" begin
        include("test_e2e.jl")
    end
end