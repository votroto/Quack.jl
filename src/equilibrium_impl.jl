
const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end

#using AmplNLWriter, Couenne_jll
#_default_optimizer() = AmplNLWriter.Optimizer(Couenne_jll.amplexe)
_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])


"""Computes the value and NE strategies for a zero-sum game"""
function linear_program(u::AbstractMatrix; optimizer=_default_optimizer)
    m = Model(optimizer)

    ny = size(u, 2)
    @variable(m, ys[1:ny], lower_bound=0, upper_bound=1)
    @variable(m, w)

    @constraint(m, sum(ys) == 1)
    @constraint(m, dx, u * ys .<= w)
    @objective(m, Min, w)
    optimize!(m)

    value.(w), abs.(dual.(dx)), value.(ys), solve_time(m)
end

"""
    nash_equilibrium(payoffs)

Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function subgame_equilibrium(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector}
) where {N}

    pay = zeros(Float64, length(actions[1]), length(actions[2]))

    for i in Iterators.product(eachindex.(actions)...)
        pay[i...] = payoffs[1](getindex.(actions, i)...)
    end

    wls, xss, yss, tim = linear_program(pay)

    return tuple(wls, -wls), (xss, yss)
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