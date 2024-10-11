import Symbolics as Sym
using JuMP: NonlinearExpr

max_incentive((_, _, values, best)) = norm(collect(best) - collect(values), Inf)

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x -> getfield.(a, x), fieldnames(eltype(a)))

tuplecat(as...) = vcat(collect.(as)...)

player_variables(domain) = Tuple(unique(vcat(Symbolics.get_variables.(domain)...)))

domains_variables(domains) = map(player_variables, domains)

"""
unilateral_payoffs(payoffs::NTuple, strategies, players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs(
    Z,
    payoffs::NTuple{N,AbstractArray},
    strategies;
    players=eachindex(payoffs)
) where {N}
    E = [zeros(Z, length(strategies[p])) for p in players]
    for p in players
        for i in CartesianIndices(payoffs[p])
            temp = zero(N)
            temp += payoffs[p][i]
            for z in players
                if z == p
                    continue
                end
                temp *= strategies[z][i.I[z]]
            end
            E[p][i.I[p]] += temp
        end
    end
    E
end

function unilateral_payoffz(
    payoffs,
    pures,
    weights;
    variables,
    players=eachindex(payoffs)
)
    insert_at(xs, y, i) = [xs[1:i-1]; [y]; xs[i:end]]
    ids = map(eachindex, weights)
    function deviation_i(i)
        total = 0
        others = players[begin:end.!=i]
        for others_ids in Iterators.product(ids[others]...)
            weight = prod(weights[o][i] for (o, i) in zip(others, others_ids))
            ps = [pures[o][i] for (o, i) in zip(others, others_ids)]
            full = insert_at(ps, variables[i], i)
            payoffs[i](full...)
            total += weight * payoffs[i](full...)
        end
        Sym.simplify(total; expand=true)
    end

    [deviation_i(i) for i in players]
end

# HC fails to solve otherwise
"""Adds a column to a matrix if it does not exist already"""
function uniqpush(xs, y; atol=1e-8)
    if !any(x -> isapprox(collect(y), collect(x); atol), xs)
        [xs; y]
    else
        xs
    end
end
