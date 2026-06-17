include("../src/Quack.jl")

# The Theory of Infinite Games
# Karlin, Samuel


function ex_karlin59_vol2_sec71_ex1()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    lam = 0.5
    v1(x, y) = 1 / (1 + lam * (x - y)^2)

    u1(x, y) = v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_karlin59_vol2_sec71_ex2()
    # NE
    # cantor distribution

    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x, y) = (y - 0.5) * ((1 + (x - 0.5) * (y - 0.5)^2) / (1 + (x - 0.5)^2 * (y - 0.5)^4) - 1 / (1 + (x / 3 - 0.5) * (y - 0.5)^4))

    u1(x, y) = v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_karlin59_vol2_sec76_pr1()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x, y) = 2*(x+y)/((2*x+1)*(2*y+1))

    u1(x, y) = v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_karlin59_vol2_sec76_pr2()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x, y) = ((1+x)*(1+y))/(1+x*y)^2

    u1(x, y) = v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
