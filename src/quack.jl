import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop

dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x...) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{N,I}
    payoffs::NTuple{N,Function}
    domains::NTuple{N,Function}
    start::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    payoffs::NTuple{N,Function},
    domains::NTuple{N,Function},
    start=feasible_init(domains)
) where {N}
    QuackIterable(payoffs, domains, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    payoffs, domains = mo.payoffs, mo.domains

    values, mixed = equilibrium(payoffs, actions)
    best, responses = oracle(payoffs, domains, actions, mixed)
    extended = epspush.(actions, responses, values, best)

    (actions, mixed, values, best), extended
end