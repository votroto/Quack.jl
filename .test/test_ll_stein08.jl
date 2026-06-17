include("../src/Quack.jl")

# Separable and low-rank continuous games. Int J Game Theory 37, 475–504 (2008).
# https://doi.org/10.1007/s00182-008-0129-2
# Stein, N.D., Ozdaglar, A. & Parrilo, P.A.

# general-sum multiplayer polynomial separable games on [-1,1]

function ex_stein08_2_3()
    # mixed NE
    # (-1.0,), 55.32 %; (0.1149,), 44.68 %;
    # (0.7166,), 100 %;

    dom_nneg(v) = (1 + v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = 2 * x[1] * y[1] + 3y[1]^3 - 2x[1]^3 - x[1] - 3x[1]^2 * y[1]^2
    u2(x, y) = 2x[1]^2 * y[1]^2 - 4y[1]^3 - x[1]^2 + 4y[1] + x[1]^2 * y[1]

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_stein08_2_4()
    # mixed NE
    # any phi and phi + pi weighted equally for both players.

    dom_nneg(v) = pi^2 - v[1]^2
    dom_null(v) = 0

    alpha = 0.5
    u1(x, y) = cos(x[1] - y[1])
    u2(x, y) = cos(x[1] - y[1] - alpha)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_stein08_3_10()
    dom_nneg(v) = (1 - v[1]^2)
    dom_null(v) = 0

    v1(x,y,z) = 1 + 2*x + 3*x^2 + 2*y*z + 4*x*y*z + 6*x^2*y*z + 3*y^2*z^2 + 6*x*y^2*z^2 + 9*x^2*y^2*z^2
    v2(x,y,z) = 7 + 2*x + 3*x^2 + 2*y + 4*x*y + 6*x^2*y + 3*z^2 + 6*x*z^2 + 9*x^2*z^2
    v3(x,y,z) = - z - 2*x*z - 3*x^2*z - 2*y*z - 4*x*y*z - 6*x^2*y*z - 3*y*z^2 - 6*x*y*z^2 - 9*x^2*y*z^2

    u1(x, y, z) = v1(x[1], y[1], z[1])
    u2(x, y, z) = v2(x[1], y[1], z[1])
    u3(x, y, z) = v3(x[1], y[1], z[1])

    (u1, u2, u3), (dom_nneg, dom_nneg, dom_nneg), (dom_null, dom_null, dom_null), (1, 1, 1)
end
