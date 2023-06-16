import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra

struct QuackIterable{P, D, I}
	payoff::P
    domain::D
	init::I
end

IteratorSize(::Type{QuackIterable}) = IsInfinite()

function quack_oracle(payoff, domain; init=interior_init(payoff))
	QuackIterable(payoff, domain, init)
end

function iterate(mo::QuackIterable, pures=mo.init)
	values, strategies = equilibrium(mo.payoff, mo.domain, pures)
	best, responses = oracle(mo.payoff, mo.domain, pures, strategies)
	extended = unique.(vcat.(pures, responses), dims=1)

	(pures, strategies, values, best), extended
end