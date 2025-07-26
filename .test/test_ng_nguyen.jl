include("../src/Quack.jl")
using Revise

xminxmax(x) =  -x^2 + 2.2*x - 0.4

# Nash equilibrium seeking over digraphs with row-stochastic matrices and network-independent step-sizes
# arXiv:2309.07897 [cs.GT]

n0 = 0.43 * 1e-6
b = [0.5, 0.51, 0.52, 0.3, 0.31, 0.32]
a = [0.261, 0.494, 0.107, 0.366, 0.208, 0.305]

p = 1e-5 * [
    7.463 7.378 7.293 7.210 7.127 6.965
    7.451 7.365 7.281 7.198 7.115 6.953
    7.438 7.353 7.269 7.186 7.103 6.942
    7.427 7.342 7.258 7.175 7.093 6.931
    7.409 7.324 7.240 7.157 7.075 6.914
    7.387 7.303 7.219 7.136 7.055 6.894
]

g = [
    (x...) -> x[i]/(n0 + sum(p[i,j]*x[j] for j in 1:6))
    for i in 1:6
]

u = [
    (x...) -> -(x[i] - b[i] * (log(1+(a[i]*g[i](x...))/(1-p[i,i]*g[i](x...))) - x[i]))
    for i in 1:6
]

quack = Quack.quack_oracle(tuple(u...), ntuple(i -> xminxmax, 6))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
