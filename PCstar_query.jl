include("oracle.jl")
include("PCstar_dict.jl")
include("meek.jl")

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



function orient_induced_cycle_query(G_out::CPDAG, V::Vector, G::SimpleDiGraph, C, Csep_sets, degbound)
    

    indV = induced_subgraph(G_out, V)
    skel = skeleton(indV)
    coll = colliders(indV) 
    if length(coll) > 1
        return G_out
    end
    (k1, k, k2) = coll[1]

    for v in setdiff(V, [k])
        for pi in collect(all_simple_paths(G_out.skeleton, v, k))
            #println("Checking path: ", pi)
            #FIXME: it's not enough to look at sinks! 
            if !issubset(pi, V) && !any(i -> contains_subsequence(pi,i), colliders(G_out))
                #println("Condition fulfilled!")
                return G_out
            end
        end 
    end  

    neV = setdiff(unique(Iterators.flatten([Graphs.neighbors(skeleton(G_out),v) for v in V])), V)

    
    for i in setdiff(V, coll[1])

        for j in setdiff(V,[i,k]) 
            K_j = [j]
            if Csep(G,C,K_j,i,k)
                 if !(Set(K_j) in Csep_sets[i,k])
                    push!(get!(Csep_sets, (i, k), Vector{Set{Any}}()), Set(K_j))
                end     
            end 
        end
    end

    source_dict = Dict()

    for i in V

        if i in coll[1]

            source_dict[i] = 1
            continue
        end

        for K in unique(Csep_sets[i,k])

            if length(intersect(V, K)) == 1
                source_dict[i] = 1
                break
            end
        end
    end

    for i in V
        
        if !haskey(source_dict, i)
            source_dict[i] = 0
        end
    end

    source = k1

    for i in setdiff(V, coll[1])

        (j, l) = neighbors(skel, i)

        if length(V) == 4 && source_dict[i] == 1
            source = i
        elseif length(V) == 4 && source_dict == 0
            break 



        elseif source_dict[i] == 1 && source_dict[j] != source_dict[l]
            source = i
            break

        elseif length(V) == 5 && source_dict[i] == 1 
            if length(intersect(unique(Iterators.flatten((filter(K -> length(intersect(V,K)) == 1 && length(K) == minimum(length.(Csep_sets[i,k])) , unique(Csep_sets[i,k]))))),V)) == 2  
                source = i 
                break
            end
  
        end
    end

    if source == k1
        
        return G_out
    end 
    if source != minimum(V)
        println(V , "is being incorrectly oriented!")
    else
        println("Orienting cycle " , V , " of length ", length(V))
    end 

    D = [e for e in directed_edges(G_out)]
    E = [e for e in undirected_edges(G_out)]
    prev_node = source
    cur_node = neighbors(skel, prev_node)[1]

    while !(cur_node == k)

        push!(D, (prev_node, cur_node))
        new_node = setdiff(neighbors(skel, cur_node), [prev_node])[1]
        prev_node = cur_node
        cur_node = new_node
        
    end


    prev_node = source
    cur_node = neighbors(skel, prev_node)[2]

    while !(cur_node == k)

        push!(D, (prev_node, cur_node))
        new_node = setdiff(neighbors(skel, cur_node), [prev_node])[1]
        prev_node = cur_node
        cur_node = new_node
        
    end

    return cp_dag(unique(D), setdiff(E, union(D, reverse.(D)))) 
end



function orient_all_cycles_query(G_out::CPDAG, G::SimpleDiGraph, C, Csep_sets, degbound)
    for coll in colliders(G_out)
        cycles = find_induced_cycles(G_out,coll)
        for cycle in cycles 
            G_out = orient_induced_cycle_query(G_out, cycle, G,C, Csep_sets, degbound)
            if undirected_edges(G_out) == []
                break 
            end 

        end 
    end
    return G_out

end 
