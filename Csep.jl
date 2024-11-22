include("Critical.jl")

function is_type_b(G::SimpleDiGraph, P::Vector, K::Vector)
    return  issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && !(P[2] in K) 
end 

function is_type_c(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && P[2] in K 

end 

function is_type_d(G::SimpleDiGraph, P::Vector, K::Vector)
    bool = false 
    if issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.inneighbors(G, P[3])) && P[3] in K && !(P[2] in K)
        bool = true
    elseif issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.outneighbors(G, P[3])) && P[2] in K && !(P[3] in K)
        bool = true 
    end 
    return bool 
end 

function is_type_e(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1],P[3]], Graphs.outneighbors(G, P[2])) && issubset([P[3],P[5]], Graphs.outneighbors(G, P[4])) && P[3] in K && !(P[2] in K) && !(P[4] in K)
end 

#Question: Is something gained from nesting the conditions here, complexity-wise? 
function Csep(G::SimpleDiGraph, C, K::Vector, i::Int64, j::Int64)
    if issubset([i,j], K)
        return false 
    end 
    G_star = critical_graph(G, K, C)
    undirected_G_star = get_skeleton(G_star)
    paths = collect(all_simple_paths(undirected_G_star, i, j;cutoff = 4)) 
    bool = true 
    for p in paths
        if length(p) == 2 && (Graphs.has_edge(G_star, i,j) || Graphs.has_edge(G_star, j, i))
            bool = false 
            break  
        elseif length(p) == 3 && (is_type_b(G_star, p, K) || is_type_c(G_star, p, K))
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

Csep(G::SimpleDiGraph, K, i, j) = Csep(G, constant_weights(G), K, i, j )


function Csepstatements_wrt_nodes(G::SimpleDiGraph, C, i, j)
    L = []
    for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
        if Csep(G,C,K,i,j)
            push!(L, K)
        end
    end 
    return L 
end 

Csepstatements_wrt_nodes(G::SimpleDiGraph, i, j) = Csepstatements_wrt_nodes(G, constant_weights(G), i, j)




function get_Csepstatements(G::SimpleDiGraph, C)
    L = []
    for i in collect(Graphs.vertices(G)), j in 1:i-1
        for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
            if Csep(G,C,K,i,j)
                push!(L,[j,i,K])
            end 
        end 
    end 
    return L 
end 

get_Csepstatements(G::SimpleDiGraph) = get_Csepstatements(G, constant_weights(G))
    
