include("../src/Quack.jl")
using Revise

# Convergence Analysis of Gradient-Based Learning in Continuous Games
# Benjamin Chasnov, Lillian Ratliff, Eric Mazumdar, Samuel Burden

function ex_chasnov20_5_2()
    # two pure equilibria at (-1.063, 1.014) and (1.408, -0.325).

    dom_nneg(x) = -x[1]^2 + π^2
    dom_null(x) = 0

    phi = (0, π / 8)
    alp = (1, 1.5)

    u1(x, y) = alp[1] * cos(x[1] − phi[1]) - cos(x[1] - y[1])
    u2(x, y) = alp[2] * cos(y[1] − phi[2]) - cos(y[1] - x[1])

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end