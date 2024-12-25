module Quack

export quack_oracle, feasible_init, oracle
export until_eps, fixed_iters

include("utils.jl")
include("quack.jl")
include("oracle.jl")
include("equilibrium_impl.jl")
include("equilibrium.jl")

end