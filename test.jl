using CausalInference, Graphs, TikzPictures, TikzGraphs
using Combinatorics
G = complete_graph(3) 

#nv(G)

#ne(G)

rem_edge!(G, 1,2)

#ne(G) 

t = plot(G, ["1","2","3"])

save(PDF("graph"), t)

collider = SimpleDiGraph(3, 0)

add_edge!(collider, (1,3))

add_edge!(collider,(2,3))

dsep(collider, 1, 2, [])

dsep(collider, 1,2,[3])

cassio = SimpleDiGraph(5,0)

cassioedges = [(1,4),(2,4), (2,5) ,(3,5)]

for edge in cassioedges;
    add_edge!(cassio, edge)
end

dseporacle(1,3,[4,5],cassio)
dseporacle(1,3,[4],cassio)


function get_dsepstatements(G::SimpleDiGraph)
    L = Any[]
    for  edge in edges(complete_graph(nv(G)));
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(union(neighbors(G,i),neighbors(G,j)), [i,j]) 
        for K in collect(powerset(ne_ij))
            if dsep(g, i,j, K);
                push!(L, [i,j,K])
                end
        end
    end
    return L
end

function skel_from_statements(H::SimpleDiGraph, S::Vector{Vector{Any}})
        G = complete_graph(nv(H))
        maxsize = maximum(length(s[3]) for s in S)
        for size in 1:maxsize;
            for edge in edges(G);
                i = src(edge)
                j = dst(edge)
                if has_edge(H,i,j) == false;
                    rem_edge!(G,i,j)
#=                 else
                    for s in S;
                        if length(s[3]) == size;
                            for k in s[3]; 
                                if has_edge(G,i,k);
                                    rem_edge!(G,i,j)
                                elseif has_edge(G, k,j);
                                    rem_edge!(G,i,j)
                                end
                            end
                        end
                    end =#
                end 
            end

        end
        return G
    end


cassiostatements = [[1,2,[]], [3,1,[]], [1,5,[]], [2,3,[]], [3,4,[]], [1,3,[4]]]


diamond = SimpleDiGraph(4,0)

diamond_edges = [(1,2),(1,3),(2,4),(3,4)]

for edge in diamond_edges;
    add_edge!(diamond,edge)
end 

#= rem_edge!(diamond, 2,4)

get_dsepstatements(diamond) =#