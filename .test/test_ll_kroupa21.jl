include("../src/Quack.jl")
using Revise

# Separable Network Games with Compact Strategy Sets
# Tomáš Kroupa, Sara Vannucci, Tomáš Votroubek

function ex_kroupa21_5()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x, y, z) = −2*x*y^2 + 5*x*y − y −2*x^2 − 4*x*z − 2*z
    v2(x, y, z) = 2*x*y^2 − 2*x^2 − 5*x*y + y −2*y*z^2 − 2*y^2 + 5*y*z
    v3(x, y, z) = 4*x^2 + 4*x*z + 2*z + 2*y*z^2 + 2*y^2 − 5*y*z

    u1(x, y, z) = v1(x[1], y[1], z[1])
    u2(x, y, z) = v2(x[1], y[1], z[1])
    u3(x, y, z) = v3(x[1], y[1], z[1])

    (u1, u2, u3), (dom_nneg, dom_nneg, dom_nneg), (dom_null, dom_null, dom_null), (1, 1, 1)
end

function ex_kroupa21_6()
	N = 1:4
	a = [0.5, 0.8]
    offset = sum(a) / length(N)

	dom_nneg1(x) = (x[1], x[2] , x[3], x[4])
	dom_nneg2(y) = (y[1], y[2] , y[3], y[4])
	dom_nneg3(u) = (u[1], u[2])
	dom_nneg4(v) = (v[1], v[2])

	dom_null1(x) = (x[1] + x[2] + x[3] + x[4] - a[1])
	dom_null2(y) = (y[1] + y[2] + y[3] + y[4] - a[2])
	dom_null3(u) = (u[1] + u[2] - 1)
	dom_null4(v) = (v[1] + v[2] - 1)

    eff = (
	    (x,y) -> (1-y^2)*0.7x^2,
	    (x,y) -> (1-y)^2*(1.4x - 0.7x^2),
	    (x,y) -> (1-y^2)*(1.8x - 0.9x^2),
	    (x,y) -> (1-y)^2*0.9x^2
    )

	u1(x,y, u,v) = a[1] - eff[1](x[1], u[1]) - eff[2](x[2], u[2]) - eff[3](x[3], v[1]) - eff[4](x[4], v[2]) - offset
	u2(x,y, u,v) = a[2] - eff[1](y[1], u[1]) - eff[2](y[2], u[2]) - eff[3](y[3], v[1]) - eff[4](y[4], v[2]) - offset
	u3(x,y, u,v) = eff[1](x[1], u[1]) + eff[2](x[2], u[2]) + eff[1](y[1], u[1]) + eff[2](y[2], u[2]) -  offset
	u4(x,y, u,v) = eff[3](x[3], v[1]) + eff[4](x[4], v[2]) + eff[3](y[3], v[1]) + eff[4](y[4], v[2])  -  offset


    (u1, u2, u3, u4), (dom_nneg1, dom_nneg2, dom_nneg3, dom_nneg4), (dom_null1, dom_null2, dom_null3, dom_null4), (4, 4, 2, 2)
end

utils, nneg, null, dims = ex_kroupa21_6()
quack = Quack.quack_oracle(utils, nneg, null, dims)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)