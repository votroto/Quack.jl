
const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end


_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])


"""
    nash_equilibrium(payoffs)

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
    open(pipeline(`gambit-logit -q -e -m1e-6`; stdin=IOBuffer(allinput)), "r", stdout) do ioout
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