
using JuMP


p1(x1, x2, x3) = -2 * x1 * x2^2 - 2 * x1^2 + 5 * x1 * x2 - 4 * x1 * x3 - x2 - 2 * x3
p2(x1, x2, x3) = 2 * x1 * x2^2 - 2 * x2 * x3^2 - 2 * x1^2 - 5 * x1 * x2 - 2 * x2^2 + 5 * x2 * x3 + x2
p3(x1, x2, x3) = 2 * x2 * x3^2 + 4 * x1^2 + 4 * x1 * x3 + 2 * x2^2 - 5 * x2 * x3 + 2 * x3

m = Model()

@variable m a
@variable m b
@variable m c
@variable m d
@variable m e


bb = (0.0 + ((0.0 + ((0.0 + (0.0 + ((-0.25*c*d - 2*b*e - 2.25*c*e) * a))) + ((0.125*a*d + 0.875*a*e) * c))) + ((0.125*a*c) * d))) + ((2*a*b + 1.375*a*c) * e)

simplify(a) = a
simplify(a::AffExpr) = isempty(a.terms) ? a.constant : a
simplify(a::QuadExpr) = isempty(a.terms) ? simplify(a.aff) : QuadExpr(simplify(a.aff), filter(a->a[2]!=0, a.terms))

function simplify(e::NonlinearExpr)
    if e.head == :*
        simplified = map(simplify, e.args)
        if any(s -> s == 0, simplified)
            return 0
        end
        return NonlinearExpr(e.head, filter(s -> s != 1, simplified))
    elseif e.head == :+
        simplified = map(simplify, e.args)
        return NonlinearExpr(e.head, filter(s -> s != 0, simplified))
    else
        e
    end
end