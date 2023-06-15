using Quack: oracle
using Symbolics: @variables, scalarize, ≲
using LinearAlgebra: norm

function closest_point_in_disc(center, point)
    direction = point - center
    direction_norm = norm(direction)
    norm_direction = direction / direction_norm
    closest = center + norm_direction

    (direction_norm <= 1) ? point : closest
end

function closest_point_in_square(center, point)
    direction = point - center
    direction_norm = norm(direction, Inf)
    clamped_direction = clamp.(direction, -1, 1)
    closest = center + clamped_direction

    (direction_norm <= 1) ? point : closest
end

@testset "minimize parabola over disc" begin
    point = ax, ay = randn(2)
    center = bx, by = randn(2)

    @variables x y
    variables = scalarize((x, y))
    cost = ((x - ax)^2 + (y - ay)^2)
    domain = [(x - bx)^2 + (y - by)^2 ≲ 1]

    actual_obj, actual_pt = oracle(cost, domain; variables)

    expected_pt = closest_point_in_disc(center, point)
    expected_obj = norm(point - expected_pt)^2
    @test isapprox(expected_pt, actual_pt; atol=1e-3)
    @test isapprox(expected_obj, actual_obj; atol=1e-3)
end

@testset "minimize parabola over square" begin
    point = ax, ay = randn(2)
    center = bx, by = randn(2)

    @variables x y
    variables = scalarize((x, y))
    cost = ((x - ax)^2 + (y - ay)^2)
    domain = [(x - bx)^2 ≲ 1, (y - by)^2 ≲ 1]

    actual_obj, actual_pt = oracle(cost, domain; variables)

    expected_pt = closest_point_in_square(center, point)
    expected_obj = norm(point - expected_pt)^2
    @test isapprox(expected_pt, actual_pt; atol=1e-3)
    @test isapprox(expected_obj, actual_obj; atol=1e-3)
end



