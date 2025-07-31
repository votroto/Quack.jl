include("../src/Quack.jl")
using Revise

# Games of strategy: theory and applications
# Dresher, Melvin

function ex_dresher61_pg110()
    # mixed NE
    # (0.0,), 50.0 %; (1.0,), 50.0 %;
    # (0.5,), 100.0 %;
    # v=1/4

    dom_nneg(v) = (v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = (x[1] - y[1])^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_dresher61_pg111()
    # v = 1/6

    dom_nneg(v) = (v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = sqrt((y[1]-x[1])^2)*(1-sqrt((y[1]-x[1])^2))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

utils, nneg, null, dims = ex_dresher61_pg111()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

prettyprints(actions,mixed)