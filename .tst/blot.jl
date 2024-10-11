include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle.jl")
include("../src/multilinear_matrix_nash.jl")
include("../src/equilibrium.jl")

__init__()

using Revise
using Symbolics: @variables
using Test


@variables x[1:5] y[1:5]

f(x) = sign(x) * x^2
p1 = sum(f(x[i] - y[i]) for i in 1:5)
p2 = -p1


pays = (p1, p2)
doms = ((sum(x) ~ 1,), (sum(y) ~ 1,))
vars = (Symbolics.scalarize(x), Symbolics.scalarize(y))

S1 = zeros(5)
S2 = zeros(5)
S1[rand(1:5)] = 1
S2[rand(1:5)] = 1

s1 = [Tuple(normalize(rand(5), 1))]
s2 = [Tuple(normalize(rand(5), 1))]

#s1 = [Tuple(S1)]
#s2 = [Tuple(S2)]

glins = []
glact = []
glmix = []

quack = quack_oracle(pays, doms; variables=vars, start=(s1, s2))
(actions, mixed, values, best) = fixed_iters(quack, 10)

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
end
