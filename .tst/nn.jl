include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle.jl")
include("../src/multilinear_matrix_nash.jl")
include("../src/equilibrium.jl")

__init__()

using Revise
using Symbolics: @variables
using Test

#=
@testset "prisoner" begin
    p1 = -[1 5; 0 3]
    p2 = -[1 0; 5 3]

    values, (s1, s2) = nash_equilibrium((p1, p2))

    @test collect(values) ≈ [-3; -3] atol = 1e-3
    @test collect(s1) ≈ [0; 1] atol = 1e-3
    @test collect(s2) ≈ [0; 1] atol = 1e-3
end

@testset "3x3 guess" begin
    guess = [0 1 4; 1 0 1; 4 1 0]

    values, (s1, s2) = nash_equilibrium((guess, -guess))

    expected_values = [1, -1]
    expected_min = [0.25, 0.0, 0.25]
    expected_max = [0.75, 1.0, 0.75]
    expected_s2 = [0.0, 1.0, 0.0]
    
    clamped_s1 = clamp.(s1, expected_min, expected_max)
    @test isapprox(collect(values), expected_values, atol=1e-3)
    @test isapprox(sum(s1), 1, atol=1e-3)
    @test (isapprox(s1, clamped_s1, atol=1e-3))
    @test isapprox(s2, expected_s2, atol=1e-3)
end
=#
using Random
Random.seed!(1928)

open("/tmp/rand1.txt", "w") do file
    
    for n in 2:10
       for i in 1:10
            A = randn(n,n,n)
            B = randn(n,n,n)
            C = randn(n,n,n)
            payoffs = (A,B,C)

            v,x,t = nash_equilibrium((A,B,C))
            println(file, n, "\t",t)
        end
        flush(file)
    end
end

#=
import Symbolics

Symbolics.@variables A[1:3,1:3,1:3]
Symbolics.@variables B[1:3,1:3,1:3]
Symbolics.@variables C[1:3,1:3,1:3]
payoffs = (Symbolics.scalarize(A),Symbolics.scalarize(B),Symbolics.scalarize(C))

Symbolics.@variables X[1:3]
Symbolics.@variables Y[1:3]
Symbolics.@variables Z[1:3]
Symbolics.@variables P[1:3]

x = [Symbolics.scalarize(X), Symbolics.scalarize(Y), Symbolics.scalarize(Z)]
p = Symbolics.scalarize(P)
players = eachindex(payoffs)
actions = axes(first(payoffs))

brfs = unilateral_payoffs(payoffs, x)
brfsX = [dot(brfs[i], x[i]) for i in players]

for i = players 
    for b in brfs[i]
        println(b ≲ p[i])
    end
    println()
end
println(sum(brfsX) ≳ sum(p))
println.([sum(x[i]) ~ 1 for i = players] )
=#