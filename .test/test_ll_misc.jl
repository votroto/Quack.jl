include("../src/Quack.jl")

function ex_misc_square_diff()
    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = y[1]^2 - x[1]^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_misc_monkey_saddle()
    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = (x[1]^3 - 3 * x[1] * y[1]^2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_misc_mul_div()
    dom_nneg(x) = -(2 + x[1])^2 + 1
    dom_null(x) = 0

    u1(x, y) = -2 * x[1] * y[1]
    u2(x, y) = 2 * x[1] / y[1]

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

# Lukas Adam
function _ex_counter()
    # oracles:

    # x = only(actions[1][argmax(weights[1])])
    # y = only(actions[2][argmax(weights[2])])
    # armx = ((y/2,), (x,))
    # mx = (payoffs[1](armx...), payoffs[2](armx...))
    # return mx, armx

    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    function v1(x, y)
        if x-y >= 0
            return x+y
        elseif x-y<=0 && 2x-y>=0
            return 8x-6y
        elseif 2x-y<=0
            return -2x-y
        end
    end
    u1(x,y) = -v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
