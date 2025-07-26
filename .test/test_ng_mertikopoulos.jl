include("../src/Quack.jl")
using Revise

zeroone(x) =  x-x^2
ball(x) =  - x^2  +  1

u1(x,y) = ((x-0.5)*(y-0.5)+1/3*exp(-(x-1/4)^2-(y-3/4)^2))
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1,u2), (zeroone, zeroone))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

u1(x,y) = -(x^4*y^2+x^2+1)*(x^2*y^4-y^2+1)
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1,u2), (ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
