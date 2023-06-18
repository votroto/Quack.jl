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

    @show values
end

function oracle(
    cost, 
    domain; 
    variables=Sym.get_variables(cost)
)
    model = NLP.SymNLPModel(cost, domain)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    values = NLP.value(solution, variables)

    stats.objective, values
end

function oracle(
    costs, 
    domains,
    actions,
    weights;
    variables=Sym.get_variables(cost)
)
    players = eachindex(variables)
    unilateral = unilateral_payoffs(costs, actions, weights; variables)
    improved = [
        oracle(unilateral[i], [domains[i]]; variables=variables[i]) 
        for i in players
    ]
    unzip(improved)
end