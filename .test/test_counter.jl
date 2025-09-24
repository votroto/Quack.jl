include("../src/Quack.jl")
using Revise

# Double Oracle Algorithm for Computing Equilibria in Continuous Games
# Adam, Lukáš & Horčík, Rostislav & Kasl, Tomáš & Kroupa, Tomáš. (2021).

function ex_counter()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    function v1(x, y)
        if x-y >= 0
            return x+y
        elseif x-y<=0 && 2x-y>=0
            return 8x-6y
        elseif 2x-y<=0
            return -2x-y
        end
    end
    u1(x,y) = -v1(x[1], y[1])
    u2(x, y) = -u1(x, y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_what()
    dom_nneg(x) = (x[1] * (1 - x[1]),)
    dom_null(x) = 0

    u1(x, y) = -sqrt(sqrt((x[1] - y[1])^2))
    u2(x, y) = -sqrt(sqrt((x[1] - tan(y[1]))^2))

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
