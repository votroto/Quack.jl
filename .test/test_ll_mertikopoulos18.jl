include("../src/Quack.jl")
using Revise

# Optimistic Mirror Descent In Saddle-Point Problems: Going The Extra (Gradient) Mile
# Panayotis Mertikopoulos, Bruno Lecouat, Houssam Zenati, Chuan-Sheng Foo, Vijay Chandrasekhar, Georgios Piliouras

function ex_mertikopoulos18_fig1()
    dom_nneg(x) = (x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x,y) = ((x-0.5)*(y-0.5)+1/3*exp(-(x-1/4)^2-(y-3/4)^2))

    u1(x,y) = v1(x[1], y[1])
    u2(x,y) = -u1(x,y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

function ex_mertikopoulos18_2_2()
    dom_nneg(x) = (1 + x[1], 1 - x[1])
    dom_null(x) = 0

    v1(x,y) = -(x^4*y^2+x^2+1)*(x^2*y^4-y^2+1)

    u1(x,y) = v1(x[1], y[1])
    u2(x,y) = -u1(x,y)

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
