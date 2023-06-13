using Quack: interior_init
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

@testset "point in disc" begin
    center = ax, ay = randn(2)

    variables = @variables x[1:2]
    variables = scalarize(variables)
    domain = [(x[1] - ax)^2 + (x[2] - ay)^2 ≲ 1]

    (actual_pt, ) = interior_init(domain; variables)

    direction_norm = norm(center - actual_pt)
    @test direction_norm <= 1
end

@testset "point in square" begin
    center = ax, ay = randn(2)

    variables = @variables x[1:2]
    variables = scalarize(variables)
    domain = [(x[1] - ax)^2 ≲ 1, (x[2] - ay)^2 ≲ 1]

    (actual_pt, ) = interior_init(domain; variables)

    direction_norm = norm(center - actual_pt, Inf)
    @test direction_norm <= 1
end



