include("starsepbackend.jl")


function get_starsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(vertices(G), [i,j]) #unlike d-sepstatements, we don't consider only subsets of ne(i) or ne(j)
        for K in collect(powerset(ne_ij))
            if starsep(H, i, j, K)
                push!(L, [i,j,K])
                end
        end
    end
    return L
end

function starsep(H::SimpleDiGraph, i::Int64, j::Int64, K::Vector{Int64})
    return in(j, star_separation(H, [i], K))
end

function starsep_statements_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = get_starsepstatements(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 

