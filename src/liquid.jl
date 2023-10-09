using LinearAlgebra: normalize, norm
using Random: shuffle
using Base.Iterators: partition

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

function rand_wcc(n, m)
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