# Sarath Yasodharan and Patrick Loiseau. 2019.
# Nonzero-sum adversarial hypothesis testing games.

function ex_yasodharan19()
    dom_nneg1(x) = (x[1], x[2], 1 - x[1], 1 - x[2])
    dom_nneg2(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    m = 1
    gamma = 0.2
    u1(x,y) = sum(x[i+1] * binomial(m,i) * y[1]^i*(1-y[1])^(m-i) for i in 0:m) - (gamma/2.0^m)*sum(x[i+1] * binomial(m,i) for i in 0:m) - 1
    u2(x,y) = -(y[1]-0.8)^2 + sum(binomial(m,i)*(1-x[i+1])*y[1]^i*(1-y[1])^(m-i) for i in 0:m)

    (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (m+1, 1)
end
