include("../src/Quack.jl")
using Revise


p1(x, y) = -3 * x^2 * y^2 - 2 * x^3 + 3 * y^3 + 2 * x * y - x
p2(x, y) = 2 * x^2 * y^2 + x^2 * y − 4 * y^3 − x^2 + 4 * y

d1(x) = -x^2 + 1
d2(y) = -y^2 + 1

quack = Quack.quack_oracle((p1, p2), (d1, d2))
cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

expected = [1.13, 1.81]
@assert isapprox(collect(vals), expected; atol=1e-1)
