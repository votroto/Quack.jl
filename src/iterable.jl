import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop


dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{P,D,V,I}
    payoffs::P
    domains::D
    variables::V
    start::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    payoffs,
    domains;
    variables=Sym.get_variables.(domain),
    start=interior_init(domains)
)
    callable = _compile_sym.(payoffs, Ref(variables))
    QuackIterable(callable, domains, variables, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    payoffs, domains, variables = mo.payoffs, mo.domains, mo.variables

    values, mixed = equilibrium(payoffs, actions)
    best, responses = oracle(payoffs, domains, actions, mixed; variables)
    extended = uniqhcat.(actions, responses)

    worsts =  worst(payoffs, actions, mixed)
    for (i, e) in enumerate(extended)
        if length(e) > 2
            extended[i] = extended[i][:, begin:end .!= worsts[i]]
        end
    end

    (actions, mixed, values, best), extended
end


function worst(payoffs, actions, strategies)
    ps = _subgames(payoffs, actions)
    players = eachindex(payoffs)

    pays = [
        _bug_ncon([ps[i], strategies[js]...], [np, njs...])
        for (i, js, np, njs) in _ncon_ids(players)
    ]

    argmin.(pays)
end