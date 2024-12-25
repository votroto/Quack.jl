using Quack: until_eps, fixed_iters, quack_oracle
using Test

@testset "guessing" begin
    p1(x, y) = (x - y)^2
    p2(x, y) = -(x - y)^2

    d1(x) = -x^2 + 1
    d2(y) = -y^2 + 1

    quack = quack_oracle((p1, p2), (d1, d2))
    (actions, mixed, values, best) = fixed_iters(quack, 5)

    expected_values = [1, -1]
    @test expected_values ≈ collect(values) atol = 1e-3
end

@testset "Stein Ozdaglar Parillo 2008 Ex. 2.3" begin
    p1(x, y) = -3 * x^2 * y^2 - 2 * x^3 + 3 * y^3 + 2 * x * y - x
    p2(x, y) = 2 * x^2 * y^2 + x^2 * y − 4 * y^3 − x^2 + 4 * y

    d1(x) = -x^2 + 1
    d2(y) = -y^2 + 1

    quack = quack_oracle((p1, p2), (d1, d2))
    cnt, (actions, mixed, values, best) = until_eps(quack, 1e-3)

    expected = [1.13, 1.81]
    @test isapprox(collect(values), expected; atol=1e-1)
end


@testset "Torus" begin
    phi = (0, π/8)
    alp = (1, 1.5)

    p1(x, y) = alp[1] * cos(x − phi[1]) - cos(x - y)
    p2(x, y) = alp[2] * cos(y − phi[2]) - cos(y - x)

    dom1(x) = -x^2 + π^2
    dom2(y) = -y^2 + π^2

    quack = quack_oracle((p1, p2), (dom1, dom2))
    iters, (actions, weights, vals, subopt) = until_eps(quack, 1e-3)
end


