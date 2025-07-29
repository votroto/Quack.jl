include("../src/Quack.jl")
using Revise

function ex_classical_square_diff()
    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = y[1]^2 - x[1]^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_classical_monkey_saddle()
    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = (x[1]^3 - 3*x[1]*y[1]^2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

