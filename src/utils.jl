using TensorOperations: ncon
import Symbolics as Sym

max_incentive((_, _, values, best)) = norm(collect(best) - collect(values), Inf)

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x -> getfield.(a, x), fieldnames(eltype(a)))

tuplecat(as...) = vcat(collect.(as)...)

player_variables(domain) = Tuple(unique(vcat(Symbolics.get_variables.(domain)...)))

domains_variables(domains) = @show map(player_variables, domains)

function _bug_ncon(gts, args...; kwargs...)
    ts = collect.(gts) # genericity bug in TensorOperations
    ncon(ts, args...; kwargs...)
end

function _ncon_ids(xs)
    delete_at(xs, i) = xs[begin:end.!=i]
    ncon_ids(i) = [(j == i) ? -j : j for j in xs]
    ncon_js(i) = collect.(delete_at(xs, i))
    id_not_i(i) = xs[begin:end.!=i]

    [(xs[i], id_not_i(i), ncon_ids(i), ncon_js(i)) for i in eachindex(xs)]
end

"""
unilateral_payoffs(payoffs::NTuple, strategies, players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs(
    payoffs::NTuple{N,AbstractArray},
    strategies;
    players=eachindex(payoffs)
) where {N}
    function contract((i, js, np, njs))
        _bug_ncon([payoffs[i], strategies[js]...], [np, njs...])
    end
    map(contract, _ncon_ids(players))
end

function unilateral_payoffs(
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
            ps, variables[i]
            full = insert_at(ps, variables[i], i)
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