using DynamicPolynomials
using SumOfSquares
using CSDP

@polyvar x y
p = x^2 - x*y^2 + y^4 + 1
p = x^4*y^2 + x^2*y^4 + 1 − 3*x^2*y^2 + x^2 + y^2

model = SOSModel(CSDP.Optimizer)
@variable(model, a)
@constraint(model, cref, p >= a)
@objective(model, Max, a)
optimize!(model)

sos_dec = sos_decomposition(cref, 1e-4)

polynomial(sos_dec, Float32)


gram = gram_matrix(cref)

gram.basis.monomials' * gram.Q * gram.basis.monomials