include("../src/Quack.jl")
using Revise

function prettyprints(actss, wghtss)
    for p in eachindex(actss)
        for i in eachindex(actss[p])
            if wghtss[p][i] > 5e-4
                print(round.(actss[p][i];digits=3), ", ", round(wghtss[p][i]*100;digits=1), " %")
                print("; ")
            end
        end
        println()
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

function run_example(example)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims)
    @show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

    prettyprints(actions,mixed)
end

function latexify_example(example)
    utils, nneg, null, dims = example()
    vars = ntuple(i -> [Symbolics.variable(:x, i*10+j) for j in 1:dims[i]], length(dims))

    for i in eachindex(dims)
        println(latexify(utils[i](vars...)))
    end
end