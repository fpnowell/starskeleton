include("main.jl")

#TODO: I don't think any of these are completely correct yet. 


function starsep(H::SimpleDiGraph, i::Int64, j::Int64, K::Vector{Int64})
#PROBLEM: all_simple_paths only collects DIRECTED PATHS! 
    L = collect(all_simple_paths(get_skeleton(H),i,j))
    bool = true 
    for P in L
        if is_star_connecting(H, K, P) 
            bool = false 
        end 
    end 
    return bool
end 

#QUESTION: what happens if K is the empty set? what if P is an EDGE? 
#IDEA: handle the case in which P is an edge separately? 
#IDEA2:
#= 
function is_star_connecting(H::SimpleDiGraph, K::Vector{Int64}, P::Vector{Int64})
    #FIXME: this only works when P is a "proper" path, i.e. with >2 distinct nodes
    K_blanket = collect(ancestors(H,K))
    colliders = []
    bool = true 
    for l in 2:(length(P)-1)
        #collect every collider along the path 
        if has_edge(H, P[l-1], P[l]) == has_edge(H, P[l+1], P[l]) == true
            if in(P[l], K_blanket)
                push!(colliders, P[l])
            #if a collider is not in K_blanket, P is not *-connecting given K
            else
                #print("path has collider not in K-blanket")
            
                bool = false
                break
            end
        end  
    end 
    #if P contains more than one collider, P is not *-connecting 
    if length(colliders) > 1
        bool = false
        #print("K contains more than one collider")
    end 
    #check if K contains non-colliders
    if !isempty(setdiff(K, colliders))
        bool = false 
        #print("K contains a non-collider")
    end 
    return bool 
end  =#

function is_star_connecting(H::SimpleDiGraph, K::Vector{Int64}, P::Vector{Int64})
    if length(P) == 2
        # The path is *-connecting only if K is empty and there is an edge between the two nodes
        if isempty(K) && (has_edge(H, P[1], P[2]) || has_edge(H, P[2], P[1]))
            return true
        else
            return false
        end
    end
    K_blanket = collect(ancestors(H,K))
    colliders = get_colliders(H, P)
    bool = true 
        #if P contains more than one collider, P is not *-connecting 
    if length(colliders) > 1
            bool = false
            #print("K contains more than one collider")
        end 
        #check if K contains non-colliders
        if !isempty(setdiff(K, colliders))
            bool = false 
            #print("K contains a non-collider")
        end 
        if !isempty(setdiff(colliders, K_blanket))
            bool = false 
            #print("Path has a collider not in Ancestors(K)")
        end 
        return bool 
end 



#better, but I still need an appropriate way of handling EDGES! 
function get_starsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(union(neighbors(G,i),neighbors(G,j)), [i,j]) 
        for K in collect(powerset(ne_ij))
            if starsep(H, i,j, K);
                push!(L, [i,j,K])
                break
                end
        end
    end
    return L
end


function starsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_starsepstatements(H))
end    

function get_colliders(H::SimpleDiGraph, P::Vector{Int64})
    colliders = Int64[]
    for j in 2:(length(P) -1)
        if has_edge(H, P[j-1], P[j]) == has_edge(H, P[j+1],P[j]) == true 
            push!(colliders, P[j])
        end 
    end
    return colliders 
end


testgraph = SimpleDiGraph(5,0)

edgelist = [(1,2),(2,3),(1,4),(5,4)]

for edge in edgelist
    add_edge!(testgraph, edge)

end

include("cassio.jl")

cassiostarstatements = get_starsepstatements(cassio)

show(sort!(cassiostarstatements, by = x->length(x[3])))

include("collider.jl")