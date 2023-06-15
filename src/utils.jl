import Symbolics as Sym

max_incentive((_, values, best)) = norm(best - values, Inf)
