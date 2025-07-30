include("../src/Quack.jl")
using Revise

# Double Oracle Algorithm for Computing Equilibria in Continuous Games
# Adam, Lukáš & Horčík, Rostislav & Kasl, Tomáš & Kroupa, Tomáš. (2021).

function ex_adam21_townsend()
    dom_nneg1(x) = (2.25 + x[1], 2.5 - x[1])
    dom_nneg2(x) = (2.5 + x[1], 1.75 - x[1])
    dom_null(x) = 0

    u1(x, y) = cos((x[1] - 0.1) * y[1])^2 + x[1] * sin(3 * x[1] + y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end
