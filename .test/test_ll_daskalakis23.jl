include("../src/Quack.jl")
using Revise

# STay-ON-the-Ridge: Guaranteed Convergence to Min-Max Critical Points in Nonconvex-Nonconcave Games
# Daskalakis et al 2023

function ex_daskalakis_d()
    dom_nneg(x) = x[1] - x[1]^2
    dom_null(x) = 0

    u1(x, y) = (x[1] - 1 / 2) * (y[1] - 1 / 2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_daskalakis_e_1st()
    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = -(4*x[1]^2-(y[1]-3*x[1]+x[1]^3/20)^2-y[1]^4/10) * exp(-(x[1]^2+y[1]^2)/100)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
