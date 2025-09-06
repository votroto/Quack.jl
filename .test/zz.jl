using Gurobi
using JuMP

using SCIP
using Couenne_jll
using AmplNLWriter


    m = Model(() -> AmplNLWriter.Optimizer("scip"))
    @variable(m, -1 <= x <= 1)
    @objective(m, Min, abs(x-0.3)^0.5)

    optimize!(m)

    @show value(x)
#=
A = 10

m = Model(Gurobi.Optimizer)
@variable m -5.12 <= x <= 5.12
@variable m -5.12 <= y <= 5.12

@objective m Max 20 + (x^2 - 10*cos(2*pi*x)) +  (y^2 - 10*cos(2*pi*y))

optimize!(m)
=#

ackley_dom(x) = (32.768 - x, 32.768 + x)
ackley_fun(x, a=20, b=0.2, c=2*pi, d=length(x)) = -a * exp(-b*sqrt(1/d*sum(x[i]^2 for i in 1:d))) - exp(1/d*sum(cos(c*x[i]) for i in 1:d)) + a + e

bukin6_dom1(x) = (15+x, -5-x)
bukin6_dom2(x) = (3+x, 3-x)
bukin6_fun(x) = 100*sqrt(abs(x[2]-0.01*x[1]^2)) + 0.01*abs(x[1]+10)

corssit_dom(x) = (10 + x, 10 - x)
corssit_fun(x) = -0.0001 * (abs(sin(x[1])*sin(x[2])*exp(abs(100 - sqrt(x[1]^2+x[2]^2)/pi)))+1)^0.1

drop_fun(x) = -(1 + cos(12*sqrt(x1^2+x2^2)))/( 0.5*(x1^2+x2^2) + 2)

#=
egg_fun(x) =
  term1 <- (-(x2+47) * sin(sqrt(abs(x2+x1/2+47))))
  term2 <- (-x1 * sin(sqrt(abs(x1-(x2+47)))))

  y <- term1 + term2
  =#
#function ex_test_ackley()
#    dom_nneg(x) = ackley_dom(x[1])
#    dom_null(x) = 0
#
#    u1(x, y) = ackley_fun([x[1],y[1]])
#    u2(x, y) = -u1(x, y)
#
#    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
#end