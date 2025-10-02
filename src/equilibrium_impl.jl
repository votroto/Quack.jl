

const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    # Reuse environment between solves
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end

#using AmplNLWriter, Bonmin_jll,Couenne_jll
#_default_optimizer() = AmplNLWriter.Optimizer(Couenne_jll.amplexe)
#using SCIP
#_default_optimizer() = SCIP.Optimizer()
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
    function evec(n)
        xs = zeros(n)
        xs[n] = 1.0
        return xs
    end

    return ntuple(i->payoffs[i](actions[1][end],actions[2][end]), N), ntuple(i -> evec(length(actions[i])), N)


#return subgame_symmetric_equilibrium(payoffs,actions)

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


#=
    fff = zeros(Float64, length(actions[1]), length(actions[2]))
    qqq = zeros(Float64, length(actions[1]), length(actions[2]))
    for i in eachindex(actions[1])
        for j in eachindex(actions[2])
            fff[i,j]= payoffs[1](actions[1][i],actions[2][j])
            qqq[i,j]= payoffs[2](actions[1][i],actions[2][j])
        end
    end
    display(fff)
    display(qqq)
=#


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




function subgame_symmetric_equilibrium(
    payoffs::NTuple{N, Function},
    actions::NTuple{N, AbstractVector};
    optimizer=_default_optimizer
) where {N}
    _simplex_var(i,a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1)

    players = eachindex(payoffs)
    act_ids = eachindex.(actions)

    m = Model(optimizer)

    z = [_simplex_var(1,a) for a in act_ids[1]]
    x = ntuple(i -> z, N)
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

    values, strats
end


function subgame_symmetric_equilibrium_low_norm(
    payoffs::NTuple{N, Function},
    actions::NTuple{N, AbstractVector};
    optimizer=_default_optimizer
) where {N}
    _simplex_var(i,a) = @variable(m; base_name="x[$i,$a]", lower_bound=0, upper_bound=1)

    players = eachindex(payoffs)
    act_ids = eachindex.(actions)

    column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
    m = direct_model(optimizer())


    z = [_simplex_var(1,a) for a in act_ids[1]]
    x = ntuple(i -> z, N)
    #x = ntuple(i -> [_simplex_var(i,a) for a in act_ids[i]], N)

    o = @variable(m, o >= 0)
    GRBaddgenconstrNorm(backend(m), "mnorm", column(o), sum(length.(act_ids)), [column(x[p][a]) for p in players for a in act_ids[p]], 0)

    @variable(m, w[i=players])

    brfs = ntuple(i -> zeros(NonlinearExpr, act_ids[i]), N)
    unilateral_payoffs!(brfs, payoffs, actions, x)

    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in act_ids[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    @objective(m, Min, o)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)


    #@show strats
    #println()
    values, strats
end