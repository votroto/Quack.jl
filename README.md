# Quack

Multiple Oracle algorithm without the oracles (this is silly).

## VERY UNSTABLE

Example of a polynomial guessing game `(x-y)^2` on the unit square:
```jl
@variables x y

pays = ((x-y)^2, -(x-y)^2)
doms = [x^2 ≲ 1, y^2 ≲ 1]
vars = [(x,), (y,)]

quack = quack_oracle(pays, doms; variables=vars)
(actions, mixed, values, best) = fixed_iters(quack, 5)
```