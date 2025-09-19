import Mosek
using JuMP

using DynamicPolynomials
using SumOfSquares

using RowEchelon
#import SCS
#scs = SCS.Optimizer
#import Dualization

#dual_scs = Dualization.dual_optimizer(scs)

@polyvar x y
p = -(x-1)^2 - (x-y)^2 - (y-3)^2
S = @set (x-1)^2 <=1 &&  (x-y)^2 <=1 && (y-3)^2 <= 1


model = SOSModel(Mosek.Optimizer)
@variable(model, α)
@objective(model, Max, α)
@constraint(model, c4, p >= α, domain = S, maxdegree = 4,newton_polytope = nothing)

optimize!(model)

mom = moment_matrix(c4)

function rank_preserving_cholesky(A; tol=1e-12)
    @assert issymmetric(A) "A must be symmetric"

    vals, vecs = eigen(A)

    # keep only "significantly positive" eigenvalues
    keep = vals .> tol
    vals_pos = vals[keep]
    vecs_pos = vecs[:, keep]

    # build L from positive eigenspace
    L = vecs_pos * Diagonal(sqrt.(vals_pos))
    return L
end

function multmatrix(fact, var, pivots, basis)
    @show gen_basis = basis[pivots]
    @show mul_monos = var .* collect(gen_basis)
    @show mul_basis = [i for i in eachindex(basis) if basis[i] in mul_monos]
    fact[pivots, mul_basis]
end

#rref(mom)
#=
non = [
    1.0000 1.5868 2.2477 2.7603 3.6690 5.2387
    1.5868 2.7603 3.6690 5.1073 6.5115 8.8245
    2.2477 3.6690 5.2387 6.5115 8.8245 12.7072
    2.7603 5.1073 6.5115 9.8013 12.1965 15.9960
    3.6690 6.5115 8.8245 12.1965 15.9960 22.1084
    5.2387 8.8245 12.7072 15.9960 22.1084 32.1036
]
    =#