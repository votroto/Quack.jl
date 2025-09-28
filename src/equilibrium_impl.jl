
const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end

_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])

"""
Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function subgame_equilibrium(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector}
) where {N}
    # Oof!

    players = eachindex(payoffs)
    dims = ntuple(i -> length(actions[i]), N)

    player_string = join(["\"$i\"" for i in players], " ")
    dim_string = join(dims, " ")

    ioin = IOBuffer()

    println(ioin, "NFG 1 R \"Exported Game\"")
    println(ioin, "{ $player_string } { $dim_string }")

    for i in Iterators.product(eachindex.(actions)...)
        for p in players
            print(ioin, payoffs[p](getindex.(actions, i)...), " ")
        end
    end
    allinput = String(take!(ioin))
    open(pipeline(`gambit-logit -q -e -m1e-8`; stdin=IOBuffer(allinput)), "r", stdout) do ioout
        zz = read(ioout, String)

        ne = parse.(Float64, split(strip(zz), ",")[2:end])
        nes = []
        for p in players
            push!(nes, ne[1:dims[p]])
            ne = ne[dims[p]+1:end]
        end

        wout = zeros(N)
        for i in Iterators.product(eachindex.(actions)...)
            for p in players

                w = prod(nes[z][i[z]] for z in players)
                uu = payoffs[p](getindex.(actions, i)...)

                wout[p] += w * uu

            end
        end
        return tuple(wout...), ntuple(i -> nes[i], N)
    end

end


using DynamicPolynomials
function ups(
    payoffs::NTuple{N,Function},
    actions::NTuple{N, AbstractVector},
    weights::NTuple{N}
) where {N}
    dim = ntuple(i -> length(first(actions[i])), N)
    zs = ntuple(i -> @polyvar(z[i, 1:dim[i]])[1], N)
    p = ntuple(i -> payoffs[i](zs...), N)

    function deviation(i, x)
        res = nothing
        q = p[i]

        #println()
        #println(i)
        for t in terms(q)
            vs = effective_variables(t)
#@show t
            function weval(w, a)
                 ass = [zs[ip][ia] => a[ip][ia] for ip in 1:N for ia in eachindex(a[ip])]
                prod(w) * t(ass...)
            end

            wf(j) = if i == j; [1]; elseif any(v in vs for v in zs[j]); weights[j] else [1] end
            af(j) = if i == j; [x]; elseif any(v in vs for v in zs[j]); actions[j] else [first(actions[j]) ] end
            part_weights = ntuple(j -> wf(j), N)
             part_actions = ntuple(j -> af(j), N)
            prod_actions = Iterators.product(part_actions...)
            prod_weights = Iterators.product(part_weights...)

            tmp = mapreduce(weval, +, prod_weights, prod_actions)
           # @show tmp
            if isnothing(res)
                res = tmp
            else
                res += tmp
            end

        end
        return res
    end

    ntuple(i -> x -> deviation(i, x), N)
end

function polymatrix_equilibrium(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector};
    optimizer=_default_optimizer
) where {N}
    dims = ntuple(i -> length(actions[i]), N)

    m = Model(optimizer)
    y = ntuple(i -> @variable(m, [j=1:dims[i]], lower_bound = 0, upper_bound = 1, base_name="y[$i,$j]"), N)
    @variable(m, w[1:N])
    @constraint(m, [i = 1:N], sum(y[i]) == 1)


    zps = ups(payoffs, actions, y)

    @constraint(m, [i = 1:N, s in actions[i]], zps[i](s) <= w[i])
    @objective(m, Min, sum(w))
    set_silent(m)
    optimize!(m)

    tuple(value.(w)...), ntuple(i -> value.(y[i]), N)
end