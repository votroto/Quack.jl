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
    payoffs::NTuple{N},
    domains::NTuple{N};
    variables::NTuple{N}=domains_variables(domains),
    start::NTuple{N}=interior_init(domains)
) where N
    callable = map(p -> _compile_sym(p, variables), payoffs)
    QuackIterable(callable, domains, variables, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    payoffs, domains, variables = mo.payoffs, mo.domains, mo.variables

    actions, variables
    values, mixed = equilibrium(payoffs, actions)
    best, responses = oracle(payoffs, domains, actions, mixed; variables)
    extended = uniqpush.(actions, responses)

    (actions, mixed, values, best), extended
end