include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle.jl")
include("../src/master.jl")
include("../src/equilibrium.jl")

using Revise
using Symbolics: @variables
using Test


@variables x y

phi = (0, π/8)
alp = (1, 1.5)
p1 = alp[1] * cos(x − phi[1]) - cos(x - y)
p2 = alp[2] * cos(y − phi[2]) - cos(y - x)


pays = (p1, p2)
doms = ((x^2 ≲ π^2,), (y^2 ≲ π^2,))
vars = ((x,), (y,))

quack = quack_oracle(pays, doms; variables=vars)
(actions, mixed, values, best) = fixed_iters(quack, 10)

#=
wass = [[NaN; [wasserstein(glact[i-1][p], glact[i][p], glmix[i-1][p], glmix[i][p]) for i in 2:length(glins)]] for p in 1:2]

for i in eachindex(glins)
    print(i)
    print("\t")
    for n in 1:2
        print(glins[i][n])
        print("\t")
    end
    for n in 1:2
        print(wass[n][i])
        print("\t")
    end
    println()
end=#