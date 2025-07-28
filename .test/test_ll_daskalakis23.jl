include("../src/Quack.jl")
using Revise

function ex_daskalakis_d()
    dom_nneg(x) = x[1] - x[1]^2
    dom_null(x) = 0

    u1(x, y) = (x[1] - 1 / 2) * (y[1] - 1 / 2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

utils, nneg, null, dims = ex_daskalakis_d()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)