include("../src/Quack.jl")
using Revise

ball(x) =  - x^2  +  1

# Separable and low-rank continuous games
# arXiv:0707.3462 [cs.GT]

# Example 2.3

#=
u1(x,y) = 2*x*y + 3y^3 - 2x^3 - x - 3x^2*y^2
u2(x,y) = 2x^2*y^2 - 4y^3 - x^2 + 4y + x^2*y

quack = Quack.quack_oracle((u1, u2), (ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
=#


# Example 2.4
# badly described
circle(x) =  - x^2  +  pi^2

alpha = 0.5
u1(x,y) = cos(x-y)
u2(x,y) = cos(x-y-alpha)

quack = Quack.quack_oracle((u1, u2), (circle, circle))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)


# Example 3.10
#=
u1(x,y,z) = 1 + 2*x + 3*x^2 + 2*y*z + 4*x*y*z + 6*x^2*y*z + 3*y^2*z^2 + 6*x*y^2*z^2 + 9*x^2*y^2*z^2
u2(x,y,z) = 7 + 2*x + 3*x^2 + 2*y + 4*x*y + 6*x^2*y + 3*z^2 + 6*x*z^2 + 9*x^2*z^2
u3(x,y,z) = - z - 2*x*z - 3*x^2*z - 2*y*z - 4*x*y*z - 6*x^2*y*z - 3*y*z^2 - 6*x*y*z^2 - 9*x^2*y*z^2

quack = Quack.quack_oracle((u1, u2, u3), (ball, ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
=#