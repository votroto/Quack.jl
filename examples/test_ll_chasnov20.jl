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

function ex_chasnov20_b_1()
    # pure equilibrium at x=0.5, y=0.5

    dom_nneg(x) = (x[1], 1-x[1])
    dom_null(x) = 0

    e = exp(1)
    soft(x) = [e^(10*x)/(e^(10*x)+e^(10*(1-x))), e^(10*(1-x))/(e^(10*x)+e^(10*(1-x)))]

    A = [1 -1; -1 1]

    u1(x, y) = -soft(y[1])' * A * soft(x[1])
    u2(x, y) = -u1(x,y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
#=
utils, nneg, null, dims = ex_chasnov20_b_1()
quack = Quack.quack_oracle(utils, nneg, null, dims, start=([(0.5,)],[(0.5,)]))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

prettyprints(actions, mixed)
=#