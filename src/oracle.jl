using JuMP
using Gurobi

using JuMP, PolyJuMP, HomotopyContinuation

function feasible_init_one(
    dom_nneg::Function,
    dom_null::Function,
    dim::Int;
    optimizer=_default_optimizer
)
    m = Model(optimizer)
    @variable(m, x[1:dim])
    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)

    optimize!(m)

    [tuple(value.(x)...)]
end

function feasible_init(
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    dims::NTuple{N,Int}
) where {N}
    ntuple(i -> feasible_init_one(dom_nneg[i], dom_null[i], dims[i]), N)
end

function feasible_oracle_init(
    payoffs::NTuple{N,Function},
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    dims::NTuple{N,Int}
) where {N}
    feasible = feasible_init(dom_nneg, dom_null, dims)
    weights = ntuple(i -> [1], N)
    _, responses = oracle(payoffs, dom_nneg, dom_null, feasible, weights)

    ntuple(i -> [responses[i]], N)
end

using AmplNLWriter, Couenne_jll, SCIP_jll, Ipopt_jll

function oracle(
    payoffs::NTuple{N,Function},
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    actions::NTuple{N,AbstractVector},
    weights::NTuple{N}
) where {N}
    slice = unilateral_payoffs_continuous(payoffs, actions, weights)

    #println(";iter")
    #println("gpoly")
    gpr = nothing
    try
       # gpr = ntuple(i -> (NaN,(NaN,)), N) #ntuple(i -> pmaxgbi(slice[i], last(actions[i])), N)
        #gpr = ntuple(i -> pmaxgbi(slice[i], last(actions[i])), N)
    catch
    end
    #println("scip")
    #scr = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i]); optimizer=optimizer_with_attributes(() -> AmplNLWriter.Optimizer("scip"), "display/verblevel" => "0")), N)
    #println("ipopt")
    ipr = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i]); optimizer=optimizer_with_attributes(() -> AmplNLWriter.Optimizer(Ipopt_jll.amplexe))), N)
    ##println("couenne")
    #cor = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i]); optimizer=optimizer_with_attributes(() -> AmplNLWriter.Optimizer(Couenne_jll.amplexe), "print_level" => 0, "output_file" => "/dev/null")), N)
    #println("gurobi")
    improved = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i])), N)
    #println("lasserre")
    #lar = ntuple(i -> oracle_lasserre(slice[i], dom_nneg[i], dom_null[i], last(actions[i])), N)
    #println("kkt")
    #kkt = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i]); optimizer=optimizer_with_attributes( PolyJuMP.KKT.Optimizer, "solver" => HomotopyContinuation.SemialgebraicSetsHCSolver())), N)
    #@show kkt
    #@show improved
    #@show lar

    acc(tt) = round(norm([tt[i][1] for i in 1:N] - [improved[i][1] for i in 1:N]); digits=5)
    @show acc(ipr)
    #println(".val")
    #println(acc(gpr), ", ", acc(scr), ", ", acc(ipr), ", ", acc(cor), ", ", acc(improved), ", ", acc(lar))


    maxes = ntuple(i -> improved[i][1], N)
    acts = ntuple(i -> improved[i][2], N)

    maxes, acts
end


column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))


function best_response(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=_default_optimizer
)
    m = nothing
    redirect_stdout(devnull) do
        m = Model(optimizer)
    end
    @variable(m, x[1:dim])
    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)
    @objective(m, Max, payoff(x))

    set_start_value.(x, start)
    redirect_stdout(devnull) do

        optimize!(m)
    end

    #println(round(solve_time(m); digits=6))
    #@show JuMP.termination_status(m)
    #@show value.(x)
    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL || JuMP.termination_status(m) == JuMP.MOI.LOCALLY_SOLVED
        objective_value(m), tuple(value.(x)...)
    else
        NaN, ntuple(i -> NaN, dim)
    end
end


using DynamicPolynomials
function pmaxgbi(
    payoff,
    start;
    optimizer=_default_optimizer
)

    @polyvar v
    poly_payoff = payoff([v])

    deg = maxdegree(poly_payoff)
    coeffs = coefficients(poly_payoff, monomials(v, 0:deg))

    m = direct_model(_default_optimizer())
    @variable(m, -1 <= x <= 1)
    set_start_value.(x, start)

    @variable(m, y)

    GRBaddgenconstrPoly(backend(m), "pcon", column(x), column(y), length(coeffs), reverse(coeffs), "")

    @objective(m, Max, y)
    optimize!(m)

    #println(m)
    #@show JuMP.termination_status(m)
    println(round(solve_time(m); digits=6))
    #@show value.(x)
    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
end


using JuMP
using SumOfSquares
using MosekTools
using DynamicPolynomials

function _sdp_lasserre(u, S; order=maxdegree(u), optimizer=Mosek.Optimizer)
    m = SOSModel(optimizer)

    @variable(m, w)
    @objective(m, Min, w)
    c = @constraint(m, u <= w, domain = S, maxdegree = order)
    optimize!(m)

    println(round(solve_time(m); digits=6))
    value(w), moment_matrix(c), termination_status(m)
end

function _set_to_blegat(dom_nneg, dom_null, vars; radius=sqrt(length(vars)))
    zero_poly = sum(0 * xi for xi in vars)
    ball_poly = radius - sum(xi^2 for xi in vars)
    eqs = vec([e + zero_poly for e in dom_null(vars)])
    ges = [ball_poly; [1 - xi^2 for xi in vars]...; [e + zero_poly for e in dom_nneg(vars)]...]
    alg = algebraic_set(eqs)
    basic_semialgebraic_set(SemialgebraicSets.FullSpace(), ges)
end

function oracle_lasserre(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=optimizer_with_attributes(Mosek.Optimizer, MOI.Silent() => true)
)
    @polyvar x[1:dim]
    u = payoff(x)
    S = _set_to_blegat(dom_nneg, dom_null, x)

    order = maxdegree(u)
    while order <= 8
        val, mom, term = _sdp_lasserre(u, S; order, optimizer)
        strat = extractatoms(mom, 1e-3)
        #@show expectation(u, strat), val

        if term == JuMP.OPTIMAL && !isnothing(strat)
            @show expectation(u, strat), val
            _, i = findmax(s.weight for s in strat.atoms)
            return val, tuple((strat.atoms[i]).center...)
        end
        order += 1
    end
    return         NaN, ntuple(i -> NaN, dim)

end
