include("test_ll_parrilo06.jl")
include("test_ll_stein07.jl")
include("test_ll_stein08.jl")

#=
out = IOBuffer()
println(); println("ex.parrilo06.2.1"); run_example_tex("ex.parrilo06.2.1", ex_parrilo06_2_1; io=out)
println(); println("ex.parrilo06.3.1"); run_example_tex("ex.parrilo06.3.1", ex_parrilo06_3_1; io=out)
println(); println("ex.parrilo06.3.2"); run_example_tex("ex.parrilo06.3.2", ex_parrilo06_3_2; io=out)
println(); println("ex.stein07.4.3.1"); run_example_tex("ex.stein07.4.3.1", ex_stein07_4_3_1; io=out)
println(); println("ex.stein08.2.3"); run_example_tex("ex.stein08.2.3", ex_stein08_2_3; io=out)
println(); println("ex.stein08.3.10"); run_example_tex("ex.stein08.3.10", ex_stein08_3_10; io=out)
res = String(take!(out))
=#

#=
include("test_ll_nie22.jl")
out = IOBuffer()
println(); println("ex.nie21.6.3.i"); run_example_tex("ex.nie21.6.3.i", ex_nie21_6_3_i; io=out)
println(); println("ex.nie21.6.3.ii"); run_example_tex("ex.nie21.6.3.ii", ex_nie21_6_3_ii; io=out)
println(); println("ex.nie21.6.5"); run_example_tex("ex.nie21.6.5", ex_nie21_6_5; io=out)
res = String(take!(out))
=#


include("test_ll_surjanovic.jl")
out = IOBuffer()
println(); println("ex.surjanovic.ackley"); run_example_tex("ex.surjanovic.ackley", ex_surjanovic_ackley; io=out)
println(); println("ex.surjanovic.boha1"); run_example_tex("ex.surjanovic.boha1", ex_surjanovic_boha1; io=out)
println(); println("ex.surjanovic.branin"); run_example_tex("ex.surjanovic.branin", ex_surjanovic_branin; io=out)
res = String(take!(out))
