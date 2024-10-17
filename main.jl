using CausalInference, Graphs, TikzPictures, TikzGraphs
using Combinatorics


function get_dsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for  edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(union(neighbors(G,i),neighbors(G,j)), [i,j]) 
        for K in collect(powerset(ne_ij))
            #TODO: currently missing line 5 of the pseudocode ( (i,k) in G, etc.. )! Do you need this!? 
            if dsep(H, i,j, K);
                push!(L, [i,j,K])
                end
        end
    end
    return L
end

function dsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_dsepstatements(H))
end    

#QUESTION: in its current state, this simply removes edges from G
#as they appear in sort!(S) 
#Is this enough? Something else to consider? 
function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
    G = complete_graph(nv(H))
    sort!(S, by = x -> length(x[3]))
    for statement in S
        i, j, K = statement 
        if has_edge(G, i, j)
            rem_edge!(G, i, j)
        end
    end
    return G
end



#TODO: there has to be a more efficient way of doing this
function get_skeleton(H::SimpleDiGraph)
    n = nv(H)
    G = SimpleGraph(n,0)
    for edge in edges(H)
        add_edge!(G, edge)
    end
    return G 
end 

same_skeleton(H::SimpleDiGraph, G::SimpleGraph) = (get_skeleton(H) == G)








#= function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
        G = complete_graph(nv(H))
        sort!(S,by = x->length(x[3]))
        for edge in edges(G)
            i = src(edge)
            j = dst(edge)
            for k in 1:length(S)
                if in([i,j,S[k][3]],S)
                    rem_edge!(G, i,j)
                end
            end
        end
        return G
end =#



#= G = complete_graph(3) 

nv(G)

ne(G)

rem_edge!(G, 1,2)

ne(G) 

t = plot(G, ["1","2","3"])

save(PDF("graph"), t)
 =#

 #TODO: write code that gives me MAXIMALLY separated sets (reduces complexity)