using Base.Iterators: product
using Gurobi
using JuMP
using LinearAlgebra

_euclidean_norm((x, y)) = norm(collect(x) - collect(y))

function wasserstein(spt_p, p, spt_q, q; ρ=_euclidean_norm)
    ρxy = ρ.(product(spt_p, spt_q))

#    @show spt_p, p, spt_q, q

    model = Model(Gurobi.Optimizer)
    @variable model μ[axes(ρxy, 1), axes(ρxy, 2)] >= 0
    @objective model Min dot(ρxy, μ)
    @constraint model sum(μ) == 1
    @constraint model sum(μ, dims=2) .== normalize(clamp.(p, 0.0, 1.0), 1)
    @constraint model sum(μ, dims=1) .== normalize(clamp.(q, 0.0, 1.0), 1)'

    set_silent(model)
    optimize!(model)

    objective_value(model)
end

function prettyprints(actss, wghtss)
    for p in eachindex(actss)
        for i in eachindex(actss[p])
            if wghtss[p][i] > 5e-4
                print(round.(actss[p][i]; digits=3), ", ", round(wghtss[p][i] * 100; digits=1), " %")
                print("; ")
            end
        end
        println()
    end
end

function deltaprints(actss, wghtss; io=stdout)
    function probfmt(p)
        cp = min(max(p, 0.0), 1.0)
        if isapprox(cp, 1)
            return ""
        else
            return round(p; digits=3)
        end
    end
    function supnumfmt(x)
        z = round(x; digits=2)
        z = (z == -0.0) ? 0 : z
        return isinteger(z) ? round(Int, z) : z
    end
    function supfmt(act)
        if length(act) == 1
            return supnumfmt(only(act))
        else
            return supnumfmt.(act)
        end
    end
    function dprint(p, acts, wghts)
        zp = collect(zip(acts, wghts))
        aw = join(map(x -> "$(probfmt(x[2]))\\delta_{ $(supfmt(x[1])) }", sort(filter(x -> x[2] > 5e-4, zp), by=x -> -x[2])), " + ")
        return "\\mu_$p^\\star &\\approx $aw"
    end

    function xprint(p, acts, wghts)
        i = findfirst(x -> x > 5e-4, wghts)
        return "\\x_$p^\\star \\approx $(supfmt(acts[i]))"
    end

    if all(length(filter(x -> x > 5e-4, w)) == 1 for w in wghtss)
        println(io, "\\begin{align*}")
        println(io, join([xprint(p, actss[p], wghtss[p]) for p in eachindex(actss)], ",\\;\n"), ".")
        println(io, "\\end{align*}")
    else
        println(io, "\\begin{align*}")
        println(io, join([dprint(p, actss[p], wghtss[p]) for p in eachindex(actss)], ",\\\\ \n"), ".")
        println(io, "\\end{align*}")
    end
end


function saddle(f, x, y; ε=1e-4)
    N = length(x)
    M = length(y)
    A = Matrix{Float64}(I, N, N)

    ff = f(x, y)

    slopesx = []
    for i in 1:N
        x_forward = x .+ ε .* A[:, i]
        x_backward = x .- ε .* A[:, i]
        f_forward = f(x_forward, y)
        f_backward = f(x_backward, y)
        slopel = (f_forward - ff) / (ε)
        sloper = (f_backward - ff) / (ε)
        push!(slopesx, slopel)
        push!(slopesx, sloper)
    end

    A = Matrix{Float64}(I, M, M)
    slopesy = []
    for i in 1:M
        y_forward = y .+ ε .* A[:, i]
        y_backward = y .- ε .* A[:, i]
        f_forward = f(x, y_forward)
        f_backward = f(x, y_backward)
        slopel = (f_forward - ff) / (ε)
        sloper = (f_backward - ff) / (ε)
        push!(slopesy, slopel)
        push!(slopesy, sloper)
    end

    return slopesx, slopesy
end

function run_example(example; eps=1e-3)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims)
    @time cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, eps)

    deltaprints(actions, mixed)

    cnt, (actions, mixed, vals, best)
end

function run_example_tex(name, example; io=stdout, eps=1e-3)
    utils, nneg, null, dims = example()
    _start = Quack.feasible_init(nneg, null, dims)
    Quack.quack_oracle(utils, nneg, null, dims; start=_start)
    stats_pre = @timed start = Quack.feasible_init(nneg, null, dims)
    quack = Quack.quack_oracle(utils, nneg, null, dims; start=start)
    Quack.until_eps(quack, 1e10)
    stats_run = @timed cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, eps)

    iter_word = (cnt > 1) ? "iterations" : "iterations"

    #incentive = round(Quack.max_incentive(nothing, nothing, vals, best);sigdigits=1)

    println(io, "\\item[Example \\ref{$(replace(name, "_"=>"."))}]")
    println(io, "Converged in \$$(round(stats_run.time; sigdigits=2))\\;(+$(round(stats_pre.time; sigdigits=1)))\\,s\$ and \$$cnt\$ $iter_word to:")
    deltaprints(actions, mixed; io)
end

function latexify_example(example)
    utils, nneg, null, dims = example()
    vars = ntuple(i -> [Symbolics.variable(:x, i * 10 + j) for j in 1:dims[i]], length(dims))

    for i in eachindex(dims)
        println(latexify(utils[i](vars...)))
    end
end

function run_progress(example; iterations)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims)

    exploit = Vector{Vector{Float64}}(undef, iterations)
    wassers = Vector{Vector{Float64}}(undef, iterations)
    iter = 1

    prev_supp = nothing
    prev_mixs = nothing

    for (actions, mixed, vals, best) in Iterators.take(quack, iterations)
        exploit[iter] = max.(collect(best) .- collect(vals), floatmin())

        if !isnothing(prev_supp)
            wassers[iter] = [max(wasserstein(prev_supp[i], prev_mixs[i], actions[i], mixed[i]), floatmin()) for i in 1:length(dims)]
        else
            wassers[iter] = [NaN64 for i in 1:length(dims)]
        end

        iter += 1
        prev_supp = actions
        prev_mixs = mixed

        @show vals
    end

    println()
    @show prev_supp
    @show prev_mixs
    println()
    deltaprints(prev_supp, prev_mixs)
    println()
    exploit, wassers
end

