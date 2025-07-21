struct Subgame{F<:Function,A,T,N} <: AbstractArray{T,N}
    payoffs::NTuple{N,F}
    actions::NTuple{N,A}
end

