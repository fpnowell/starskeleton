using CausalInference 

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


function dsep_statements_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = get_dsepstatements(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 
