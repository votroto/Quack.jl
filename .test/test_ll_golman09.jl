include("../src/Quack.jl")
using Revise

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

function ex_golman09_isolated_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt(x^2) * x

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_pairs_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt((x)^2) * x

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:4 for k in (j+1):5) + sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_sets_p2_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = sqrt((x)^2) * x

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(5))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end


function ex_golman09_isolated_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_pairs_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:4 for k in (j+1):5) + sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_all_sets_p1_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x) = x

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(5))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end


function ex_golman09_isolated_p05_5d()
    dom_nneg(v) = (v[1], v[2], v[3], v[4], v[5], 1-v[1], 1-v[2], 1-v[3], 1-v[4], 1-v[5])
    dom_null(v) = v[1] + v[2] + v[3] + v[4] + v[5] - 1

    f(x::Float64) = sign(x)*abs(x)^0.5
    f(x) = x/(((x^2+1e-8)^0.25))

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:5)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (5, 5)
end

function ex_golman09_isolated_p2_nd(n)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    f(x) = sqrt(x^2) * x

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:n)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end

function ex_golman09_all_pairs_p2_nd(n)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    f(x) = sqrt(x^2) * x

    u1(x, y) = sum(f(x[j] * x[k] - y[j] * y[k]) for j in 1:n-1 for k in (j+1):n) + sum(f(x[i] - y[i]) for i in 1:n)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end

function ex_golman09_all_sets_p2_nd(n)
    dom_nneg(v) = ntuple(i->v[i], n)
    dom_null(v) = sum(v[i] for i in 1:n) - 1

    f(x) = sqrt(x^2) * x

    u1(x, y) = sum(f(prod(x[i] for i in I) - prod(y[i] for i in I)) for I in all_combinations(n))
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (n, n)
end




function ex_golman09_isolated_p05_3d()
    dom_nneg(v) = (v[1], v[2], v[3], 1-v[1], 1-v[2], 1-v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    f(x) = sign(x)*abs(x)^0.5

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:3)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end


function ex_golman09_isolated_p0_3d()
    dom_nneg(v) = (v[1], v[2], v[3], 1-v[1], 1-v[2], 1-v[3])
    dom_null(v) = v[1] + v[2] + v[3] - 1

    f(x) = sign(x)

    u1(x, y) = sum(f(x[i] - y[i]) for i in 1:3)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (3, 3)
end




