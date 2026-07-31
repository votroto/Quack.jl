using LogitNash

"""
    nash_equilibrium(payoffs)

Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function subgame_equilibrium(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector}
) where {N}

    players = eachindex(payoffs)
    dims = ntuple(i -> length(actions[i]), N)

    pay = ntuple(i -> Array{Float64,N}(undef, dims...), N)

    for i in Iterators.product(eachindex.(actions)...)
        for p in players
            pay[p][i...] = payoffs[p](getindex.(actions, i)...)
        end
    end

    nes, status = LogitNash.nash(pay)

    wout = zeros(N)
    for i in Iterators.product(eachindex.(actions)...)
        for p in players
            w = prod(nes[z][i[z]] for z in players)
            uu = payoffs[p](getindex.(actions, i)...)
            wout[p] += w * uu
        end
    end
    return tuple(wout...), nes

end
