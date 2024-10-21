include("k_starsep.jl")

#GOAL: write functions "starsep", "get_starsepstatements" based on k_starsep code 

function get_starsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(union!(neighbors(G,i), neighbors(G,j)), [i,j]) 
        for K in collect(powerset(ne_ij))
            if starsep(H, i, j, K)
                push!(L, [i,j,K])
                end
        end
    end
    return L
end


function starsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_starsepstatements(H))
end 

function starsep(H::SimpleDiGraph, i::Int64, j::Int64, K::Vector{Int64})
    return in(j, star_separation(H, [i], K))
end