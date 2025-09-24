using JuMP
using SumOfSquares
using MosekTools
using DynamicPolynomials

function ex_parrilo06_3_1()
    # Example 3.1
    # NE
    # (4^(-2/4),), 100.0 %;
    # (4^(-1/4),), 100.0 %;

    dom_nneg(v) = (1 - v[1], 1 + v[1])
    dom_null(v) = 0

    u1(x, y) = 2 * x[1] * y[1]^2 - x[1]^2 - y[1]
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function _sdp_lasserre(u, S; order=maxdegree(u), optimizer=Mosek.Optimizer)
    m = SOSModel(optimizer)

    @variable(m, w)
    @objective(m, Min, w)
    c = @constraint(m, u <= w, domain = S, maxdegree = order)
    optimize!(m)

    value(w), moment_matrix(c), termination_status(m)
end

function _set_to_blegat(dom_nneg, dom_null, vars; radius=1)
    zero_poly = sum(0 * xi for xi in vars)
    ball_poly = radius - sum(xi^2 for xi in vars)
    eqs = vec([e + zero_poly for e in dom_null(vars)])
    ges = [ball_poly; [e + zero_poly for e in dom_nneg(vars)]...]
    alg = algebraic_set(eqs)
    basic_semialgebraic_set(alg, ges)
end

function oracle_lasserre(
    payoff::Function,
    dom_nneg::Function,
    dom_null::Function,
    start;
    dim=length(start),
    optimizer=Mosek.Optimizer
)
    @polyvar x[1:dim]
    u = payoff(x)
    S = _set_to_blegat(dom_nneg, dom_null, x)

    order = maxdegree(u)
    while true
        val, mom, term = _sdp_lasserre(u, S; order, optimizer)
        strat = extractatoms(mom, 1e-3)
        @show expectation(u, strat), val
        if term == JuMP.OPTIMAL && !isnothing(strat)
            _, i = findmax(s.weight for s in stra.atoms)
            return val, tuple((strat.atoms[i]).center...)
        end
        order += 1
    end
end

(u1, u2), (dom_nneg1, dom_nneg2), (dom_null1, dom_null2), (dim1, dim2) = ex_parrilo06_3_2()

@polyvar x[1:1]

mv = u1(x, (0.5,))

v, s = oracle_lasserre(x -> u1(x, (0.5,)), dom_nneg1, dom_null1, (0.0,))
