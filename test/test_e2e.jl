using Quack: fixed_iters, quack_oracle
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
