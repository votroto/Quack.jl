using Quack: nash_equilibrium
using Test

@testset "prisoner" begin
    p1 = -[1 5; 0 3]
    p2 = -[1 0; 5 3]

    values, (s1, s2) = nash_equilibrium((p1, p2))

    @test values ≈ [-3; -3] atol = 1e-3
    @test s1 ≈ [0; 1] atol = 1e-3
    @test s2 ≈ [0; 1] atol = 1e-3
end

@testset "3x3 guess" begin
    guess = [0 1 4; 1 0 1; 4 1 0]

    values, (s1, s2) = nash_equilibrium((guess, -guess))

    expected_values = [1, -1]
    expected_s1 = [0.25, 0.0, 0.75]
    expected_s2 = [0.0, 1.0, 0.0]

    @test isapprox(values, expected_values, atol=1e-3)
    @test (isapprox(s1, expected_s1, atol=1e-3) ||
           isapprox(reverse(s1), expected_s1, atol=1e-3))
    @test isapprox(s2, expected_s2, atol=1e-3)
end