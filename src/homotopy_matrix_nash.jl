using HomotopyContinuation
using LinearAlgebra: dot
using Base.Iterators: flatten, take, drop

function _hc_value(variable, system, path)
    i = findfirst(isequal(variable), system.variables)
    path.solution[i]
end

function extract_solution(s, player_vars, system, path)
    _value(var) = real(_hc_value(var, system, path))

    payoffs = _value.(s)
    strats = [_value.(p) for p in player_vars]

    (payoffs, strats)
end

function _is_br(payoffs, actuals, strats; eps=1e-3)
    players = eachindex(payoffs)
    pays = unilateral_payoffs(payoffs, strats; players)
    maxes = maximum.(pays)

    all(isapprox(actuals[i], maxes[i], atol=eps) for i in players)
end

function _is_strategy(strats; tol=1e-3)
    between_0_1(s) = all((i >= 0 - tol) for i in s)

    all(between_0_1(s) for s in strats)
end

function _is_solution(payoffs, v, x)
    _is_strategy(x) && _is_br(payoffs, v, x)
end

function _is_solution_path(payoffs, s, xs, system, path)
    v, x = extract_solution(s, xs, system, path)
    is_real(path) && _is_solution(payoffs, v, x)
end

function solve_homotopy(payoffs; start_system=:polyhedral)
    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    xs = [first(@var x[d, a]) for (d, a) in enumerate(actions)]
    @var s[players]

    pays = unilateral_payoffs(payoffs, xs; players)

    constr_simplex = [sum(xs[p]) - 1 for p in players]
    constr_best_resp = [xs[i] .* (s[i] .- p) for (i, p) in enumerate(pays)]

    variables = collect(flatten([xs; s]))
    system = System([constr_simplex; constr_best_resp...], variables)

    result = HomotopyContinuation.solve(system;
        show_progress=false,
        compile=false,
        stop_early_cb=p -> _is_solution_path(payoffs, s, xs, system, p),
        start_system)

    sols = [extract_solution(s, xs, system, p) for p in result.path_results]
    filter(s -> _is_solution(payoffs, s...), sols)
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