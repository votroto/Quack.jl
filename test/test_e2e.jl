using Quack: until_eps, fixed_iters, quack_oracle
using Symbolics
using Test

@testset "guessing" begin
    @variables x y

    pays = ((x-y)^2, -(x-y)^2)
    doms = ((x^2 ≲ 1,), (y^2 ≲ 1,))
    vars = ((x,), (y,))

    quack = quack_oracle(pays, doms; variables=vars)
    (actions, mixed, values, best) = fixed_iters(quack, 5)

    expected_values = [1, -1]
    @test expected_values ≈ collect(values) atol = 1e-5
end

@testset "Stein Ozdaglar Parillo 2008 Ex. 2.3" begin
    @variables x y

    u1 = -3*x^2*y^2 - 2*x^3 + 3*y^3 + 2*x * y - x
    u2 = 2*x^2*y^2 + x^2*y − 4*y^3 − x^2 + 4*y

    pays = (u1, u2)
    doms = ((x^2 ≲ 1,), (y^2 ≲ 1,))
    vars = ((x,), (y,))

    quack = quack_oracle(pays, doms; variables=vars)
    cnt, (actions, mixed, values, best) = until_eps(quack, 1e-3)

    expected = [1.13, 1.81]
    @test isapprox(collect(values), expected; atol = 1e-1)
end