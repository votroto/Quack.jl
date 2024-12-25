function max_incentive(_, _, values::NTuple{N,F}, best::NTuple{N,F}) where {N,F}
    incentive_max = typemin(F)
    for i in eachindex(values)
        incentive_i = best[i] - values[i]
        if incentive_i > incentive_max
            incentive_max = incentive_i
        end
    end
    incentive_max
end


function unilateral_payoffs_continuous(
    payoffs::NTuple{N, Function},
    actions::NTuple{N},
    weights::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    insert_at(xs, y, i) = [xs[1:i-1]; [y]; xs[i:end]]
    ids = map(eachindex, weights)
    function deviation(i)
        function zz(x)
            total = 0
            others = players[begin:end.!=i]
            for others_ids in Iterators.product(ids[others]...)
                weight = prod(weights[o][i] for (o, i) in zip(others, others_ids))
                ps = [actions[o][i] for (o, i) in zip(others, others_ids)]
                full = insert_at(ps, x, i)
                total += weight * payoffs[i](full...)
            end
            total
        end
    end

    ntuple(i -> deviation(i), N)
end


"""TODO: FIX! No way to know the eps set by user"""
function epspush(xs, y, val, best; eps=1e-6)
    if best - val <= eps
        xs
    else
        [xs; y]
    end
end
