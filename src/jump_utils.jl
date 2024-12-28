
# simplify jump nl exprs along with `flatten!`

_jump_simplify(a) = a
_jump_simplify(a::AffExpr) = isempty(a.terms) ? a.constant : a
_jump_simplify(a::QuadExpr) = isempty(a.terms) ? _jump_simplify(a.aff) : QuadExpr(_jump_simplify(a.aff), filter(a -> a[2] != 0, a.terms))

function _jump_simplify(e::NonlinearExpr)
    if e.head == :*
        simplified = map(_jump_simplify, e.args)
        if any(s -> s == 0, simplified)
            return 0
        end
        return prod(s for s in simplified if s != 1)
    elseif e.head == :+
        simplified = map(_jump_simplify, e.args)
        return sum(s for s in simplified if s != 0)
    else
        e
    end
end
