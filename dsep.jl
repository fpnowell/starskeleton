

function get_dsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for  edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(union(neighbors(G,i),neighbors(G,j)), [i,j]) 
        for K in collect(powerset(ne_ij))
            if dsep(H, i,j, K);
                push!(L, [i,j,K])
                end
        end
    end
    return L
end