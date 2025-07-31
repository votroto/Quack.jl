include("../src/Quack.jl")
using Revise

# Characterization and Computation of Correlated Equilibria in Infinite Games
# Noah D. Stein, Pablo A. Parrilo, and Asuman Ozdaglar

function ex_stein07_4_3_1()
    # correlated NE
    # x = 1, y = 1

    dom_nneg(v) = (1 + v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = 0.596 * x[1]^2 + 2.072 * x[1] * y[1] - 0.394 * y[1]^2 + 1.360 * x[1] - 1.200 * y[1] + 0.554
    u2(x, y) = -0.108 * x[1]^2 + 1.918 * x[1] * y[1] - 1.044 * y[1]^2 - 1.232 * x[1] + 0.842 * y[1] - 1.886

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

utils, nneg, null, dims = ex_stein07_4_3_1()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

prettyprints(actions,mixed)