using Base.Iterators: product

"""
unilateral_payoffs(payoffs::NTuple, strategies::NTuple; players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs!(
    result::NTuple{N},
    payoffs::NTuple{N, Function},
    actions::NTuple{N, AbstractVector},
    strategies::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    evalpi(p,i) = payoffs[p](getindex.(actions, i)...)

    for i in Iterators.product(eachindex.(actions)...)
        for p in players
            w = prod(strategies[z][i[z]] for z in players if z != p)
            result[p][i[p]] += w * evalpi(p, i)
        end
    end
    result
end

"""
    equilibrium(payoffs, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoffs, actions)
    return subgame_equilibrium(payoffs, actions)
end