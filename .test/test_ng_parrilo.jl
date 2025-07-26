include("../src/Quack.jl")
using Revise

ball(x) =  - x^2  +  1

u1(x,y) = (x-y)^2
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1, u2), (ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)


u1(x,y) = 2*x*y^2 - x^2 - y
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1, u2), (ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)


u1(x,y) = 5*x*y - 2*x^2 - 2*x*y^2 - y
u2(x,y) = -u1(x,y)

quack = Quack.quack_oracle((u1, u2), (ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)