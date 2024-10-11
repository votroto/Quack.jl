using JuMP
using Gurobi
using LinearAlgebra
using Symbolics

function nash_equilibrium(
    payoffs::NTuple{N,<:AbstractArray{T,N}};
    optimizer=_default_optimizer()
) where {T,N}
    _simplex_var(m, a, nn,p) = @variable(m; lower_bound=0, upper_bound=1, start=1/nn, base_name="x[$a,$p]")
    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)
    x = [[_simplex_var(m, a, length(actions[p]), p) for a in actions[p]] for p in players]
    @variable(m, minimum(payoffs[i]) <= p[i in players] <= maximum(payoffs[i]))

    brfs = unilateral_payoffs(NonlinearExpr, payoffs, x)
    brfsX = [dot(brfs[i], x[i]) for i in players]

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p) )
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    Tuple(value.(p)), Tuple([value.(xi) for xi in x])
end