using NLPModelsIpopt: ipopt

import SymNLPModels as NLP
import Symbolics as Sym

function interior_init(
    domains;
    variables=unique(vcat(Sym.get_variables.(domains)...))
)
    interior = sum(_inequality_to_expr.(domains))

    model = NLP.SymNLPModel(interior, domains)
    stats = ipopt(model; print_level=0)

    solution = NLP.parse_solution(model, stats.solution)
    values = NLP.value.(Ref(solution), variables)

    values
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