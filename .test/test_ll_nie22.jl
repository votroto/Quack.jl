include("../src/Quack.jl")
using Revise

# Foundations of Computational Mathematics (2022) 22:1133–1169
# https://doi.org/10.1007/s10208-021-09526-8
# The Saddle Point Problem of Polynomials
# Jiawang Nie, Zi Yang, Guangming Zhou

# Examples of two-player zero-sum polynomial games (mostly) on compact nD subsets of R.

function ex_nie21_6_1_i()
    # Example 6.1 (i)
    # Saddle point
    # x∗ = (0.0000, 1.0000, 0.0000), y∗ = (0.2500, 0.5000, 0.2500).

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1] * x[2] + x[2] * x[3] + x[3] * y[1] + x[1] * y[3] + y[1] * y[2] + y[2] * y[3])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_1_ii()
    # Example 6.1 (ii)
    # Saddle point
    # x∗ = (0.0000, 0.0000, 1.0000), y∗ = (0.0000, 0.0000, 1.0000).

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1]^3 + x[2]^3 - x[3]^3 - y[1]^3 - y[2]^3 + y[3]^3 + x[3] * y[1] * y[2] * (y[1] + y[2]) + x[2] * y[1] * y[3] * (y[1] + y[3]) + x[1] * y[2] * y[3] * (y[2] + y[3]))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_1_iii()
    # Example 6.1 (iii)
    # Saddle point
    # x∗ = (0.2500, 0.2500, 0.2500, 0.2500), y∗ = ei

    dom_nneg(v) = (v[1], v[2], v[3], v[4])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] - 1

    u1(x, y) = -(sum(x[i]^2 * y[i]^2 for i in 1:4, j in 1:4) - sum(x[i] * x[j] + y[i] * y[j] for i in 1:4, j in 1:4 if i != j))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (4, 4)
end

function ex_nie21_6_1_iv()
    # Example 6.1 (iv)
    # no saddle points

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    u1(x, y) = -(x[1] * x[2] * y[1] * y[2] + x[2] * x[3] * y[2] * y[3] + x[3] * x[1] * y[3] * y[1] - x[1]^2 * y[3]^2 - x[2]^2 * y[1]^2 - x[3]^2 * y[2]^2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_2_i()
    # Example 6.2 (i)
    # saddle point
    # x∗ = (0.3249, 0.3249), y∗ = (1.0000, 0.0000)
    # - seemingly also all x[1]=x[2] < 0.8?

    dom_nneg(v) = (v[1], v[2], 1 - v[1], 1 - v[2])
    dom_null(v) = 0

    u1(x, y) = -((x[1] + x[2] + y[1] + y[2] + 1)^2 - 4 * (x[1] * x[2] + x[2] * y[1] + y[1] * y[2] + y[2] + x[1]))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (2, 2)
end


function ex_nie21_6_2_ii()
    # Example 6.2 (ii)
    # no saddle point

    dom_nneg(v) = (v[1], v[2], v[3], 1 - v[1], 1 - v[2], 1 - v[3])
    dom_null(v) = 0

    u1(x, y) = -(sum(x[i] + y[i] for i in 1:3) + sum(x[i]^2 * y[j]^2 - y[i]^2 * x[j]^2 for i in 1:3, j in 1:3 if i < j))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_nie21_6_3_i()
    # Example 6.3 (i)
    # saddle points:
    # x∗ = (−1.0000, −1.0000, 1.0000), y∗ = (1.0000, 1.0000, 1.0000),
    # x∗ = (−1.0000, 1.0000, −1.0000), y∗ = (1.0000, 1.0000, 1.0000),
    # x∗ = (1.0000, −1.0000, −1.0000), y∗ = (1.0000, 1.0000, 1.0000).

    dom_nneg(v) = (1 + v[1], 1 + v[2], 1 + v[3], 1 - v[1], 1 - v[2], 1 - v[3])
    dom_null(v) = 0

    u1(x, y) = -(sum(x[i] + y[i] for i in 1:3) - prod(x[i] - y[i] for i in 1:3))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_nie21_6_3_ii()
    # Example 6.3 (ii)
    # saddle points:
    # x∗ = (−1.0000, 1.0000, −1.0000), y∗ = (−1.0000, 1.0000, −1.0000)

    dom_nneg(v) = (1 + v[1], 1 + v[2], 1 + v[3], 1 - v[1], 1 - v[2], 1 - v[3])
    dom_null(v) = 0

    u1(x, y) = -(sum(y[i]^2 for i in 1:3) - sum(x[i]^2 for i in 1:3) + sum(x[i] * y[j] - x[j] * y[i] for i in 1:3, j in 1:3 if i < j))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_nie21_6_4_i()
    # Example 6.4 (i)
    # saddle points:
    # (−ei , ej)

    dom_nneg(v) = 1
    dom_null(v) = (v[1]^2 + v[2]^2 + v[3]^2 - 1)

    u1(x, y) = -(x[1]^3 + x[2]^3 + x[3]^3 + y[1]^3 + y[2]^3 + y[3]^3 + 2 * (x[1] * x[2] * y[1] * y[2] + x[1] * x[3] * y[1] * y[3] + x[2] * x[3] * y[2] * y[3]))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_nie21_6_4_ii()
    # Example 6.4 (ii)
    # no saddle points

    dom_nneg(v) = 1
    dom_null(v) = (v[1]^2 + v[2]^2 + v[3]^2 - 1)

    u1(x, y) = -(x[1]^2 * y[1]^2 + x[2]^2 * y[2]^2 + x[3]^2 * y[3]^2 + x[1]^2 * y[2] * y[3] + x[2]^2 * y[1] * y[3] + x[3]^2 * y[1] * y[2] + y[1]^2 * x[2] * x[3] + y[2]^2 * x[1] * x[3] + y[3]^2 * x[1] * x[2])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_5()
    # Example 6.5
    # saddle points
    # x∗ = (0.7264, 0.4576, 0.3492), y∗ = (0.6883, 0.5463, 0.4772).

    dom_nneg(v) = 1 - v[1]^2 - v[2]^2 - v[3]^2
    dom_null(v) = 0

    u1(x, y) = -(x[1]^2 * y[1] + 2 * x[2]^2 * y[2] + 3 * x[3]^2 * y[3] − x[1] − x[2] − x[3])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_6()
    # Example 6.6
    # no saddle points

    dom_nneg(v) = (v[1], v[2], v[3])
    dom_null(v) = (v[1]^2 + v[2]^2 + v[3]^2 - 1)

    u1(x, y) = -(x[1]^2 * y[2] * y[3] + y[1]^2 * x[2] * x[3] + x[2]^2 * y[1] * y[3] + y[2]^2 * x[1] * x[3] + x[3]^2 * y[1] * y[2] + y[3]^2 * x[1] * x[2])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_7()
    # Example 6.7
    # saddle points
    # x∗ = (1.5075, 0.5337, 0.0000, 0.5018), y∗ = (2.4143, 1.1463, 0.0000, 0.0000).

    # unbounded

    dom_nneg(v) = (v[1], v[2], v[3], v[4])
    dom_null(v) = 0

    u1(x, y) = -(y[1] * (x[2] + x[3] + x[4] − 1)^2 + y[2] * (x[1] + x[3] + x[4] − 2)^2 + y[3] * (x[1] + x[2] + x[4] − 3)^2 − y[4] * (x[1] + x[2] + x[3] − 4)^2 − (x[1] * (y[2] + y[3] + y[4] − 1)^2 + x[2] * (y[1] + y[3] + y[4] − 2)^2 − x[3] * (y[1] + y[2] + y[4] − 3)^2 + x[4] * (y[1] + y[2] + y[3] − 4)^2))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (4, 4)
end

function ex_nie21_6_8()
    # saddle points
    # x∗ = −(0.6981, 0.6981, 0.6981), y∗ = (0.4979, 0.4979, 0.4979)

    # unbounded

    dom_nneg(v) = 1
    dom_null(v) = 0

    u1(x, y) = -(sum(x[i]^4 - y[i]^4 + x[i] + y[i] for i in 1:3) + sum(x[i]^3 * y[j]^3 for i in 1:3, j in 1:3 if i != j))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end

function ex_nie21_6_9()
    # saddle points
    # x∗ = (1.2599, 1.2181, 1.3032), y∗ = (1.0000, 1.1067, 0.9036)

    # unbounded

    dom_nneg(v) = (v[1], v[1] * v[2] - 1, v[2] * v[3] - 1)
    dom_null(v) = 0

    u1(x, y) = -(x[1]^3 * y[1] + x[2]^3 * y[2] + x[3]^3 * y[3] - 3 * x[1] * x[2] * x[3] - y[1]^2 - 2 * y[2]^2 - 3 * y[3]^2)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_nie21_6_10()
    # Example 6.10
    # two Nash equilibria
    # x∗ = (0, 1, 0, 0, 0), y∗ = (1, 0, 0, 0, 0),
    # x∗ = (0, 1, 0, 0, 0), y∗ = (0, 1, 0, 0, 0).

    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    A1 = [-4 4 0 3 -4; 3 4 3 -4 -5; -3 0 -2 0 4; -4 -4 -1 3 -5; 4 1 -3 0 -5]
    A2 = [-4 4 1 0 1; -2 -4 2 -3 1; -3 1 1 4 4; 3 -4 0 1 -2; -1 -3 -1 3 -2]
    B = [-2 -4 -2 -5 3; 0 0 2 4 2; 0 -4 -1 -5 3; 1 -3 -4 0 -3; 3 -1 -5 4 -4]

    u1(x, y) = (sum(x[i] * A1[i, j] * x[j] for i in 1:5, j in 1:5) + sum(y[i] * A2[i, j] * y[j] for i in 1:5, j in 1:5) + sum(x[i] * B[i, j] * y[j] for i in 1:5, j in 1:5))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end
