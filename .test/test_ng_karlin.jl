include("../src/Quack.jl")
using Revise

zeroone(x) =  x-x^2


u1(x,y) = (y-0.5)*((1+(x-0.5)*(y-0.5)^2)/(1+(x-0.5)^2*(y-0.5)^4) - 1/(1+(x/3-0.5)*(y-0.5)^4))
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1,u2), (zeroone, zeroone))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
