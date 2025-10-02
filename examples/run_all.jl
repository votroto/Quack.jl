using Revise
include("utils.jl")

include("test_ll_adam21.jl")
include("test_ll_chasnov20.jl")
include("test_ll_daskalakis23.jl")
include("test_ll_dresher61.jl")
include("test_ll_gale58.jl")
include("test_ll_golman09.jl")
include("test_ll_karlin59.jl")
include("test_ll_kroupa21.jl")
include("test_ll_mertikopoulos18.jl")
include("test_ll_misc.jl")
include("test_ll_nguyen23.jl")
include("test_ll_nie22.jl")
include("test_ll_parrilo06.jl")
include("test_ll_ratliff13.jl")
include("test_ll_razaviyayn20.jl")
include("test_ll_stein07.jl")
include("test_ll_stein08.jl")
include("test_ll_surjanovic.jl")
include("test_ll_yasodharan19.jl")
include("test_ll_zheng23.jl")
include("test_ll_zhou20.jl")

run_sets = [
    #"adam21"
    #"chasnov20"
    #"daskalakis"
    #"dresher61"
    #"golman09"
    #"gross58"
    #"karlin59"
    "kroupa21"
    #"mertikopoulos18"
    #"misc"
    #"nguyen23"
    #"nie21"
    #"parrilo06"
    #"ratliff13"
    #"razaviyayn20"
    #"stein07"
    #"stein08"
    #"surjanovic"
    #"yasodharan19"
    #"zheng23"
    #"zhou19"
]

example_symbols = filter(x -> startswith(string(x), "ex_"), names(Main))
#=

example_symbols = [
    :_ex_zhou19_5_1
    #:_ex_zhou19_5_2_ii
    #:_ex_zhou19_5_5_i
    #:_ex_zhou19_5_5_ii
    #:_ex_zhou19_5_6_i
    #:_ex_zhou19_5_6_ii
    #:_ex_zhou19_5_7_i
    #:_ex_zhou19_5_7_i_polar
    #:_ex_zhou19_5_7_ii
]
=#

out = IOBuffer()
for example_symbol in example_symbols
    example_eval = eval(example_symbol)
    example_name = String(example_symbol)
    example_set = split(example_name, '_')[2]
    example_label = replace(example_name, '_' => '.')

    if example_set ∉ run_sets
        continue
    end
println(example_name)
   # try
    run_example_tex(example_label, example_eval; io=out)
    #catch
    #end
end
res = String(take!(out))