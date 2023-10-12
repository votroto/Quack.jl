using LinearAlgebra: normalize, norm
using Random: shuffle
using Base.Iterators: partition
using JuMP
using Gurobi
using LinearAlgebra

_LP_SOLVER = optimizer_with_attributes(Gurobi.Optimizer, MOI.Silent() => true)

struct WCC
    V
    C
    S
    w
    δ
    d
    b
end

function ld_r(wcc, xs, v)
    norm(ld_f(wcc, xs, v) - xs[v])
end

function ld_f(wcc, xs, v)
    function ld_fs(s)
        del = wcc.δ[v, s]
        up = wcc.d[v, s] + wcc.w[v, s] * xs[del][s]

        normalize(up, 1) * wcc.b[v, s]
    end

    br = zero(xs[v])
    for s in wcc.S[v]
        br[s] = ld_fs(s)
    end

    br
end

function wcc_br_pure(wcc, actions)
    Tuple(0 for v in wcc.V), Tuple(ld_f(wcc, actions, v) for v in wcc.V)
end

function wcc_brs(wcc, actions, probs, player; optimizer=_LP_SOLVER)
    aprod = Base.Iterators.product(actions...)
    pprod = vec(prod.(Base.Iterators.product(probs...)))

    m = Model(optimizer)
    @variable m X[wcc.C]
    @variable m t[1:length(aprod), wcc.C]

    @objective m Min sum(pprod[i] * t[i,c] for i in eachindex(pprod) for c in wcc.C)
    @constraint m [s in wcc.S[player]] sum(X[s]) == wcc.b[player, s]

    for (i,xs) in enumerate(aprod)
        br = ld_f(wcc, xs, player)
        for c in wcc.C
            @constraint m t[i,c] >= X[c] - br[c]
            @constraint m t[i,c] >= -(X[c] - br[c])
        end
    end

    optimize!(m)

    collect(value.(X))
end

function wcc_br(wcc, actions, probs)
    vals = Tuple(0 for v in wcc.V)
    resps = Tuple(wcc_brs(wcc, actions, probs, v) for v in wcc.V)
    
    vals, resps
end

function wcc_init(wcc)    
    init = Tuple(zeros(length(wcc.C)) for _ in wcc.V)
    for (v, Sv) in enumerate(wcc.S) 
        for s in Sv
            init[v][s] = normalize(rand(length(s)), 1) * wcc.b[v, s]
        end
    end

    Tuple([i] for i in init)
end

function wcc_rand(n, m)
    V = 1:n
    C = 1:m

    S = ntuple(v -> collect(partition(shuffle(C), rand(1:m))), n)
    budgets = [normalize(rand(length(b)), 1) for b in S]

    w = Dict((v, s) => rand() for (v, Sv) in enumerate(S) for s in Sv)
    δ = Dict((v, s) => rand(V) for (v, Sv) in enumerate(S) for s in Sv)
    b = Dict((v, s) => budgets[v][si] for (v, Sv) in enumerate(S) for (si, s) in enumerate(Sv))
    d = Dict((v, s) => normalize(rand(length(s)), 1) * b[v, s] for (v, Sv) in enumerate(S) for s in Sv)

    WCC(V, C, S, w, δ, d, b)
end