using Quack: nash_equilibrium
using Test

@testset "prisoner" begin
    p1 = -[1 5; 0 3]
    p2 = -[1 0; 5 3]

    values, (s1, s2) = nash_equilibrium((p1, p2))
        
    @test values ≈ [-3; -3] atol=1e-3
    @test s1 ≈ [0; 1] atol=1e-3
    @test s2 ≈ [0; 1] atol=1e-3
end