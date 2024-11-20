include("Critical.jl")
include("examplegraphs.jl")

#TODO: The type c, d, and e code should check if the colliders are in K (union an(K)?)

function is_type_b(G::SimpleDiGraph, P::Vector)
    return  issubset([P[1], P[3]], Graphs.outneighbors(G,P[2]))
end 

function is_type_c(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && P[2] in K 

end 

function is_type_d(G::SimpleDiGraph, P::Vector, K::Vector)
    bool = false 
    if issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.inneighbors(G, P[3])) && P[3] in K
        bool = true
    elseif issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.outneighbors(G, P[3])) && P[2] in K 
        bool = true 
    end 
    return bool 
end 

function is_type_e(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1],P[3]], Graphs.outneighbors(G, P[2])) && issubset([P[3],P[5]], Graphs.outneighbors(G, P[4])) && P[3] in K 
end 

#Question: Is something gained from nesting the conditions here, complexity-wise? 
function Csep(G::SimpleDiGraph, C, K::Vector{Int64}, i::Int64, j::Int64)
    G_star = critical_graph(G, K, C)
    undirected_G_star = get_skeleton(G_star)
    paths = collect(all_simple_paths(undirected_G_star, i, j;cutoff = 5)) 
    bool = true 
    for p in paths
        if length(p) == 2 && (Graphs.has_edge(G_star, i,j) || Graphs.has_edge(G_star, j, i))
            bool = false 
            break  
        elseif length(p) == 3 && (is_type_b(G_star, p) || is_type_c(G_star, p, K))
            bool = false 
            break 
        elseif length(p) == 4 && is_type_d(G_star, p, K)
            bool = false 
            break  
        elseif length(p) == 5 && is_type_e(G_star, p,K)
            bool = false 
            break 
        else 
            continue 
        end 
    end 
    return bool 
end 



