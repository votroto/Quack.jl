using JuMP
using Gurobi
using LinearAlgebra
using Symbolics

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

    brfs = unilateral_payoffs(payoffs, x)
    brfsX = [dot(brfs[i], x[i]) for i in players]

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    Tuple(value.(p)), Tuple([value.(xi) for xi in x])
end