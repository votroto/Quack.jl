using NLPModelsIpopt: ipopt

import SymNLPModels as NLP
import Symbolics as Sym

function interior_init(
    domains;
    variables=Sym.get_variables.(domains)
)
    varcat = unique(vcat(variables...))
    interior = sum(_inequality_to_expr.(domains))

    model = NLP.SymNLPModel(interior, domains; variables=varcat)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    values = [NLP.value.(Ref(solution), vs) for vs in variables]

    values
end

function oracle(
    payoff, 
    domain; 
    variables=Sym.get_variables(payoff)
)
    model = NLP.SymNLPModel(-payoff, domain; variables)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    values = NLP.value(solution, variables)

    stats.objective, values
end

function oracle(
    payoffs, 
    domains,
    actions,
    weights;
    variables=Sym.get_variables(cost)
)
    players = eachindex(variables)
    unilateral = unilateral_payoffs(payoffs, actions, weights; variables)
    improved = [
        oracle(unilateral[i], [domains[i]]; variables=collect(variables[i]))
        for i in players
    ]
    unzip(improved)
end