using Graphs, Combinatorics

include("dsep.jl")
include("starsep.jl")
include("Csep.jl")
include("common.jl")

function dsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_dsepstatements(H))
end    

function starsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_starsepstatements(H))
end 


function Csep_skeleton(H::SimpleDiGraph, C)
    return skel_from_statements(H, get_Csepstatements(H, C))
end 

Csep_skeleton(H::SimpleDiGraph) = Csep_skeleton(H, constant_weights(H))


function C_star_difference(H::SimpleDiGraph)
    L1 = get_Csepstatements(H, constant_weights(H))
    L2 = get_starsepstatements(H)
    return setdiff(L1,L2)
end 



function C_star_skeletons_unequal(H::SimpleDiGraph)
    return !(Csep_skeleton(H) == starsep_skeleton(H))
end 
