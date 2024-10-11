

include("../src/utils.jl")
include("../src/symbolics_utils.jl")
include("../src/iterable.jl")
include("../src/oracle.jl")
include("../src/master.jl")
include("../src/equilibrium.jl")

using Revise
using Symbolics: @variables
using Test

__init__()

n = 3
gamma = 1.3


c(q) = (q-0.8)^2
l1(phi,q) = 1 - sum(phi[i+1] * binomial(n,i) * q^i*(1-q)^(n-i) for i in 0:n) + 2.0^(-n)*gamma*sum(phi[i+1] * binomial(n,i) for i in 0:n)
l2(phi,q) = c(q) - sum(binomial(n,i)*(1-phi[i+1])*q^i*(1-q)^(n-i) for i in 0:n)


phi = Tuple([Symbolics.variable(:ϕ,i) for i in 1:n+1])
q = Symbolics.variable(:q)

pays = -l1(phi,q), -l2(phi,q)

doms = (ntuple(i->phi[i]*(phi[i]-1) ≲ 0, n+1), (q*(q-1) ≲ 0,))
vars = (phi, (q,))

quack = quack_oracle(pays, doms; variables=vars)
(actions, mixed, values, best) = fixed_iters(quack, 10)




