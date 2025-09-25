
using JuMP, PolyJuMP, HomotopyContinuation
m = Model(optimizer_with_attributes( PolyJuMP.KKT.Optimizer, "solver" => HomotopyContinuation.SemialgebraicSetsHCSolver()))
using AmplNLWriter, Couenne_jll, Ipopt_jll

  #  m = Model(() -> AmplNLWriter.Optimizer(Ipopt_jll.amplexe))\
  a=0.25
    @variable(m, x)
    @variable(m, y)
    @constraint(m, x >= -1)
    @constraint(m, x <= 1)
    @constraint(m, y >= -1)
    @constraint(m, y <= 1)
    @objective(m, Max, a * x + y - a * x)


    optimize!(m)