# Quack

Multiple Oracle algorithm for general-sum multiplayer continuous games.
The API is **not stable** yet! It will be ported from DoubleQuack.
The subgame equilibrium is computed by an LLM port of the logit tool from gambit.


## Example Torus Game (Chasnov 2019)

Find an eps-equilibrium of a two-player general-sum game where the agents’ joint strategy space is a torus. The game has two pure equilibria at $(-1.063, 1.014)$ and $(1.408, -0.325)$.
```julia

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

function run_example(example; eps=1e-3)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims)
    @time cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, eps)

    deltaprints(actions, mixed)

    cnt, (actions, mixed, vals, best)
end

run_example(ex_chasnov20_5_2)
```