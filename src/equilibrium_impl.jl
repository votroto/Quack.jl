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
    actions::NTuple{N, AbstractVector};
    optimizer=_default_optimizer
) where {N}
    _simplex_var(i,a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1)

    players = eachindex(payoffs)
    act_ids = eachindex.(actions)

    m = Model(optimizer)
    #column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
    #m = direct_model(optimizer())

    x = ntuple(i -> [_simplex_var(i,a) for a in act_ids[i]], N)

    #o = @variable(m, o >= 0)
    #GRBaddgenconstrNorm(backend(m), "mnorm", column(o), sum(length.(act_ids)), [column(x[p][a]) for p in players for a in act_ids[p]], 0)

    @variable(m, w[i=players])

    brfs = ntuple(i -> zeros(NonlinearExpr, act_ids[i]), N)
    unilateral_payoffs!(brfs, payoffs, actions, x)

    #@show actions
    #for p in players
    #    println()
    #    println.(brfs[p])
    #end

    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in act_ids[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    #@objective(m, Min, o)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)


    #@show strats
    #println()
    values, strats
end


#=
function subgame_equilibrium_low_norm(
    payoffs::NTuple{N, Function},
    actions::NTuple{N, AbstractVector},
    weights;
    optimizer=_default_optimizer
) where {N}
    _simplex_var(i,a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1, start=weights[i][a])

    players = eachindex(payoffs)
    act_ids = eachindex.(actions)

    column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
    m = direct_model(optimizer())

    x = ntuple(i -> [_simplex_var(i,a) for a in act_ids[i]], N)

    o = @variable(m, o >= 0)
    GRBaddgenconstrNorm(backend(m), "mnorm", column(o), sum(length.(act_ids)), [column(x[p][a]) for p in players for a in act_ids[p]], 0)

    @variable(m, w[i=players])

    brfs = ntuple(i -> zeros(NonlinearExpr, act_ids[i]), N)
    unilateral_payoffs!(brfs, payoffs, actions, x)

    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in act_ids[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    @objective(m, Min, o)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)


    #@show strats
    #println()
    values, strats
end=#