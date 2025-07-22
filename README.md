# Quack

Multiple Oracle algorithm for general-sum multiplayer continuous games.
The API is **not stable** yet!


## Example Torus Game (Chasnov 2019)

Find an eps-equilibrium of a two-player general-sum game where the agents’ joint strategy space is a torus. The game has two pure equilibria at $(-1.063, 1.014)$ and $(1.408, -0.325)$.
```julia
phi = (0, π/8)
alp = (1, 1.5)

p1(x, y) = alp[1] * cos(x − phi[1]) - cos(x - y)
p2(x, y) = alp[2] * cos(y − phi[2]) - cos(y - x)

dom1(x) = -x^2 + π^2
dom2(y) = -y^2 + π^2

quack = quack_oracle((p1, p2), (dom1, dom2))
iters, (actions, weights, vals, subopt) = until_eps(quack, 1e-3)
```