include("oracle.jl")


#PC skeleton: reconstructs edges of skeleton by querying the oracle on a "need-to-know" basis.
#outputs collected statements in stmts 
#TODO: change these methods to use dictionaries too
function PC_skeleton_query(G::SimpleDiGraph, C, degbound)
    n = Graphs.nv(G)
    E = []
    stmts = []
    sep_sets = Dict{Tuple{Int, Int}, Vector{Int}}()

    for i in 1:n, j in 1:(i-1)
        separated = false
        #QUESTION: could I replace this with powerset(neighbors(G,i), 0 k)? 
        for K in collect(powerset(setdiff(1:n, [i, j]), 0, degbound))
            if Csep(G, C, K, i, j)
                push!(stmts, [minimum([i,j]), maximum([i,j]), K])
                sep_sets[(min(i, j), max(i, j))] = K
                separated = true
                break
            end
        end
        if !separated
            push!(E, (min(i,j),max(i,j)))
            sep_sets[(min(i,j),max(i,j))] = []
        end
    end

    return unique(E), stmts, sep_sets
end


#modified PCstar which queries the oracle as needed to find colliders
function PCstar_query(G::SimpleDiGraph,C,degbound,strategy;orient_cycles = false)
    (E, stmts, sep_sets) = PC_skeleton_query(G,C,degbound)
    G_out = cp_dag([],E)
    for triple in get_unshielded_triples(G_out)
        (i,k,j) = triple 
        for K in collect(powerset(setdiff(union(neighbors(G_out.skeleton,i),neighbors(G_out.skeleton, j)),[i,j]), 0, degbound))
            if Csep(G,C,K,i,j)
                push!(stmts,[minimum([i,j]),maximum([i,j]),K])
            end
        end  
    end 
    stmts = unique(stmts)
    G_out = find_colliders(G_out,stmts)
    #sinks = [coll[2] for coll in colliders(G_out)] 
    if orient_cycles && !isempty(colliders(G_out))
        G_out = orient_all_cycles_query(G_out, G,C, sep_sets,degbound,strategy)
    end 
    return G_out, stmts, sep_sets, G, C, degbound 
end 



function orient_induced_cycle_query(G_out::CPDAG, V::Vector, G::SimpleDiGraph, C, sep_sets, degbound, strategy)

    indV = induced_subgraph(G_out, V)
    skel = skeleton(indV)
    coll = colliders(indV)
    sepsets = sep_sets 
    if length(coll) > 1
        return G_out
    end
    (k1, k, k2) = coll[1]
    for v in setdiff(V, [k])
        if !issubset(sepsets[v,k], V)
            return G_out 
            break 
        end 
    end 
    neV = setdiff(unique(Iterators.flatten([Graphs.neighbors(skeleton(G_out),v) for v in V])), V)
    stmts = [] 
    #add extra statements to stmts so that cycles can be correctly detected
    if strategy == 1 #naive approach: collect statements for all K outside the cycle (explodes in complexity)
        for K in collect(powerset(neV,0,degbound))
            for i in setdiff(V, coll[1])
                for j in setdiff(V,[i]) 
                    K_j = union(K,[j])
                    if Csep(G,C,K_j,i,k)
                        push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                    end 
                end
            end 
        end 
    
    elseif strategy == 2 #fixed K for each pair i,k: all nodes in sepset(i,k) not in V. orients "most" cycles (TODO: characterize them!)
        for i in setdiff(V, coll[1])
            K = setdiff(sepsets[i,k], V)
            for j in setdiff(V,[i,k]) 
                K_j = union(K,[j])
                if Csep(G,C,K_j,i,k)
                    #push!(stmts, [i,k,K_j])
                    push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                end 
            end
        end
    elseif strategy == 3 #fixed K: neighbors of the cycle which are not collliders. FIXME: currently not orienting anything. 
        colls = unique([x[2] for x in colliders(G_out)if !isempty(intersect(x, V))])
        for i in setdiff(V, coll[1])
            K = union(setdiff(Graphs.neighbors(skeleton(G_out),i), union(V, colls)), setdiff(neighbors(skeleton(G_out),k)))
            #K = setdiff(Graphs.neighbors(skeleton(G_out),i), union(V,colls))
            for j in setdiff(V,[i,k]) 
                K_j = union(K,[j])
                if Csep(G,C,K_j,i,k)
                    #push!(stmts, [i,k,K_j])
                    push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                end 
            end
        end
    end 

    stmts = unique(stmts)

    sep_dict = Dict()

    for i in V

        if i in coll[1]

            sep_dict[i] = 1
            continue
        end

        for stmt in filter(stmt -> i in stmt && k in stmt, stmts)

            if length(intersect(V, stmt[3])) == 1
                sep_dict[i] = 1
                break
            end
        end
    end

    for i in V
        
        if !haskey(sep_dict, i)
            sep_dict[i] = 0
        end
    end

    source = k1

    for i in setdiff(V, coll[1])

        (j, l) = neighbors(skel, i)

        if length(V) == 4 && sep_dict[i] == 1
            source = i
        



        elseif sep_dict[i] == 1 && sep_dict[j] != sep_dict[l]
            source = i
            break

        elseif length(V) == 5 && sep_dict[i] == 1 
            if length(filter(stmt -> i in stmt && k in stmt && length(intersect(V,stmt[3])) == 1 && length(stmt[3]) == minimum([length(t[3]) for t in stmts]), stmts)) == 2 
                source = i 
                break
            end

        end
    end

    if source == k1
        
        return G_out
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



function orient_all_cycles_query(G_out::CPDAG, G::SimpleDiGraph, C, sep_sets, degbound,strategy)
    for coll in colliders(G_out)
        cycles = find_induced_cycles(G_out,coll)
        for cycle in cycles 
            G_out = orient_induced_cycle_query(G_out, cycle, G,C, sep_sets, degbound,strategy)
            if undirected_edges(G_out) == []
                break 
            end 

        end 
    end
    return G_out 

end 


#old cycle orientation
#=     sep_dict = Dict()

    for i in V

        if i in coll[1]

            sep_dict[i] = 0
            continue
        else 
            sep_dict[i] = length(unique(filter(stmt -> i in stmt && k in stmt && length(intersect(V, stmt[3])) == 1 , stmts))) # currently, this is only garantueed to detect the right source with strategy 2, because it assumes one statement per intermediate node.
        end 
    end 
    for i in V
        
        if !haskey(sep_dict, i)
            sep_dict[i] = 0
        end
    end

    if all(x -> sep_dict[x] == 0 , keys(sep_dict))
        source = k1
    else 
        (maxval, maxkey) = findmax(sep_dict)
        if count(==(maxval), values(sep_dict)) == 1
            source = maxkey 
        else
            source = k1
        end
    end 

    if source == k1 
        
        return G_out
    end 
 =#