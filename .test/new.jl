include("../src/Quack.jl")
using Revise

p1(x,y) = (x-y)^2
p2(x,y) = -(x-y)^2

dom1(x) = -x^2 + 1
dom2(y) = -y^2 + 1

#@show Quack.feasible_init((dom1, dom2))
#@show Quack.best_response((x) -> p1(x, 0.5), dom1)
#@show Quack.best_response((y) -> p2(0.5, y), dom2)

#@show Quack.oracle((p1, p2), (dom1, dom2), ([0.5], [0.5]), ([1.0],[1.0]))

iters, (actions, weights, vals, subopt) = Quack.until_eps(Quack.quack_oracle((p1, p2), (dom1, dom2)), 1e-3)
