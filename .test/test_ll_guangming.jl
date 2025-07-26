include("../src/Quack.jl")
using Revise

# Computational Optimization and Applications (2020) 75:817–832
# https://doi.org/10.1007/s10589-019-00141-6
# Saddle points of rational functions
# Guangming Zhou, Qin Wang, Wenjie Zhao

full_null(x) = 0
unitball3d(x) = 1 - x[1]^2 - x[2]^2 - x[3]^2

u1(x, y) = -(x[1]^2 * y[1] + 2 * x[2]^2 * y[2] + 3 * x[3]^2 * y[3] - x[1] - x[2] - x[3]) / (x[1] * y[1] + 1)
u2(x, y) = -u1(x, y)

quack = Quack.quack_oracle((u1, u2), (unitball3d, unitball3d), (full_null, full_null), (3, 3))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
