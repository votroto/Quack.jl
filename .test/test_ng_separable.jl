include("../src/Quack.jl")
using Revise

function prettyprints(actss, wghtss)
    for p in eachindex(actss)
        for i in eachindex(actss[p])
            if wghtss[p][i] > 5e-4
                print(round.(actss[p][i];digits=3), ", ", round(wghtss[p][i]*100;digits=1), " %")
                print("; ")
            end
        end
        println()
    end
end

ball(x) = -x^2 + 1

#u1(x, y, z) = −2*x*y^2 + 5*x*y − y −2*x^2 − 4*x*z − 2*z
#u2(x, y, z) = 2*x*y^2 − 2*x^2 − 5*x*y + y −2*y*z^2 − 2*y^2 + 5*y*z
#u3(x, y, z) = 4*x^2 + 4*x*z + 2*z + 2*y*z^2 + 2*y^2 − 5*y*z

u1(x, y, z) = -2 * x * y^2 - 2 * x^2 + 5 * x * y - 4 * x * z - y - 2 * z
u2(x, y, z) = 2 * x * y^2 - 2 * y * z^2 - 2 * x^2 - 5 * x * y - 2 * y^2 + 5 * y * z + y
u3(x, y, z) = 2 * y * z^2 + 4 * x^2 + 4 * x * z + 2 * y^2 - 5 * y * z + 2 * z

quack = Quack.quack_oracle((u1, u2, u3), (ball, ball, ball))
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)

#@show (actions, mixed, vals, best) = Quack.fixed_iters(quack, 4)
#=
start_candidate(as, ws) = [as[i] for i in eachindex(as) if ws[i] >= 0.1]
filtered = ntuple(i -> start_candidate(actions[i], mixed[i]), 3)

quack = Quack.quack_oracle((u1,u2,u3), (ball, ball, ball), filtered)
@show cnt, (actions, mixed, vals, best) = Quack.until_eps(quack, 1e-3)
=#
