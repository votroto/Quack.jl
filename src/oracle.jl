using PolyJuMP
using JuMP
using Gurobi

const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
end

function _default_optimizer()
    grb = Gurobi.Optimizer(GRB_ENV_REF[])
    #MOI.set(grb, MOI.RawOptimizerAttribute("OutputFlag"), 0)
    MOI.set(grb, MOI.RawOptimizerAttribute("Threads"), 1)
    () -> PolyJuMP.QCQP.Optimizer(grb)
end

function interior_init(
    domains;
    variables=domains_variables(domains),
    optimizer=_default_optimizer()
)
    players = eachindex(variables)

    m = Model(optimizer)
    vs = [[@variable(m) for i in eachindex(pv)] for pv in variables]

    varmap = collect(tuplecat(variables...)) .=> vcat(vs...)
    domcat = collect(tuplecat(domains...))

    exs = [Symbolics.substitute(_inequality_to_expr(d), varmap) for d in domcat]
    interior = sum(exs)

    @objective(m, Min, interior)
    @constraint(m, [e in exs], e <= 0)

    optimize!(m)

    Tuple([value.(vs[p]) for p in players])
end

function oracle(
    payoff,
    domain;
    variables=player_variables(domain),
    optimizer=_default_optimizer()
)
    m = Model(optimizer)
    @variable(m, vs[i in eachindex(variables)])

    @objective(m, Max, Symbolics.substitute(payoff, variables .=> vs))
    @constraint(m, [d in domain], Symbolics.substitute(_inequality_to_expr(d), variables .=> vs) <= 0)

    optimize!(m)

    objective_value(m), Tuple(value.(vs))
end

function oracle(
    payoffs,
    domains,
    actions,
    weights;
    variables=player_variables.(domains)
)
    players = eachindex(variables)

    unilateral = unilateral_payoffs(payoffs, actions, weights; variables)
    improved = [
        oracle(unilateral[i], domains[i]; variables=variables[i])
        for i in players
    ]
    as, bs = unzip(improved)
    Tuple(as), Tuple(bs)
end