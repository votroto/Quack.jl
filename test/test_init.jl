using Quack: interior_init
using Symbolics: @variables, scalarize, ≲
using LinearAlgebra: norm

@testset "point on line" begin
    center = ax = randn()

    @variables x
    variables = ([x],)
    domain = ([(x[1] - ax)^2 ≲ 1],)

    actual_pt, = interior_init(domain; variables)

    direction_norm = norm([center] - first(actual_pt))
    @test direction_norm <= 1
end

@testset "point in disc" begin
    center = ax, ay = randn(2)

    @variables x[1:2]
    variables = (scalarize(x),)
    domain = ([(x[1] - ax)^2 + (x[2] - ay)^2 ≲ 1],)

    actual_pt = interior_init(domain; variables)

    direction_norm = norm(center - actual_pt[1][1])
    @test direction_norm <= 1
end

@testset "point in square" begin
    center = ax, ay = randn(2)

    @variables x[1:2]
    variables = (scalarize(x),)
    domain = ([(x[1] - ax)^2 ≲ 1, (x[2] - ay)^2 ≲ 1],)

    actual_pt = interior_init(domain; variables)

    direction_norm = norm(center - actual_pt[1][1], Inf)
    @test direction_norm <= 1
end