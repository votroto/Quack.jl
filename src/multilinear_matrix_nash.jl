using JuMP
using Gurobi
using LinearAlgebra
using Symbolics


function unip(
    payoffs::NTuple{N,AbstractArray},
    strategies;
    players=eachindex(payoffs)
) where {N}
    E = [zeros(JuMP.NonlinearExpr, length(strategies[p])) for p in players]
    for p in players
        for i in CartesianIndices(payoffs[p])
            temp = zero(JuMP.NonlinearExpr)
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

function nash_equilibrium(
    payoffs::NTuple{N,<:AbstractArray{T,N}};
    optimizer=_default_optimizer()
) where {T,N}
    _simplex_var(m, a, p) = @variable(m; lower_bound=0, upper_bound=1, base_name="x[$a,$p]")
    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)
    x = [[_simplex_var(m, a, p) for a in actions[p]] for p in players]
    @variable(m, p[players])

    brfs = unip(payoffs, x)
    brfsX = [dot(brfs[i], x[i]) for i in players]

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    Tuple(value.(p)), Tuple([value.(xi) for xi in x])
end

#=
function nash_equilibrium(
    payoffs::NTuple{N, <:AbstractArray{T, N}};
    optimizer=_DEFAULT_OPTIMIZER
) where {T, N}
    _simplify(expr) = Symbolics.simplify(expr; expand=true)
    _eval_sym(expr, dict) = Symbolics.value.(Symbolics.substitute(expr, dict))
    _simplex_var() = @variable(m; lower_bound=0, upper_bound=1, start=0)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    X = [[Symbolics.variable(:X, i, a) for a in actions[i]] for i in players]    
    brfs_sym = _simplify(unilateral_payoffs(payoffs, X))
    brfsX_sym = [_simplify(dot(brfs_sym[i], X[i])) for i in players]
    
    m = Model(optimizer)
    x = [[_simplex_var() for _ in actions[i]] for i in players]
    @variable(m, p[players])
    
    var_map = Dict(vcat(X...) .=> vcat(x...))
    brfs = map(e -> _eval_sym(e, var_map), brfs_sym)
    brfsX = map(e -> _eval_sym(e, var_map), brfsX_sym)

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    Tuple(value.(p)), Tuple([value.(xi) for xi in x])
end
=#