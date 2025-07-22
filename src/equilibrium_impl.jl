const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end


_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])


"""
    nash_equilibrium(payoffs)

Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function subgame_equilibrium(
    payoffs::NTuple{N, Function},
    actionz::NTuple{N};
    optimizer=_default_optimizer
) where {N}
    _simplex_var(i,a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1)

    players = eachindex(payoffs)
    actions = eachindex.(actionz)

    m = Model(optimizer)

    x = ntuple(i -> [_simplex_var(i,a) for a in actions[i]], N)
    @variable(m, w[i=players])

    brfs = ntuple(i -> zeros(NonlinearExpr, actions[i]), N)
    unilateral_payoffs!(brfs, payoffs, actionz, x)


    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in actions[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)

    values, strats
end