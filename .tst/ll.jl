using JuMP
using Gurobi

logistic(x) = 1/(1+exp(-x))

m = Model(Gurobi.Optimizer)
@variable m 0 <= x <= 0
@constraint m 0.5 == logistic(x)

optimize!(m)

println(m)