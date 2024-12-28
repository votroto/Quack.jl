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
    payoffs::NTuple{N,Function},
    actions::NTuple{N},
    weights::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    function deviation(i, x)
        part_weights = ntuple(j -> (j == i) ? [1] : weights[j], N)
        part_actions = ntuple(j -> (j == i) ? [x] : actions[j], N)
        prod_actions = Iterators.product(part_actions...)
        prod_weights = Iterators.product(part_weights...)
        total = 0
        for (a, w) in zip(prod_actions, prod_weights)
            total += prod(w) * payoffs[i](a...)
        end
        total
    end

    ntuple(i -> x -> deviation(i, x), N)
end


"""TODO: FIX! No way to know the eps set by user"""
function epspush(xs, y, val, best; eps=1e-6)
    if best - val <= eps
        xs
    else
        [xs; y]
    end
end
