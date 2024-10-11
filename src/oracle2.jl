using PolyJuMP
using SumOfSquares
using JuMP
using Gurobi
using AmplNLWriter
using Couenne_jll

using MosekTools
using DynamicPolynomials
using SemialgebraicSets

const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
end

function _default_optimizer()
    grb = Gurobi.Optimizer(Gurobi.Env())
    #MOI.set(grb, MOI.RawOptimizerAttribute("OutputFlag"), 0)
    MOI.set(grb, MOI.RawOptimizerAttribute("Threads"), 1)
    () -> PolyJuMP.QCQP.Optimizer(grb)

#    () -> AmplNLWriter.Optimizer(Couenne_jll.amplexe)
end


function _sos_optimizer()
    return Mosek.Optimizer
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
    ntuple(p -> [Tuple(value.(vs[p]))], length(players))
end

function wasserstein(supp, supq, p, q; optimizer=_default_optimizer())
    rho(x, y) = norm(collect(supp[x]) - collect(supq[y]))
    idsp = eachindex(supp)
    idsq = eachindex(supq)

    m = Model(optimizer)
    @variable(m, mu[idsp, idsq] >= 0)
    @constraint(m, sum(mu) == 1)
    @constraint(m, [x in idsp], sum(mu[x, :]) == p[x])
    @constraint(m, [y in idsq], sum(mu[:, y]) == q[y])
    @objective(m, Min, sum(mu[x, y] * rho(x, y) for x in idsp, y in idsq))
    optimize!(m)

    objective_value(m)
end

function oracle(
    payoffs,
    domains,
    actions,
    weights;
    variables=player_variables.(domains)
)
    players = eachindex(variables)
    unilateral = unilateral_payoffz(payoffs, actions, weights; variables)
    improved = [
        oracle(unilateral[i], domains[i]; variables=variables[i])
        for i in players
    ]
    as, bs = unzip(improved)
    Tuple(as), Tuple(bs)
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

function sos(p, dom, deg, solver)
    model = SOSModel(solver)
    #set_silent(model)
    @variable(model, α)
    @objective(model, Min, α)
    @constraint(model, c, p <= α, domain = dom, maxdegree = deg)
    optimize!(model)

    ν = moment_matrix(c)
    if result_count(model) >= 1
        objective_value(model), atomic_measure(ν, 1e-3)
    end
end


function oracle_(
    payoff,
    domain;
    variables=player_variables(domain),
    optimizer=_sos_optimizer()
)
    @polyvar vs[1:length(variables)]

    ss = [Symbolics.substitute(-_inequality_to_expr(d), variables .=> vs) for d in domain]
    se = SemialgebraicSets.basic_semialgebraic_set(SemialgebraicSets.FullSpace(), ss)
    p = Symbolics.substitute(payoff, variables .=> vs)  

    m, meas = sos(p, se, 8, optimizer)

    m, Tuple(first(meas.atoms).center)
end