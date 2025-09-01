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

    mv1, ac1 = blotto_oracle_three(actions[2], weights[2], 1.0)
    mv2, ac2 = blotto_oracle_three(actions[1], weights[1], -1.0)

    #_mv1, _ac1 = blotto_oracle_three(actions[2], weights[2], 1.0)
    #_mv2, _ac2 = blotto_oracle_three(actions[1], weights[1], -1.0)


    #@show mv1, ac1
    #@show _mv1, _ac1
    #
    #@show mv2, ac2
    #@show _mv2, _ac2

    return (mv1, mv2), (ac1, ac2)

    #@show x = only(actions[1][argmax(weights[1])])
    #@show y = only(actions[2][argmax(weights[2])])
    #
    #armx = ((y/2,), (x,))
    #mx = (payoffs[1](armx...), payoffs[2](armx...))
    #
    #return mx, armx

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
    vv
)
    num_fronts = length(first(actions_opponent))
    num_mixed = length(actions_opponent)

    m = direct_model(_default_optimizer())
    @variable(m, 0 <= x[1:num_fronts] <= 1)

    @variable(m, -1 <= sg[1:num_fronts, 1:num_mixed] <= 1, Int)
    @variable(m, 0 <= ab[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= absq[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, -1 <= df[1:num_fronts, 1:num_mixed] <= 1)
    xstrt = rand(num_fronts)
    set_start_value.(x, xstrt ./ sum(xstrt))

    for mi in 1:num_mixed
        for fi in 1:num_fronts
            #GRBaddgenconstrPoly(backend(model), C_NULL, column(x), column(y), 5, p, "")
            @constraint(m, df[fi, mi] == vv * (x[fi] - actions_opponent[mi][fi]))
            GRBaddgenconstrAbs(backend(m), "abs.$fi.$mi", column(ab[fi, mi]), column(df[fi, mi]))
            GRBaddgenconstrPWL(backend(m), "sgn.$fi.$mi", column(df[fi, mi]), column(sg[fi, mi]), 4, [-1.0, 0.0, 0.0, 1.0], [-1.0, -1.0, 1.0, 1.0])
            GRBaddgenconstrPow(backend(m), "abssq.$fi.$mi", column(ab[fi, mi]), column(absq[fi, mi]), 0.5, "")
        end
    end
    @constraint(m, sum(x) == 1)
    #@objective(m, Max, vv*sum(weights_opponent[mi] * sum(sg[fi,mi] for fi in 1:num_fronts) for mi in 1:num_mixed))
    @objective(m, Max, vv * sum(weights_opponent[mi] * sum(sg[fi, mi] * absq[fi, mi] for fi in 1:num_fronts) for mi in 1:num_mixed))


    optimize!(m)

    #@show JuMP.termination_status(m)
    #@show value.(x)
    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
end

#column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))

function blotto_oracle_two(
    actions_opponent,
    weights_opponent,
    vv
)

    num_fronts = length(first(actions_opponent))
    num_mixed = length(actions_opponent)

    m = Model(SCIP.Optimizer)
    @variable(m, 0 <= act[1:num_fronts] <= 1)
    @constraint(m, sum(act) == 1)
    xstrt = rand(num_fronts)
    set_start_value.(act, xstrt ./ sum(xstrt))

    @variable(m, -1 <= x[1:num_fronts, 1:num_mixed] <= 1)

    @variable(m, 0 <= p[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= n[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= y[1:num_fronts, 1:num_mixed] <= 1, Bin)

    @variable(m, 0 <= pn[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= sqpn[1:num_fronts, 1:num_mixed] <= 1)

    for mi in 1:num_mixed
        for fi in 1:num_fronts
            @constraint(m, x[fi, mi] == act[fi] - actions_opponent[mi][fi])
            @constraint(m, x[fi, mi] == p[fi, mi] - n[fi, mi])
            @constraint(m, pn[fi, mi] == p[fi, mi] + n[fi, mi])
            @constraint(m, p[fi, mi] <= y[fi, mi])
            @constraint(m, n[fi, mi] <= 1 - y[fi, mi])
            @constraint(m, sqpn[fi, mi]^2 == pn[fi, mi])
        end
    end

    @objective(m, Max, sum(weights_opponent[mi] * sum((2 * y[fi, mi] - 1) * sqpn[fi, mi] for fi in 1:num_fronts) for mi in 1:num_mixed))

    optimize!(m)
    if true || JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(act)...)
    else
        NaN
    end
end

using LinearAlgebra
function blotto_oracle_three(
    actions_opponent,
    weights_opponent,
    vv
)
    nfronts = length(actions_opponent[1])
    br = zeros(nfronts)
    ma = zeros(nfronts)
    for i in eachindex(actions_opponent)
        ma += weights_opponent[i] * collect(actions_opponent[i])
    end
    mx, ij = findmax(ma)
    for k in 1:nfronts
        if k == ij
            continue
        end
        br[k] = ma[k] + mx / (nfronts - 1)
    end
    @show br

    num_fronts = length(first(actions_opponent))
    num_mixed = length(actions_opponent)

    m = Model(_default_optimizer)
    @variable(m, 0 <= act[1:num_fronts] <= 1)
    @constraint(m, sum(act) == 1)
    xstrt = normalize(br, 1) #rand(num_fronts)
    set_start_value.(act, xstrt ./ sum(xstrt))

    @variable(m, 0 <= p[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= n[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= y[1:num_fronts, 1:num_mixed] <= 1, Bin)

    @variable(m, 0 <= pn[1:num_fronts, 1:num_mixed] <= 1)
    @variable(m, 0 <= sqpn[1:num_fronts, 1:num_mixed] <= 1)

    for mi in 1:num_mixed
        for fi in 1:num_fronts
            @constraint(m, act[fi] - actions_opponent[mi][fi] == p[fi, mi] - n[fi, mi])
            @constraint(m, pn[fi, mi] == p[fi, mi] + n[fi, mi])
            @constraint(m, p[fi, mi] <= y[fi, mi])
            @constraint(m, n[fi, mi] <= 1 - y[fi, mi])
            @constraint(m, sqpn[fi, mi]^2 == pn[fi, mi])
        end
    end

    @objective(m, Max, sum(weights_opponent[mi] * sum((2 * y[fi, mi] - 1) * sqpn[fi, mi] for fi in 1:num_fronts) for mi in 1:num_mixed))

    optimize!(m)
    if JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(act)...)
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

    @show solve_time(m)
    @show JuMP.termination_status(m)
    @show value.(x)
    if true || JuMP.termination_status(m) == JuMP.MOI.OPTIMAL
        objective_value(m), tuple(value.(x)...)
    else
        NaN
    end
end

using DynamicPolynomials
using MosekTools
using SumOfSquares
using SemialgebraicSets

# pouzij tuhle verzi
function poly_max(
    payoff::Function;
    optimizer=_default_optimizer)

    @polyvar x
    u = payoff(x)
    de = maxdegree(u)

    meas = nothing
    dom = @set 1 - x^2 >= 0
    for ord in de:2:10
        m = SOSModel(Mosek.Optimizer)
        @variable(m, w)
        @objective(m, Min, w)
        c = @constraint(m, u <= w, domain = dom, maxdegree = ord)
        optimize!(m)
        @show termination_status(m)
        @show solve_time(m)
        meas = atomic_measure(moment_matrix(c), 1e-3)
        if !isnothing(meas)
            break
        end
    end
    @show meas
    @show stats.time
    value(w)
end

function hankel(mu::AbstractVector{T}) where T
    m = length(mu)
    base = div(m, 2, RoundUp)
    result = zeros(Base.promote_op(+, T, T), base, base)

    for i in 1:base, j in 1:base
        result[i, j] += mu[i+j-1]
    end

    result
end

function hankel_mes_mom(mu::AbstractVector{T}) where T
    Hm = hankel(mu)
    m = size(Hm, 1)

    result = zeros(Base.promote_op(+, T, T), m - 1, m - 1)

    for i1 in axes(result, 1), i2 in axes(result, 2)
        result[i1, i2] = Hm[i1, i2]
    end
    for i1 in axes(result, 1), i2 in axes(result, 2)
        result[i1, i2] -= Hm[i1+1, i2+1]
    end

    @show result
end

function anti_hankel(A::AbstractMatrix{T}) where T
    m, n = size(A)
    result = zeros(Base.promote_op(+, T, T), m + n - 1)

    for i in 1:m, j in 1:n
        result[i+j-1] += A[i, j]
    end

    result
end

function anti_hankel_pos_poly(Z::AbstractMatrix{T}, W::AbstractMatrix{T}) where T
    sw1, sw2 = size(W)
    sz1, sz2 = size(Z)

    @assert sw1 + 1 == sz1 && sw2 + 1 == sz2

    result = Matrix{Base.promote_op(+, T, T)}(undef, sz1, sz2)

    for i1 in 1:sz1, i2 in 1:sz2
        result[i1, i2] = Z[i1, i2]
    end
    for i1 in 1:sw1, i2 in 1:sw2
        result[i1, i2] += W[i1, i2]
    end
    for i1 in 1:sw1, i2 in 1:sw2
        result[i1+1, i2+1] -= W[i1, i2]
    end

    anti_hankel(result)
end

#nema smysl optimalizovat univariate
function pmaxsos(
    payoff::Function;
    optimizer=_default_optimizer
)
    m = Model(Mosek.Optimizer)

    @polyvar v
    poly_payoff = payoff(v)
    d = div(maxdegree(poly_payoff), 2, RoundUp)

    @variable(m, Z[1:d+1, 1:d+1] in JuMP.PSDCone())
    @variable(m, W[1:d, 1:d] in JuMP.PSDCone())
    @variable(m, bnd)

    @objective(m, Max, bnd)

    soscoeffs = anti_hankel_pos_poly(Z, W)
    coeffs = coefficients(poly_payoff, monomials(v, 0:d+d))

    @constraint(m, -coeffs[1] - bnd == soscoeffs[1])
    @constraint(m, [i = 2:length(soscoeffs)], -coeffs[i] == soscoeffs[i])

    optimize!(m)
    @show termination_status(m)

    @show solve_time(m)
    value(bnd)
end

function pmaxmom(
    payoff::Function;
    optimizer=_default_optimizer
)
    m = Model(Mosek.Optimizer)

    @polyvar v
    poly_payoff = payoff(v)
    deven = div(maxdegree(poly_payoff), 2, RoundUp) * 2
    coeffs = coefficients(poly_payoff, monomials(v, 0:deven))

    @variable(m, mu[1:deven+1])
    @objective(m, Min, -sum(coeffs[i] * mu[i] for i in eachindex(mu)))
    @constraint(m, mu[1] == 1)
    @constraint(m, hankel(mu) in JuMP.PSDCone())
    @constraint(m, hankel_mes_mom(mu) in JuMP.PSDCone())

    optimize!(m)

    @show termination_status(m)
    @show solve_time(m)

    @show hankel(value.(mu))
    @show rank(hankel(value.(mu)))
    objective_value(m)
end

