include("../src/Quack.jl")
using Revise


p1(x1, x2) = -2 * x1 * x2
p2(x1, x2) =  2 * x1 / x2

d1(x) = -(2+x)^2 + 1

quack = Quack.quack_oracle((p1, p2), (d1, d1))
ite, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

