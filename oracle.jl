using CausalInference 

include("separation.jl")


## dsep statements 


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



##(unweighted) starsep statements 


function get_starsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(collect(Graphs.vertices(G)), [i,j]) #unlike d-sepstatements, we don't consider only subsets of ne(i) or ne(j)
        for K in collect(powerset(ne_ij))
            if starsep(H, i, j, K)
                push!(L, [i,j,K])
                end
        end
    end
    return L
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


#Csep statements 


function get_Csepstatements(G::SimpleDiGraph, C)
    L = []
    for i in collect(Graphs.vertices(G)), j in 1:i-1
        for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
            if Csep(G,C,K,i,j)
                push!(L,[minimum([i,j]),maximum([i,j]),K])
            end 
        end 
    end 
    return L 
end 


get_Csepstatements(G::SimpleDiGraph) = get_Csepstatements(G, constant_weights(G))
    

function get_Csep_stmts_var(G::SimpleDiGraph, C)
    L = [] 
    for K in collect(powerset(Graphs.vertices(G)))
        for i in setdiff(collect(Graphs.vertices(G)), K), j in 1:i-1
            if Csep(G,C,K,i,j)
                push!(L,[j,i,K])
            end 
        end 
    end 
    return L 
end 

function get_Csep_stmts_bounded(G::SimpleDiGraph,C, k)
    L = [] 
    #(G,C) = wtr(G,C)
    for K in collect(powerset(Graphs.vertices(G),0,k))
        for i in setdiff(collect(Graphs.vertices(G)), K), j in 1:i-1
            if Csep(G,C,K,i,j)
                push!(L,[minimum([i,j]),maximum([i,j]),K])
            end 
        end 
    end 
    return L 
end 



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

#Csep dictionary
#given a true DAG with bounded in-degree, construct a dictionary 
# keys are non-adjacent pairs [i,j]
#values are lists of all separating sets of length <= degbound
#Question: an alternative
function Csep_dict(G,C,degbound)
    Csep_sets = Dict{Tuple{Int, Int}, Vector{Vector{Any}}}()
    #(G,C) = wtr(G,C)
    for K in collect(powerset(Graphs.vertices(G),0,degbound))
        V_without_K = setdiff(collect(Graphs.vertices(G)), K)
        for (i,j) in [(i, j) for (i, j) in Iterators.product(V_without_K, V_without_K) if i < j]
                if Csep(G,C,K,i,j)
                    push!(get!(Csep_sets, (i, j), Vector{Vector{Int}}()), K)
                end 
        end 
    end 
    return Csep_sets
end 