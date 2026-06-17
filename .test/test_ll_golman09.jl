include("../src/Quack.jl")

# Russell Golman and Scott E Page. “General Blotto: Games Of Allocative Strategic
# Mismatch”. In: Public Choice 138.3-4 (2009), pp. 279–299

function all_combinations(max)
    result = []

    function combine(current, start, k)
        if length(current) == k
            push!(result, current)
        end
        for i in start:max
            combine([current...; i], i + 1, k)
        end
    end

    for k in 1:max
        combine([], 1, k)
    end

    return result
end

_golman_weight_p2(x) = sqrt(x^2) * x
_golman_weight_p1(x) = x
_golman_weight_p0(x) = sign(x)
_golman_weight_p(x; p=0.5) = sign(x)*abs(x)^p

function ex_golman09_isolated(n=5, f=_golman_weight_p2)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:n)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end

function ex_golman09_all_pairs(n=5, f=_golman_weight_p2)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:n-1 for k in (j+1):n) + sum(f(x[i] - y[i]) for i in 1:n)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end

function ex_golman09_all_sets(n=5, f=_golman_weight_p2)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(n))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end

