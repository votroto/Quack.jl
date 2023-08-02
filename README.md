# Quack

Multiple Oracle algorithm without the oracles (this is silly and **unstable**).

## Example Torus Game (Chasnov 2019)

Running a fixed number of iterations on a two-player game with agents’ joint strategy space on a torus. The game has two pure equilibria at (-1.063, 1.014) and (1.408, -0.325).
```julia
@variables θ[1:2]
α = [1, 1.5]
ϕ = [0, π/8]

p1 = α[1] * cos(θ[1] - ϕ[1]) - cos(θ[1] - θ[2])
p2 = α[2] * cos(θ[2] - ϕ[2]) - cos(θ[2] - θ[1])

pays = (p1, p2)
doms = ((θ[1]^2 ≲ π^2,), (θ[2]^2 ≲ π^2,))
vars = ((θ[1],), (θ[2],))

quack = quack_oracle(pays, doms; variables=vars)
(pure, prob, values, best) = fixed_iters(quack, 5)
```