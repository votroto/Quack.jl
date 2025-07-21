using Base.Iterators: product

"""
unilateral_payoffs(payoffs::NTuple, strategies::NTuple; players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs!(
    result::NTuple{N},
    payoffs::NTuple{N, Function},
    actions::NTuple{N},
    strategies::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    evalpi(p,i) = payoffs[p](getindex.(s.actions, i.I)...)
    for p in players
        for i in CartesianIndices(length.(s.actions))
            w = prod(strategies[z][i.I[z]] for z in players if z != p)
            result[p][i.I[p]] += w * evalipi(payoffs, p, i)
        end
    end
    result
end

"""
    equilibrium(payoffs, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoffs, actions)
    subgame_equilibrium(payoffs, actions)
end