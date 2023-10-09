using Base.Iterators: product

_subgame(wcc, v, actions) = map(a -> -ld_r(wcc, a, v), product(actions...))
_subgames(wcc, actions) = map(v -> _subgame(wcc, v, actions), Tuple(wcc.V))

function equilibrium(wcc, actions)
    subproblem = _subgames(wcc, actions)
    nash_equilibrium(subproblem)
end