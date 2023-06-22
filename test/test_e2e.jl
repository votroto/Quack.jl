using Quack: until_eps, fixed_iters, quack_oracle
using Symbolics
using Test

@testset "guessing" begin
    @variables x y

    pays = ((x-y)^2, -(x-y)^2)
    doms = [x^2 ≲ 1, y^2 ≲ 1]
    vars = [(x,), (y,)]

    quack = quack_oracle(pays, doms; variables=vars)
    (actions, mixed, values, best) = fixed_iters(quack, 5)

    expected_values = [1, -1]
    @test expected_values ≈ values atol = 1e-5
end

@testset "Chasnov2019" begin
    @variables θ[1:2]
    α = [1, 1.5]
    ϕ = [0, π/8]

    p1 = α[1] * cos(θ[1] - ϕ[1]) - cos(θ[1] - θ[2])
    p2 = α[2] * cos(θ[2] - ϕ[2]) - cos(θ[2] - θ[1])

    pays = (p1, p2)
    doms = [θ[1]^2 ≲ π^2, θ[2]^2 ≲ π^2]
    vars = [(θ[1],), (θ[2],)]

    quack = quack_oracle(pays, doms; variables=vars)
    cnt, (actions, mixed, values, best) = until_eps(quack, 1e-3)
    pure = [actions[1][findmax(mixed[1])[2]], actions[2][findmax(mixed[2])[2]]]
    
    expected_ne = [[-1.063, 1.014], [1.408, -0.325]]
    expected_pay = [[0.324, 1.291], [0.971, 1.705]]

    @test (isapprox(pure, expected_ne[1]; atol = 1e-1)
        || isapprox(pure, expected_ne[2]; atol = 1e-1))
    @test (isapprox(values, expected_pay[1]; atol = 1e-1)
        || isapprox(values, expected_pay[2]; atol = 1e-1))
end