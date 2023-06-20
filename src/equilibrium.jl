using Base.Iterators: product

_subgame(payoff, actions) = map(a -> payoff(a...), product(eachcol.(actions)...))
_subgames(payoffs, actions) = map(p -> _subgame(p, actions), payoffs)

"""
    equilibrium(payoffs, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoffs, actions)
	subproblem = _subgames(payoffs, actions)
	nash_equilibrium(subproblem)
end