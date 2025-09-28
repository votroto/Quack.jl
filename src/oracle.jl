using JuMP
using Gurobi

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

function oracle(
    payoffs::NTuple{N,Function},
    dom_nneg::NTuple{N,Function},
    dom_null::NTuple{N,Function},
    actions::NTuple{N,AbstractVector},
    weights::NTuple{N}
) where {N}
    #slice = ups(payoffs, actions, weights)
    slice = unilateral_payoffs_continuous(payoffs, actions, weights)
    #bb = @timed slice = unilateral_payoffs_continuous(payoffs, actions, weights)

    improved = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i])), N)

    maxes = ntuple(i -> improved[i][1], N)
    acts = ntuple(i -> improved[i][2], N)

    maxes, acts
end

function best_response(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=_default_optimizer
)
    m = Model(optimizer)
    @variable(m, x[1:dim])
    set_start_value.(x, start)

    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)
    @objective(m, Max, payoff(x))

    optimize!(m)

    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN, ntuple(i -> NaN, dim)
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
     xx = @timed c = @constraint(m, u <= w, domain = S, maxdegree = order)
     optimize!(m)
   #     @show xx.time

    println(round(solve_time(m); digits=6))
    value(w), moment_matrix(c), termination_status(m)
end

function _set_to_blegat(dom_nneg, dom_null, vars; radius=sqrt(length(vars)))
    zero_poly = sum(0 * xi for xi in vars)
    eqs = vec([e + zero_poly for e in dom_null(vars)])
    ges = vec([e + zero_poly for e in dom_nneg(vars)])
    alg = algebraic_set(eqs)
    basic_semialgebraic_set(alg, ges)
end

function oracle_lasserre(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=optimizer_with_attributes(Mosek.Optimizer, MOI.Silent() => true)
)
        println("las")

    @polyvar x[1:dim]
    u = payoff(x)
    S = _set_to_blegat(dom_nneg, dom_null, x)

    order = maxdegree(u)
    while order <= 8
     #   println("lasi $order")
        zz = @timed val, mom, term = _sdp_lasserre(u, S; order, optimizer)
      #  @show zz.time

         strat = extractatoms(mom, 1e-3)

        if term == JuMP.OPTIMAL && !isnothing(strat)
            _, i = findmax(s.weight for s in strat.atoms)
            return val, tuple((strat.atoms[i]).center...)
        end
        order += 2
    end
    return         NaN, ntuple(i -> NaN, dim)

end
