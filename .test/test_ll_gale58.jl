include("../src/Quack.jl")

# Gale, D., & Gross, O. (1958). A note on polynomial and separable games.
# Pacific J. Math., 8 (4), 735–741. https://projecteuclid.org:443/euclid.pjm/1103039699

function gale_gross(x, y, spectrum_x, spectrum_y, weights_x, weights_y, pts_x, pts_y)
    sqnrmdist(x, y) = sum((x[i]-y[i])^2 for i in eachindex(x))

    function _f(x, sx)
        prod([sqnrmdist(x, s) for s in sx])
    end
    function _f(i, x, sx)
        prod([sqnrmdist(x, s) / sqnrmdist(sx[i], s) for s in sx if s != sx[i]])
    end
    function _ϕ(x, as)
        prod([sqnrmdist(x, s) for s in as])
    end
    function _ϕ(i, x, as)
        prod([sqnrmdist(x, s) for s in as if s != as[i]])
    end

    μs = weights_x
    νs = weights_y
    m = length(μs)
    n = length(νs)
    αs = pts_x
    βs = pts_y

    f(i, x) = _f(i, x, spectrum_x)
    g(i, y) = _f(i, y, spectrum_y)
    f(x) = _f(x, spectrum_x)
    g(y) = _f(y, spectrum_y)
    ϕ(i, x) = _ϕ(i, x, αs)
    ψ(i, y) = _ϕ(i, y, βs)
    ϕ(x) = _ϕ(x, αs)
    ψ(y) = _ϕ(y, βs)

    m1 = +f(x)ϕ(x) * (g(y)ϕ(x) + sum([(g(j, y) - νs[j]) * ϕ(j, x) for j = 1:n]))
    m2 = -g(y)ψ(y) * (f(x)ψ(y) + sum([(f(i, x) - μs[i]) * ψ(i, y) for i = 1:m]))
    m3 = -(f(x)ϕ(x))^2 + (g(y)ψ(y))^2

    m1 + m2 + m3
end

function ex_gross58_poly()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    sup = [[0.5]]
    wgt = [1.0]

    pts = [[1.0], [0.0]]

    g(x, y) = gale_gross(x, y, sup, sup, wgt, wgt, pts, pts)
    u1(x, y) = g(x, y)
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
