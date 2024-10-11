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

#open("/tmp/prog.txt", "w") do file
    n=5
            A = rand(-100:100, n,n,n) .// rand(1:100, n,n,n) #,n,n)
            B = rand(-100:100, n,n,n) .// rand(1:100, n,n,n) #,n,n)
            C = rand(-100:100, n,n,n) .// rand(1:100, n,n,n) #,n,n)
            #D = randn(n,n,n,n,n)
            #E = randn(n,n,n,n,n)
            payoffs = (A,B,C)#,D,E)

            v,x,t = nash_equilibrium(payoffs)
            #println(file, n, "\t",t)
#        end
#        flush(file)
#    end
#end

import Symbolics
..
#=
Symbolics.@variables A[1:3,1:3,1:3]
Symbolics.@variables B[1:3,1:3,1:3]
Symbolics.@variables C[1:3,1:3,1:3]
payoffs = (Symbolics.scalarize(A),Symbolics.scalarize(B),Symbolics.scalarize(C))
=#
Symbolics.@variables X[1:n]
Symbolics.@variables Y[1:n]
Symbolics.@variables Z[1:n]
#Symbolics.@variables U[1:5]
#Symbolics.@variables V[1:5]
Symbolics.@variables P[1:3]

x = [Symbolics.scalarize(X), Symbolics.scalarize(Y), Symbolics.scalarize(Z)] #, Symbolics.scalarize(U), Symbolics.scalarize(V)]
p = Symbolics.scalarize(P)
players = eachindex(payoffs)
actions = axes(first(payoffs))

brfs = unilateral_payoffs(Num, payoffs, x)
brfsX = [dot(brfs[i], x[i]) for i in players]

open("/tmp/prog.txt", "w") do file
    println(file, "set IDS;")
    println(file, "set PLS;")
    println(file, "var X{IDS} >= 0, <= 1;")
    println(file, "var Y{IDS} >= 0, <= 1;")
    println(file, "var Z{IDS} >= 0, <= 1;")
    #println(file, "var U{IDS} >= 0, <= 1;")
    #println(file, "var V{IDS} >= 0, <= 1;")
    println(file, "var P{PLS};")

    println(file, "minimize Objective: 0;")

    for i = players 
        for bi in eachindex(brfs[i])
            b = brfs[i][bi]
            println(file, "s.t. B$i$bi: ", b - p[i], " <= 0;")
        end
        println(file)
    end
    println(file, "s.t. BB: ", sum(brfsX) - sum(p), " >= 0;")
    for i = players
        println(file, "s.t. S$i: ", sum(x[i]) - 1, " = 0;")
    end
    println(file, "data;")
    println(file, "set IDS := 1 2 3 4 5 6 7 8 9 10;")
    println(file, "set PLS := 1 2 3;")
end

#=
open("/tmp/con.ms", "w") do file
    println(file, "set IDS;")
    println(file, "set PLS;")
    println(file, "var X{IDS} >= 0, <= 1;")
    println(file, "var Y{IDS} >= 0, <= 1;")
    println(file, "var Z{IDS} >= 0, <= 1;")
    #println(file, "var U{IDS} >= 0, <= 1;")
    #println(file, "var V{IDS} >= 0, <= 1;")
    println(file, "var P{PLS};")

    println(file, "minimize Objective: 0;")

    for i = players 
        for bi in eachindex(brfs[i])
            b = brfs[i][bi]
            println(file, "s.t. B$i$bi: ", b - p[i], " <= 0;")
        end
        println(file)
    end
    println(file, "s.t. BB: ", sum(brfsX) - sum(p), " >= 0;")
    for i = players
        println(file, "s.t. S$i: ", sum(x[i]) - 1, " = 0;")
    end
    println(file, "data;")
    println(file, "set IDS := 1 2 3 4 5 6 7 8 9 10;")
    println(file, "set PLS := 1 2 3;")
end
=#