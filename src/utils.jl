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


"""Adds a column to a matrix if it does not exist already"""
function uniqpush(xs, y; atol=1e-8)
    if !any(x -> isapprox(collect(y), collect(x); atol), xs)
        [xs; y]
    else
        xs
    end
end
