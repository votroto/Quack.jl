include("../src/Quack.jl")
using Revise


p1(x1, x2, x3) = -2 * x1 * x2^2 - 2 * x1^2 + 5 * x1 * x2 - 4 * x1 * x3 - x2 - 2 * x3
p2(x1, x2, x3) =  2 * x1 * x2^2 - 2 * x2 * x3^2 - 2 * x1^2 - 5 * x1 * x2 - 2 * x2^2 + 5 * x2 * x3 + x2
p3(x1, x2, x3) =  2 * x2 * x3^2 + 4 * x1^2 + 4 * x1 * x3 + 2 * x2^2 - 5 * x2 * x3 + 2 * x3

d1(x) = -x^2 + 1

quack = Quack.quack_oracle((p1, p2, p3), (d1, d1, d1))
ite, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

