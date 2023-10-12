import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra
using Base.Iterators: dropwhile, flatten, take, drop


dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

struct QuackIterable{W,I}
    wcc::W
    start::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(
    wcc::WCC,
    start::NTuple{N}=wcc_init(wcc)
) where N
    QuackIterable(wcc, start)
end

function iterate(mo::QuackIterable, actions=mo.start)
    values, mixed = equilibrium(mo.wcc, actions)
    best, responses = wcc_br(mo.wcc, actions, mixed)
    extended = uniqpush.(actions, responses)

    (actions, mixed, values, best), extended
end