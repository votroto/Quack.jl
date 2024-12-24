const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end


_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])

_silent_optimizer() = optimizer_with_attributes(_default_optimizer, MOI.Silent() => true)


"""
    nash_equilibrium(payoffs)

Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function nash_equilibrium(
    payoffs::NTuple{N,AbstractArray{T,N}};
    optimizer=_silent_optimizer()
) where {T,N}
    _simplex_var(N) = @variable(m; lower_bound=0, upper_bound=1, start=1 / N)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)

    pay_ub = ntuple(i -> maximum(payoffs[i]), N)
    pay_lb = ntuple(i -> minimum(payoffs[i]), N)
    x = ntuple(i -> [_simplex_var(N) for a in actions[i]], N)
    @variable(m, w[i=players], lower_bound = pay_lb[i], upper_bound = pay_ub[i])

    brfs = ntuple(i -> zeros(NonlinearExpr, actions[i]), N)
    unilateral_payoffs!(brfs, payoffs, x)

    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in actions[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)

    values, strats
end