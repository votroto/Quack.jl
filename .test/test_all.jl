include("../src/Quack.jl")
using Revise



function _guess(example; eps=1e-3, start=start)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims;start)
    Quack.fixed_iters(quack, 12)
end

function _guess_nn()
    for i in -1:0.1:1.0
        for j in -1:0.1:1.0
            _guess(ex_parrilo06_2_1; start=([(i,)],[(j,)]))
            println()
        end
        println()
    end
end



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


# Convergence Analysis of Gradient-Based Learning in Continuous Games
# Benjamin Chasnov, Lillian Ratliff, Eric Mazumdar, Samuel Burden

# Two-player general-sum continuous game played on an interval ("torus").

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
    # also in: On Finding Local Nash Equilibria (and only Local Nash Equilibria) in Zero-Sum Games, ERIC MAZUMDAR, S. SHANKAR SASTRY and MICHAEL I. JORDAN

    dom_nneg(x) = 1 - x[1]^2
    dom_null(x) = 0

    u1(x, y) = -(4*x[1]^2-(y[1]-3*x[1]+x[1]^3/20)^2-y[1]^4/10) * exp(-(x[1]^2+y[1]^2)/100)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


# Games of strategy: theory and applications
# Dresher, Melvin

function ex_dresher61_pg110()
    # mixed NE
    # (0.0,), 50.0 %; (1.0,), 50.0 %;
    # (0.5,), 100.0 %;
    # v=1/4

    dom_nneg(v) = (v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = (x[1] - y[1])^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_dresher61_pg111()
    # v = 1/6

    dom_nneg(v) = (v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = sqrt((y[1]-x[1])^2)*(1-sqrt((y[1]-x[1])^2))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

# Gale, D., & Gross, O. (1958). A note on polynomial and separable games.
# Pacific J. Math., 8 (4), 735–741. https://projecteuclid.org:443/euclid.pjm/1103039699

function gale_gross(x, y, spectrum_x, spectrum_y, weights_x, weights_y, pts_x, pts_y)
    sqnrmdist(x, y) = sum((x[i]-y[i])^2 for i in eachindex(x))

    function _f(x, sx)
        prod([sqnrmdist(x, s) for s in sx])
    end
    function _f(i, x, sx)
        prod([sqnrmdist(x, s) / sqnrmdist(sx[i], s) for s in sx if s != sx[i]])
    end
    function _ϕ(x, as)
        prod([sqnrmdist(x, s) for s in as])
    end
    function _ϕ(i, x, as)
        prod([sqnrmdist(x, s) for s in as if s != as[i]])
    end

    μs = weights_x
    νs = weights_y
    m = length(μs)
    n = length(νs)
    αs = pts_x
    βs = pts_y

    f(i, x) = _f(i, x, spectrum_x)
    g(i, y) = _f(i, y, spectrum_y)
    f(x) = _f(x, spectrum_x)
    g(y) = _f(y, spectrum_y)
    ϕ(i, x) = _ϕ(i, x, αs)
    ψ(i, y) = _ϕ(i, y, βs)
    ϕ(x) = _ϕ(x, αs)
    ψ(y) = _ϕ(y, βs)

    m1 = +f(x)ϕ(x) * (g(y)ϕ(x) + sum([(g(j, y) - νs[j]) * ϕ(j, x) for j = 1:n]))
    m2 = -g(y)ψ(y) * (f(x)ψ(y) + sum([(f(i, x) - μs[i]) * ψ(i, y) for i = 1:m]))
    m3 = -(f(x)ϕ(x))^2 + (g(y)ψ(y))^2

    m1 + m2 + m3
end

function ex_gross58_poly()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    sup = [[0.5]]
    wgt = [1.0]

    pts = [[1.0], [0.0]]

    g(x, y) = gale_gross(x, y, sup, sup, wgt, wgt, pts, pts)
    u1(x, y) = g(x, y)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


# Russell Golman and Scott E Page. “General Blotto: Games Of Allocative Strategic
# Mismatch”. In: Public Choice 138.3-4 (2009), pp. 279–299

function all_combinations(max)
    result = []

    function combine(current, start, k)
        if length(current) == k
            push!(result, current)
        end
        for i in start:max
            combine([current...; i], i + 1, k)
        end
    end

    for k in 1:max
        combine([], 1, k)
    end

    return result
end

function ex_golman09_isolated_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt(x^2) * x

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_pairs_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt((x)^2) * x

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:4 for k in (j+1):5) + sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_sets_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt((x)^2) * x

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(5))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end


function ex_golman09_isolated_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_pairs_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:4 for k in (j+1):5) + sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_sets_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(5))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end


function ex_golman09_isolated_p02_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5], 1-v[1], 1-v[2], 1-v[3], 1-v[4], 1-v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    #f(x::Float64) = sign(x)*abs(x)^0.2
    f(x) = x/(((x^2)^0.4)+1e-6)

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end



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


# Separable Network Games with Compact Strategy Sets
# Tomáš Kroupa, Sara Vannucci, Tomáš Votroubek

function ex_kroupa21_5()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x, y, z) = −2*x*y^2 + 5*x*y − y −2*x^2 − 4*x*z − 2*z
    v2(x, y, z) = 2*x*y^2 − 2*x^2 − 5*x*y + y −2*y*z^2 − 2*y^2 + 5*y*z
    v3(x, y, z) = 4*x^2 + 4*x*z + 2*z + 2*y*z^2 + 2*y^2 − 5*y*z

    u1(x, y, z) = v1(x[1], y[1], z[1])
    u2(x, y, z) = v2(x[1], y[1], z[1])
    u3(x, y, z) = v3(x[1], y[1], z[1])

    (u1, u2, u3), (dom_nneg, dom_nneg, dom_nneg), (dom_null, dom_null, dom_null), (1, 1, 1)
end

function ex_kroupa21_6()
	N = 1:4
	a = [0.5, 0.8]
    offset = sum(a) / length(N)

	dom_nneg1(x) = (x[1], x[2] , x[3], x[4])
	dom_nneg2(y) = (y[1], y[2] , y[3], y[4])
	dom_nneg3(u) = (u[1], u[2])
	dom_nneg4(v) = (v[1], v[2])

	dom_null1(x) = (x[1] + x[2] + x[3] + x[4] - a[1])
	dom_null2(y) = (y[1] + y[2] + y[3] + y[4] - a[2])
	dom_null3(u) = (u[1] + u[2] - 1)
	dom_null4(v) = (v[1] + v[2] - 1)

    eff = (
	    (x,y) -> (1-y^2)*0.7x^2,
	    (x,y) -> (1-y)^2*(1.4x - 0.7x^2),
	    (x,y) -> (1-y^2)*(1.8x - 0.9x^2),
	    (x,y) -> (1-y)^2*0.9x^2
    )

	u1(x,y, u,v) = a[1] - eff[1](x[1], u[1]) - eff[2](x[2], u[2]) - eff[3](x[3], v[1]) - eff[4](x[4], v[2]) - offset
	u2(x,y, u,v) = a[2] - eff[1](y[1], u[1]) - eff[2](y[2], u[2]) - eff[3](y[3], v[1]) - eff[4](y[4], v[2]) - offset
	u3(x,y, u,v) = eff[1](x[1], u[1]) + eff[2](x[2], u[2]) + eff[1](y[1], u[1]) + eff[2](y[2], u[2]) -  offset
	u4(x,y, u,v) = eff[3](x[3], v[1]) + eff[4](x[4], v[2]) + eff[3](y[3], v[1]) + eff[4](y[4], v[2])  -  offset


    (u1, u2, u3, u4), (dom_nneg1, dom_nneg2, dom_nneg3, dom_nneg4), (dom_null1, dom_null2, dom_null3, dom_null4), (4, 4, 2, 2)
end



# Optimistic Mirror Descent In Saddle-Point Problems: Going The Extra (Gradient) Mile
# Panayotis Mertikopoulos, Bruno Lecouat, Houssam Zenati, Chuan-Sheng Foo, Vijay Chandrasekhar, Georgios Piliouras

function ex_mertikopoulos18_fig1()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x,y) = ((x-0.5)*(y-0.5)+1/3*exp(-(x-1/4)^2-(y-3/4)^2))

    u1(x,y) = v1(x[1], y[1])
    u2(x,y) = -u1(x,y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_mertikopoulos18_2_2()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x,y) = -(x^4*y^2+x^2+1)*(x^2*y^4-y^2+1)

    u1(x,y) = v1(x[1], y[1])
    u2(x,y) = -u1(x,y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


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



# Nash equilibrium seeking over digraphs with row-stochastic matrices and network-independent step-sizes
# arXiv:2309.07897 [cs.GT]

# Six player general-sum game, or:
#   an N-player noncooperative game, based on a general network
#   OSNR model with linear pricing and OSNR-like utility.

function ex_nguyen23_iv()
    # NE
    # x∗ = [0.3329, 0.3375, 0.3412, 0.2305, 0.2361, 0.2421]

    dom_nneg(x) = -x[1]^2 + 2.2 * x[1] - 0.4
    dom_null(x) = 0

    n0 = 0.43 * 1e-6
    b = [0.5, 0.51, 0.52, 0.3, 0.31, 0.32]
    a = [0.261, 0.494, 0.107, 0.366, 0.208, 0.305]

    p = 1e-5 * [
        7.463 7.378 7.293 7.210 7.127 6.965
        7.451 7.365 7.281 7.198 7.115 6.953
        7.438 7.353 7.269 7.186 7.103 6.942
        7.427 7.342 7.258 7.175 7.093 6.931
        7.409 7.324 7.240 7.157 7.075 6.914
        7.387 7.303 7.219 7.136 7.055 6.894
    ]

    g = [
        (x...) -> x[i] / (n0 + sum(p[i, j] * x[j] for j in 1:6))
        for i in 1:6
    ]

    v = [
        (x...) -> -(x[i] - b[i] * (log(1 + (a[i] * g[i](x...)) / (1 - p[i, i] * g[i](x...))) - x[i]))
        for i in 1:6
    ]

    u = [(a, b, c, d, e, f) -> v[i](a[1], b[1], c[1], d[1], e[1], f[1]) for i in 1:6]

    tuple(u...), ntuple(i -> dom_nneg, 6), ntuple(i -> dom_null, 6), ntuple(i -> 1, 6)
end


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


# Proceedings of the 45th IEEE Conference on Decision and Control
# DOI: 10.1109/CDC.2006.377261
# Polynomial games and sum of squares optimization
# Pablo A. Parrilo

# Examples of two-player zero-sum polynomial games on [-1, 1]

function ex_parrilo06_2_1()
    # Example 2.1
    # mixed NE
    # (1.0,), 50.0 %; (-1.0,), 50.0 %;
    # (0.0,), 100.0 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = (x[1] - y[1])^2
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


function ex_parrilo06_3_1()
    # Example 3.1
    # NE
    # (4^(-2/4),), 100.0 %;
    # (4^(-1/4),), 100.0 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = 2 * x[1] * y[1]^2 - x[1]^2 - y[1]
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


function ex_parrilo06_3_2()
    # Example 3.2
    # mixed NE
    # (0.2,), 100.0 %;
    # (1.0,), 78 %; (-1.0,), 22 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = 5 * x[1] * y[1] - 2 * x[1]^2 - 2 * x[1] * y[1]^2 - y[1]
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


# Characterization and computation of local Nash equilibria in continuous games
# Lillian J. Ratliff; Samuel A. Burden; S. Shankar Sastry

function ex_ratliff13_location()
    # NE
    # x=1; y=-1.1
    # x=-1; y=1.1
    # x=0; y=pi ???

    dom_nneg(x) = π^2 - x[1]^2
    dom_null(x) = 0

    alp = (1, 1.05)

    u1(x, y) = cos(x[1]) - alp[1]*cos(x[1] - y[1])
    u2(x, y) = cos(y[1]) - alp[2]*cos(y[1] - x[1])

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

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


# Characterization and Computation of Correlated Equilibria in Infinite Games
# Noah D. Stein, Pablo A. Parrilo, and Asuman Ozdaglar

function ex_stein07_4_3_1()
    # correlated NE
    # x = 1, y = 1

    dom_nneg(v) = (1 + v[1], 1 - v[1])
    dom_null(v) = 0

    u1(x, y) = 0.596 * x[1]^2 + 2.072 * x[1] * y[1] - 0.394 * y[1]^2 + 1.360 * x[1] - 1.200 * y[1] + 0.554
    u2(x, y) = -0.108 * x[1]^2 + 1.918 * x[1] * y[1] - 1.044 * y[1]^2 - 1.232 * x[1] + 0.842 * y[1] - 1.886

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end


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


# Sarath Yasodharan and Patrick Loiseau. 2019.
# Nonzero-sum adversarial hypothesis testing games.

function ex_yasodharan19()
    dom_nneg1(x) = (x[1], x[2], 1 - x[1], 1 - x[2])
    dom_nneg2(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    m = 1
    gamma = 0.2
    u1(x,y) = sum(x[i+1] * binomial(m,i) * y[1]^i*(1-y[1])^(m-i) for i in 0:m) - (gamma/2.0^m)*sum(x[i+1] * binomial(m,i) for i in 0:m) - 1
    u2(x,y) = -(y[1]-0.8)^2 + sum(binomial(m,i)*(1-x[i+1])*y[1]^i*(1-y[1])^(m-i) for i in 0:m)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (m+1, 1)
end


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
    # x∗ = (0.2540, 0.2097) × 10^−4, y∗ = (0.2487, 0.2944) × 10^−4 ???

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


function _ex_zhou19_5_4_ii()
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

    # [0.43513140940430417, 0.636655580488325, 0.636655580488325]
    # [0.5255286571112407, 0.8507758992243892]

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
    # x = [0.8812945920343842, 0.9716157415160604]
    # y = [1.0174554472964583]

    dom_nneg1(v) = (v[1]-1e-8, v[2]-1e-8, pi / 2 - v[1], pi / 2 - v[2])
    dom_null1(v) = 0

    dom_nneg2(v) = (v[1]-1e-8, pi / 2 - v[1] + 1e-8)
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

