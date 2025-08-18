include("oracle.jl")
include("PCstar_dict.jl")

#PC skeleton: reconstructs edges of skeleton by querying the oracle on a "need-to-know" basis.
#outputs collected statements in stmts 
function PC_skeleton_query(G::SimpleDiGraph, C, degbound)
    #construct a Csep-dictionary, but only go as far as necessary to separate non-adjacent i-j
    Csep_sets = Dict{Tuple{Int, Int}, Vector{Set{Any}}}()
    n = Graphs.nv(G)
    n_wtr_edges = Graphs.ne(wtr(G,C)[1])
    println("Computing Csep dictionary...")
    for j in 1:n, i in 1:(j-1)
        for K in collect(powerset(setdiff(1:n, [i, j]), 0, degbound))
            if Csep(G, C, K, i, j)
                #push!(stmts, [minimum([i,j]), maximum([i,j]), K])
                push!(get!(Csep_sets, (i, j), Vector{Set{Int}}()), Set(K))
                break
            end
        end
    end 


    E = []
    for j in 1:Graphs.nv(G), i in 1:(j-1)
        if !haskey(Csep_sets, (i,j))
            push!(E,(i,j))

        end 
    end 
    println("Skeleton recovered!")
    return E, Csep_sets 
end


#modified PCstar which queries the oracle as needed to find colliders
#input is the true DAG with in-degree bounded by degbound
function PCstar_query(G::SimpleDiGraph,C,degbound;orient_cycles = false, apply_rules = false )
    (E, Csep_sets) = PC_skeleton_query(G,C,degbound)
    G_out = cp_dag([],E)
    #add additional separating sets for detecting colliders
    println("Gathering extra statements for collider orientation...")
    for triple in get_unshielded_triples(G_out)
        (i,k,j) = triple 
        for K in collect(powerset(setdiff(union(neighbors(G_out.skeleton,i),neighbors(G_out.skeleton, j)),[i,j]), 0, degbound))
            if Csep(G,C,K,i,j) && !(K in Csep_sets[min(i,j),max(i,j)]) #you might have to sort K 
                push!(get!(Csep_sets, (min(i, j), max(i,j)), Vector{Set{Int}}()), Set(K))
            end
        end  
    end 
    G_out = find_colliders_dict(G_out, Csep_sets)
    if apply_rules 
        n_edges_wo_cycles = length(directed_edges(apply_meek(G_out)))
    else 
        n_edges_wo_cycles = length(directed_edges(G_out))
    end 
    if orient_cycles && !isempty(colliders(G_out))
        G_out = orient_all_cycles_query(G_out, G,C, Csep_sets,degbound)
    end 
    if apply_rules
        G_out = apply_meek(G_out)
    end
    n_edges_w_cycles = length(directed_edges(G_out))
    return G_out, n_edges_wo_cycles, n_edges_w_cycles
end 

