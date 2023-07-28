using NLPModelsIpopt: ipopt

import SymNLPModels as NLP
import Symbolics as Sym

function interior_init(
    domains;
    variables=domains_variables(domains)
)
    player_vals(sol, vs) = map(v -> NLP.value(sol, v), vs)
    all_inits(sol) = map(vs -> [player_vals(sol, vs)], variables)

    domcat = collect(tuplecat(domains...))
    varcat = tuplecat(variables...)
    interior = Sym.Num(sum(_inequality_to_expr.(domcat)))

    model = NLP.SymNLPModel(interior, domcat; variables=varcat)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    
    all_inits(solution)
end

function oracle(
    payoff,
    domain;
    variables=player_variables(domain)
)
    model = NLP.SymNLPModel(-payoff, collect(domain); variables=collect(variables))
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    values =  map(v -> NLP.value(solution, v), variables)

    -stats.objective, Tuple(values)
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