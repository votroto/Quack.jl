include("../src/Quack.jl")
using Revise

# Computational Optimization and Applications (2020) 75:817–832
# https://doi.org/10.1007/s10589-019-00141-6
# Saddle points of rational functions
# Guangming Zhou, Qin Wang, Wenjie Zhao

# Examples of two-player zero-sum rational polynomial games (mostly) on compact nD subsets of R.

function ex_zhou19_5_1()
    # two saddle points
    # x∗ = (0.3165, 0.3165, 0.3670), y∗ = (0.0000, 1.0000, 0.0000)
    # x∗ = (0.3165, 0.3165, 0.3670), y∗ = (0.0000, 0.0000, 1.0000)

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    p(x, y) = sum(x[i]^2 * y[j]^2 for i in 1:3, j in 1:3) - sum(x[i] * x[j] + y[i] * y[j] for i in 1:3, j in 1:3 if i != j)
    q(x, y) = x[1] + x[2] + y[2] + y[3]

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function _ex_zhou19_5_2_i()
    # no saddle points

    # huge discontinuous rift

    dom_nneg(v) = (1 - v[1], 1 - v[2], 1 + v[1], 1 + v[2])
    dom_null(v) = 0

    p(x, y) = x[1]^2 * x[2]^2 - y[1]^2 * y[2]^2 - x[1] * y[1] - x[2] * y[2]
    q(x, y) = -x[1] * x[2] + y[1] * y[2] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (2, 2)
end

function ex_zhou19_5_2_ii()
    # saddle point
    # x∗ = (0.0722, 0.0155, 0.0394) × 10^−15,
    # y∗ = (−0.1210, −0.0824, −0.0632) × 10^−15

    dom_nneg(v) = (1 - v[1], 1 - v[2], 1 - v[3], 1 + v[1], 1 + v[2], 1 + v[3])
    dom_null(v) = 0

    p(x, y) = sum(x[i]^2 for i in 1:3) - sum(y[i]^2 for i in 1:3)
    q(x, y) = sum(y[i]^2 for i in 1:3) - sum(x[i]^2 for i in 1:3) + 3

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_3_i()
    # saddle point
    # x∗ = (0.2540, 0.2097) × 10^−4, y∗ = (0.2487, 0.2944) × 10^−4

    dom_nneg(v) = (1 - v[1], 1 - v[2], v[1], v[2])
    dom_null(v) = 0

    p(x, y) = x[1]^2 + x[2]^2 - y[1]^2 - y[2]^2
    q(x, y) = x[1] + y[2] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (2, 2)
end

function ex_zhou19_5_3_ii()
    # no saddle point

    dom_nneg(v) = (1 - v[1], 1 - v[2], 1 - v[3], v[1], v[2], v[3])
    dom_null(v) = 0

    p(x, y) = sum(x[i] + y[i] for i in 1:3) + sum(x[i]^2 * y[j]^2 - y[i]^2 * x[j]^2 for i in 1:3, j in 1:3 if i < j)
    q(x, y) = x[1]^2 + y[2]^2 + x[3] * y[3] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_4_i()
    # saddle point
    # x∗ = (0.0015, 0.0015, 0.0015), y∗ = (0.0015, 0.0015, 0.0015)

    # not compact

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = 0

    p(x, y) = x[1]^4 + x[2]^4 + x[3]^4 - y[1]^4 - y[2]^4 - y[3]^4
    q(x, y) = x[1] + y[1] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_zhou19_5_4_ii()
    # no saddle point

    # not compact
    # obvious discontinuity at 0

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = 0

    p(x, y) = x[1]^2 + x[2]^2 + x[3] * y[3] - y[1]^2 - y[2]^2
    q(x, y) = x[1] * x[2] * x[3] + y[1] * y[2] * y[3]

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_5_i()
    # no saddle point

    dom_nneg(v) = (1 - (v[1]^2 + v[2]^2))
    dom_null(v) = 0

    p(x, y) = x[1]^2 + x[2]^2 - 3 * x[1] * x[2] - y[1]^2 - y[2]^2 + y[1] * y[2]
    q(x, y) = x[1] * y[1] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (2, 2)
end


function ex_zhou19_5_5_ii()
    # saddle point
    # x∗ = (0.4730, 0.4476, 0.3416), y∗ = (0.6708, 0.5585, 0.4879)

    dom_nneg(v) = (1 - (v[1]^2 + v[2]^2 + v[3]^2))
    dom_null(v) = 0

    p(x, y) = x[1]^2 * y[1] + 2 * x[2]^2 * y[2] + 3 * x[3]^2 * y[3] - x[1] - x[2] - x[3]
    q(x, y) = x[1] * y[1] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_zhou19_5_6_i()
    # no saddle point

    dom_nneg(v) = 1
    dom_null(v) = (1 - (v[1]^2 + v[2]^2 + v[3]^2))

    p(x, y) = sum(x[i]^3 + y[i]^3 for i in 1:3) + 2 * (x[1] * x[2] * y[1] * y[2] + x[1] * x[3] * y[1] * y[3] + x[2] * x[3] * y[2] * y[3])
    q(x, y) = x[1] - y[1] + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_6_ii()
    # saddle point
    # x∗ = (0.4082, 0.4082, 0.8165), y∗ = (−0.4082, −0.8165, −0.4082)

    dom_nneg(v) = 1
    dom_null(v) = (1 - (v[1]^2 + v[2]^2 + v[3]^2))

    p(x, y) = sum(x[i]^2 + y[i]^2 - x[i] - y[i] for i in 1:3)
    q(x, y) = x[3] + y[2] + 2

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_7_i()
    # no saddle point

    # there so is...
    # (0.435, 0.637, 0.637), 100.0 %;
    # (0.526, 0.851), 100.0 %;

    dom_nneg1(v) = (v[1], v[2], v[3])
    dom_null1(v) = (v[1]^2 + v[2]^2 + v[3]^2 - 1)

    dom_nneg2(v) = (v[1], v[2])
    dom_null2(v) = (v[1]^2 + v[2]^2 - 1)

    p(x, y) = sum(x[i]^2 - x[i] for i in 1:3) + sum(y[i] - y[i]^2 for i in 1:2)
    q(x, y) = x[1]^2 - y[1]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null1, dom_null2), (3, 2)
end

function ex_zhou19_5_7_i_polar()
    # no saddle point

    # there so is...
    # (0.88, 0.972), 100.0 %;
    # (1.017,), 100.0 %;

    dom_nneg1(v) = (v[1], v[2], pi / 2 - v[1], pi / 2 - v[2])
    dom_null1(v) = 0

    dom_nneg2(v) = (v[1], pi / 2 - v[1])
    dom_null2(v) = 0

    p(x, y) = sum(x[i]^2 - x[i] for i in 1:3) + sum(y[i] - y[i]^2 for i in 1:2)
    q(x, y) = x[1]^2 - y[1]^2 + 1

    function u1(x, y)
        cx = [
            sin(x[1]) * cos(x[2]),
            sin(x[1]) * sin(x[2]),
            cos(x[1])
        ]
        cy = [
            cos(y[1]),
            sin(y[1])
        ]

        -(p(cx, cy) / q(cx, cy))
    end
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null1, dom_null2), (2, 1)
end

function ex_zhou19_5_7_ii()
    # saddle point
    # x∗ = (0.9519, 0.2167, 0.2167), y∗ = (1.0000, 0.0000, 0.0000)

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = (v[1]^2 + v[2]^2 + v[3]^2 - 1)

    p(x, y) = sum((x[i] - 1)^2 + (y[i] - 1)^2 for i in 1:3)
    q(x, y) = x[1]^2 - y[1]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_8_i()
    # saddle point
    # x∗ = (0.3508, 0.5000, 0.0000), y∗ = (0.0000, 0.0000, 0.0000)

    # unbounded

    dom_nneg(v) = 1
    dom_null(v) = 0

    p(x, y) = x[1]^2 + x[2]^2 + x[3]^2 + y[1]^2 + y[2]^2 - x[1] - x[2]
    q(x, y) = x[1]^2 + y[3]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_zhou19_5_8_ii()
    # no saddle point
    # unbounded

    dom_nneg(v) = 1
    dom_null(v) = 0

    p(x, y) = sum(x[i]^4 - y[i]^4 + x[i] - y[i] for i in 1:3) + sum(x[i]^3 * y[j]^3 for i in 1:3, j in 1:3 if i != j)
    q(x, y) = x[1]^2 + x[2]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_zhou19_5_9_i()
    # saddle point
    # x∗ = (0.8914, 1.1219, 0.8914), y∗ = (0.8914, 1.1219, 0.8914)

    # unbounded

    dom_nneg(v) = (v[1], v[1] * v[2] - 1, v[2] * v[3] - 1)
    dom_null(v) = 0

    p(x, y) = sum(x[i]^2 - x[i] + y[i] - y[i]^2 for i in 1:3)
    q(x, y) = x[1]^2 + y[1]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_zhou19_5_9_ii()
    # saddle point
    # x∗ = (0.9230, 1.0834, 2.8239), y∗ = (1.0459, 0.9561, 1.3804)

    # unbounded

    dom_nneg(v) = (v[1], v[1] * v[2] - 1, v[2] * v[3] - 1)
    dom_null(v) = 0

    p(x, y) = x[1]^4 + x[2]^4 - y[1]^4 - y[2]^4 + x[1] * x[3] + y[1] * y[3]
    q(x, y) = x[3]^2 + y[3]^2 + 1

    u1(x, y) = -(p(x, y) / q(x, y))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


