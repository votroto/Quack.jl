module Quack

export quack_oracle, interior_init, oracle

include("utils.jl")
include("symbolics_utils.jl")
include("iterable.jl")
include("oracle.jl")
include("homotopy_matrix_nash.jl")
include("equilibrium.jl")

end
