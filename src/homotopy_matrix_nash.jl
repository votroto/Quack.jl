using HomotopyContinuation
using LinearAlgebra: dot
using Base.Iterators: flatten, take, drop

function extract_solution(player_vars, sol)
        len = length(player_vars)
        result = Array{Any}(undef, len)
        rs = sol
        for (p, vs) in enumerate(player_vars)
                lvs = length(vs)
                result[p] = take(rs, lvs)
                rs = drop(rs, lvs)
        end
        (sol[end-len+1:end], collect.(result))
end

function is_plausible(strats; eps=1e-3)
        sums_to_one(s) = isapprox(sum(s), 1; rtol=eps)
        between_0_1(s) = all((i >= 0 - eps && i <= 1 + eps) for i in s)

        all(between_0_1(s) && sums_to_one(s) for s in strats)
end

function is_br(payoffs, strats; eps=1e-3)
        players = eachindex(payoffs)

        pays = [
                _bug_ncon([payoffs[i], strats[js]...], [np, njs...])
                for (i, js, np, njs) in _ncon_ids(players)
        ]
        maxes = maximum.(pays)
        actuals = dot.(pays, strats)

        all(isapprox(actuals[i], maxes[i], rtol=eps) for i in players)
end

function solve_homotopy(payoffs; start_system=:polyhedral)
        ne_predicate((v, x)) = is_plausible(x) && is_br(payoffs, x)
        stop_predicate(path) = ne_predicate((nothing, real(path.solution)))
        players = eachindex(payoffs)

        x = [
                [Variable(:x, d, i) for i in a]
                for (d, a) in enumerate(axes(payoffs[1]))
        ]
        @var s[players]

        sum_to_one = [sum(x[p]) - 1 for p in players]
        is_best = [
                x[i] .* (s[i] .- _bug_ncon([payoffs[i], x[js]...], [np, njs...]))
                for (i, js, np, njs) in _ncon_ids(players)
        ]

        vars = collect(flatten([x; s]))
        G = System([sum_to_one; is_best...], variables=vars)

        res = HomotopyContinuation.solve(G;
                show_progress=false,
                compile=false,
                stop_early_cb=stop_predicate,
                start_system)
        outs = real_solutions(res)
        sols = extract_solution.(Ref(x), outs)

        filter(ne_predicate, sols)
end

function multiple_start_homotopy(payoffs)
        _last(xs) = get(xs, length(xs), missing) # why is this not a function?
        pol() = solve_homotopy(payoffs; start_system=:polyhedral)
        deg() = solve_homotopy(payoffs; start_system=:total_degree)

        @coalesce _last(pol()) _last(deg())
end

"""
    nash_equilibrium(payoffs::NTuple)

Compute the Nash equilibrium of a general matrix game using homotopy methods.
"""
function nash_equilibrium(payoffs::NTuple)
        multiple_start_homotopy(payoffs)
end