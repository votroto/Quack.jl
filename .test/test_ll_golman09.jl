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


utils, nneg, null, dims = ex_golman09_all_sets_p1_5d()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

prettyprints(actions, mixed)
