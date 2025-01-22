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

function star_C_statements(H::SimpleDiGraph)
    return !(issubset(get_starsepstatements(H), get_Csepstatements(H)))
end 


function randomly_sampled_matrix(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = rand(1:10000)
        end 
    end 
    return C

end 