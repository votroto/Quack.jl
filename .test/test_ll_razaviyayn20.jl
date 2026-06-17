include("../src/Quack.jl")

# Non-convex Min-Max Optimization: Applications, Challenges, and Recent Theoretical Advances
# Meisam Razaviyayn, Tianjian Huang, Songtao Lu, Maher Nouiehed, Maziar Sanjabi, Mingyi Hong

function ex_razaviyayn20_5_1()
    dom_nneg1(x) = (1 + x[1], 1 - x[1])
    dom_nneg2(x) = (2 * pi + x[1], 2 * pi - x[1])
    dom_null(x) = 0

    u1(x, y) = 0.2 * x[1] * y[1] - cos(y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end

function ex_razaviyayn20_5_3()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    u1(x, y) = x[1]^3+2*x[1]*y[1]-y[1]^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
