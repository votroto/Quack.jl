using Quack: _compile_sym, _subgames, _subgame
using Symbolics: @variables
using Test

@testset "static" begin
    @testset "native two one one" begin
        variables = @variables x y a b
        poly1 = x + 10y + 100a + 1000b
        f = _compile_sym(poly1, [[x, y], [a], [b]])
        actions = [[1 2; 2 1], [3 4], [5 6]]

        actual = _subgame(f, actions)

        expected =  [5321 5421; 5312 5412;;; 6321 6421; 6312 6412]
        @test isapprox(expected, actual)
    end

    @testset "symbolics two one one" begin
        poly((x,y), (a,), (b,)) = x + 10y + 100a + 1000b
        actions = [[1 2; 2 1], [3 4], [5 6]]

        actual = _subgame(poly, actions)

        expected =  [5321 5421; 5312 5412;;; 6321 6421; 6312 6412]
        @test isapprox(expected, actual)
    end
end