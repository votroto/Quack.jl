#=include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle.jl")
include("../src/master.jl")
include("../src/equilibrium.jl")
=#
using Revise
using Symbolics: @variables
using Test


@variables x y

phi = (0, π/8)
alp = (1, 1.5)
f1(x, y) = alp[1] * cos(x − phi[1]) - cos(x - y)
f2(x, y) = alp[2] * cos(y − phi[2]) - cos(y - x)


using JuMP
import AmplNLWriter
import Couenne_jll
m = Model(() -> AmplNLWriter.Optimizer(Couenne_jll.amplexe))

@variable m x
@variable m y
@constraint m x^2 + y^2 <= 1
@objective m Max f1(x, y)
optimize!(m)


