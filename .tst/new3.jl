include("../src/Quack.jl")
using Revise

phi = (0, π/8)
alp = (1, 1.5)

p1(x, y) = alp[1] * cos(x − phi[1]) - cos(x - y)
p2(x, y) = alp[2] * cos(y − phi[2]) - cos(y - x)

dom1(x) = -x^2 + π^2
dom2(y) = -y^2 + π^2


iters, (actions, weights, vals, subopt) = Quack.until_eps(Quack.quack_oracle((p1, p2), (dom1, dom2)), 1e-3)