# Universal Gradient Descent Ascent Method for Nonconvex-Nonconcave Minimax Optimization
# Taoli Zheng

function ex_zheng23_convex_nonconcave()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    u1(x, y) = -u2(x, y)
    u2(x, y) = 2 * x[1]^2 - y[1]^2 + 4 * x[1] * y[1] + 4 / 3 * y[1]^3 - 1 / 4 * y[1]^4

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_zheng23_kl_nonconcave()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    u1(x, y) = -u2(x, y)
    u2(x, y) = x[1]^2 + 3 * sin(x[1])^2 * sin(y[1])^2 - 4 * y[1]^2 - 10 * sin(y[1])^2

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_zheng23_bilinearly_coupled_minimax()
    dom_nneg(x) = (4 + x[1], 4 - x[1])
    dom_null(x) = 0

    A = 10
    f(z) = (z + 1) * (z - 1) * (z + 3) * (z - 3)

    u1(x, y) = -u2(x, y)
    u2(x, y) = f(x[1]) + A * x[1] * y[1] - f(y[1])

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_zheng23_forsaken()
    dom_nneg(x) = (1.5 + x[1], 1.5 - x[1])
    dom_null(x) = 0

    phi(z) = 1/4*z^2 - 1/2 * z^4 + 1/6*z^6

    u1(x, y) = -u2(x, y)
    u2(x, y) = x[1]*(y[1]-0.45) + phi(x[1]) - phi(y[1])

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
