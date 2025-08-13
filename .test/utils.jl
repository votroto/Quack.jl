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


function deltaprints(actss, wghtss;io=stdout)
    function supfmt(act)
        if length(act) == 1
            return round(only(act); digits=2)
        else
            return round.(act;digits=2)
        end
    end
    function dprint(p,acts, wghts)
        zp = collect(zip(acts, wghts))
        aw = join(map(x -> "$(round(x[2];digits=3))\\delta_{ $(supfmt(x[1])) }", sort(filter(x -> x[2] > 5e-4 , zp), by=x -> x[2])), " + ")
        return "\\mu_$p^\\star &\\approx $aw"
    end
    println(io, "\\begin{align*}")
    println(io, join([dprint(p, actss[p], wghtss[p]) for p in eachindex(actss)], ",\\\\ \n"), ".")
    println(io, "\\end{align*}")
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

    deltaprints(actions,mixed)

    cnt, (actions, mixed, vals, best)
end

function run_example_tex(name, example; io=stdout, eps=1e-3)
    utils, nneg, null, dims = example()
    quack = Quack.quack_oracle(utils, nneg, null, dims)
    Quack.until_eps(quack, 1e10)
    stats = @timed cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, eps)

    println(io, "\\item[Example \\ref{$(replace(name, "_"=>"."))}]")
    println(io, "Time: \$$(round(stats.time; sigdigits=2))\\,s\$, iterations: \$$cnt\$\\\\")
    println(io, "Equilibrium:")
    deltaprints(actions,mixed; io)

end

function latexify_example(example)
    utils, nneg, null, dims = example()
    vars = ntuple(i -> [Symbolics.variable(:x, i*10+j) for j in 1:dims[i]], length(dims))

    for i in eachindex(dims)
        println(latexify(utils[i](vars...)))
    end
end