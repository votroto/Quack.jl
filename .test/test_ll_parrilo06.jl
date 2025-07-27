include("../src/Quack.jl")
using Revise

# Proceedings of the 45th IEEE Conference on Decision and Control
# DOI: 10.1109/CDC.2006.377261
# Polynomial games and sum of squares optimization
# Pablo A. Parrilo

# Examples of two-player zero-sum polynomial games on [-1, 1]

function ex_parrilo06_2_1()
    # Example 2.1
    # mixed NE
    # (1.0,), 50.0 %; (-1.0,), 50.0 %;
    # (0.0,), 100.0 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = (x[1] - y[1])^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


function ex_parrilo06_3_1()
    # Example 3.1
    # NE
    # (4^(-2/4),), 100.0 %;
    # (4^(-1/4),), 100.0 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = 2*x[1]*y[1]^2 - x[1]^2 - y[1]
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


function ex_parrilo06_3_2()
    # Example 3.2
    # mixed NE
    # (0.2,), 100.0 %;
    # (1.0,), 78 %; (-1.0,), 22 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x,y) = 5*x[1]*y[1] - 2*x[1]^2 - 2*x[1]*y[1]^2 - y[1]
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

utils, nneg, null, dims = ex_parrilo06_3_1()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)