import Symbolics as Sym

max_incentive((_, values, best)) = norm(best - values, Inf)

function _inequality_to_expr(ineq::Sym.Inequality)
    lhs, rhs, op = ineq.lhs, ineq.rhs, ineq.relational_op
    (op == Sym.geq) ? -lhs + rhs : lhs - rhs
end