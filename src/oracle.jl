using JuMP
using Gurobi


function feasible_init(
    domains::NTuple{N,Function};
    optimizer=_silent_optimizer()
) where {N}
    players = eachindex(domains)

    m = Model(optimizer)
    @variable(m, x[i in players])
    @constraint(m, [i in players], domains[i](x[i]) >= 0)

    optimize!(m)

    ntuple(i -> [value(x[i])], N)
end


function oracle(
    payoffs::NTuple{N,Function},
    domains::NTuple{N,Function},
    actions::NTuple{N},
    weights::NTuple{N}
) where {N}
    unilateral = unilateral_payoffs_continuous(payoffs, actions, weights)
    improved = ntuple(i -> best_response(unilateral[i], domains[i]), N)

    maxes = ntuple(i -> improved[i][1], N)
    acts = ntuple(i -> improved[i][2], N)

    maxes, acts
end


function best_response(
    payoff,
    domain;
    optimizer=_silent_optimizer()
)
    m = Model(optimizer)
    @variable(m, x)

    @objective(m, Max, payoff(x))
    @constraint(m, domain(x) >= 0)

    optimize!(m)

    objective_value(m), value(x)
end