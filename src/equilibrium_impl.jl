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
    actions::NTuple{N,AbstractVector};
    optimizer=_default_optimizer
) where {N}
    ztratz, wals = subgame_gambit_nfg_export(payoffs, actions)
    #=
        _simplex_var(i, a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1)

        players = eachindex(payoffs)
        act_ids = eachindex.(actions)

        m = Model(optimizer)

        x = ntuple(i -> [_simplex_var(i, a) for a in act_ids[i]], N)
        @variable(m, w[i=players])

        brfs = ntuple(i -> zeros(NonlinearExpr, act_ids[i]), N)
        unilateral_payoffs!(brfs, payoffs, actions, x)

        sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in act_ids[i])
        @constraint(m, [i = players], brfs[i] .<= w[i])
        @constraint(m, sum_payoff >= sum(w))
        @constraint(m, [i = players], sum(x[i]) == 1)

        optimize!(m)

        values = ntuple(i -> value.(w[i]), N)
        strats = ntuple(i -> value.(x[i]), N)


        @show strats
        @show ztratz

        @show wals
        @show values
    =#
    wals, ztratz
    #values, strats
end

function normal_form_subgames(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector}
) where {N}
    players = eachindex(payoffs)
    dims = ntuple(i -> length(actions[i]), N)
    nfgs = ntuple(i -> Matrix{Float32,N}(undef, dims), N)

    for i in Iterators.product(eachindex.(actions)...)
        for p in players
            nfgs[p][i[p]] = payoffs[p](getindex.(actions, i)...)
        end
    end

    nfgs
end

function subgame_gambit_nfg_export(
    payoffs::NTuple{N,Function},
    actions::NTuple{N,AbstractVector}
) where {N}
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


        return ntuple(i -> nes[i], N), tuple(wout...)
    end

end

