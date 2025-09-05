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
    actions::NTuple{N, AbstractVector},
    weights::NTuple{N}
) where {N}

    mv1, ac1 = blotto_oracle_one(actions[2], weights[2], 1.0, last(actions[1]))
    mv2, ac2 = blotto_oracle_one(actions[1], weights[1], -1.0, last(actions[2]))

    return (mv1, mv2),(ac1, ac2)

    slice = unilateral_payoffs_continuous(payoffs, actions, weights)
    improved = ntuple(i -> best_response(slice[i], dom_nneg[i], dom_null[i], last(actions[i])), N)

    maxes = ntuple(i -> improved[i][1], N)
    acts = ntuple(i -> improved[i][2], N)

    maxes, acts
end


column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
function blotto_oracle_one(
    actions_opponent,
    weights_opponent,
    vv,
    strt
)
    num_fronts = length(first(actions_opponent))
    num_mixed = length(actions_opponent)

    m = direct_model(_default_optimizer())
    @variable(m, 0<=x[1:num_fronts]<=1)
    set_start_value.(x, strt)

    @variable(m, -1 <= sg[1:num_fronts, 1:num_mixed] <= 1, Int)
    @variable(m, 0 <= ab[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= absq[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, -1 <= df[1:num_fronts, 1:num_mixed] <= 1)
    #xstrt = rand(num_fronts)
    #set_start_value.(x, xstrt ./ sum(xstrt))

    for mi in 1:num_mixed
        for fi in 1:num_fronts
            #GRBaddgenconstrPoly(backend(model), C_NULL, column(x), column(y), 5, p, "")
            @constraint(m, df[fi,mi] == vv * (x[fi] - actions_opponent[mi][fi]))
            GRBaddgenconstrAbs(backend(m), "abs.$fi.$mi", column(ab[fi,mi]), column(df[fi,mi]))
            GRBaddgenconstrPWL(backend(m), "sgn.$fi.$mi", column(df[fi,mi]), column(sg[fi,mi]), 4,[-1.0,0.0,0.0,1.0],[-1.0,-1.0,1.0,1.0])
            GRBaddgenconstrPow(backend(m), "abssq.$fi.$mi", column(ab[fi,mi]), column(absq[fi,mi]), 0.5, "")
        end
    end
@constraint(m, sum(x)==1)
    #@objective(m, Max, vv*sum(weights_opponent[mi] * sum(sg[fi,mi] for fi in 1:num_fronts) for mi in 1:num_mixed))
    @objective(m, Max, vv*sum(weights_opponent[mi] * sum(sg[fi,mi]*absq[fi,mi] for fi in 1:num_fronts) for mi in 1:num_mixed))


    optimize!(m)

    @show JuMP.termination_status(m)
    @show value.(x)
    if  JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
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
    @constraint(m, dom_nneg(x) .>= 0)
    @constraint(m, dom_null(x) .== 0)
    @objective(m, Max, payoff(x))

    set_start_value.(x, start)
    optimize!(m)

    @show JuMP.termination_status(m)
    #@show value.(x)
    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
end