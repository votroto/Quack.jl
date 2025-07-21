using Gurobi
using JuMP

function logistic(x)
    1/(1+exp(-x))
end

m = Model(Gurobi.Optimizer)
@variable(m, 1 <= x <= 2)
@objective m Max logistic(x)
optimize!(m)

println(m)

