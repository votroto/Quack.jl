include("../src/Quack.jl")
using Revise

zeroone(x) =  x-x^2

u1(x,y) = (x-1/2)*(y-1/2)
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1,u2), (zeroone, zeroone))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
