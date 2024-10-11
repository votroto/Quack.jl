include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle2.jl")
include("../src/master.jl")
include("../src/equilibrium.jl")


using Revise
using Symbolics: @variables
using Test

#=
@variables x y

pays = ((x - y)^2, -(x - y)^2)
doms = ((x^2 ≲ 1,), (y^2 ≲ 1,))
vars = ((x,), (y,))

quack = quack_oracle(pays, doms; variables=vars)
(actions, mixed, values, best) = fixed_iters(quack, 5)

expected_values = [1, -1]
@test expected_values ≈ collect(values) atol = 1e-5
=#
@variables x y

u1 = [1,x,y,x^2,y^2,x*y,x^3,y^3,x^2*y,x*y^2]' * randn(10, 10) * [1,x,y,x^2,y^2,x*y,x^3,y^3,x^2*y,x*y^2]
u2 = [1,x,y,x^2,y^2,x*y,x^3,y^3,x^2*y,x*y^2]' * randn(10, 10) * [1,x,y,x^2,y^2,x*y,x^3,y^3,x^2*y,x*y^2]

pays = (u1, u2)
doms = ((x^2 ≲ 1,), (y^2 ≲ 1,))
vars = ((x,), (y,))

quack = quack_oracle(pays, doms; variables=vars)
@time cnt, (actions, mixed, values, best) = until_eps(quack, 1e-3)



#expected = [1.13, 1.81]
#@test isapprox(collect(values), expected; atol=1e-1)

