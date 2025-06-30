include("oracle.jl")
include("PCstar_dict.jl")

#PC skeleton: reconstructs edges of skeleton by querying the oracle on a "need-to-know" basis.
#outputs collected statements in stmts 
#TODO: change these methods to use dictionaries too
function PC_skeleton_query(G::SimpleDiGraph, C, degbound)
    #construct a Csep-dictionary, but only go as far as necessary to separate non-adjacent i-j
    Csep_sets = Dict{Tuple{Int, Int}, Vector{Set{Any}}}()

#=     for i in 1:n, j in 1:(i-1)
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
    end =#
#=     for K in collect(powerset(Graphs.vertices(G),0,degbound))
        V_without_K = setdiff(collect(Graphs.vertices(G)), K)
        for (i,j) in [(i, j) for (i, j) in Iterators.product(V_without_K, V_without_K) if i < j]
                if Csep(G,C,K,i,j)
                    push!(get!(Csep_sets, (i, j), Vector{Vector{Int}}()), K)
                    #break #don't collect all bounded CI statements
                end 
        end 
    end  =#
    n = Graphs.nv(G)
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
    #sep_sets = Dict{Tuple{Int, Int}, Vector{Int}}()
    for j in 1:Graphs.nv(G), i in 1:(j-1)
        if !haskey(Csep_sets, (i,j))
            push!(E,(i,j))
        end 
    end 
    return E, Csep_sets 
end


#modified PCstar which queries the oracle as needed to find colliders
function PCstar_query(G::SimpleDiGraph,C,degbound,strategy;orient_cycles = false)
    (E, Csep_sets) = PC_skeleton_query(G,C,degbound)
    G_out = cp_dag([],E)
    #add additional separating sets for detecting colliders
    for triple in get_unshielded_triples(G_out)
        (i,k,j) = triple 
        for K in collect(powerset(setdiff(union(neighbors(G_out.skeleton,i),neighbors(G_out.skeleton, j)),[i,j]), 0, degbound))
            if Csep(G,C,K,i,j) && !(K in Csep_sets[min(i,j),max(i,j)]) #you might have to sort K 
                #push!(stmts,[minimum([i,j]),maximum([i,j]),K])
                push!(get!(Csep_sets, (min(i, j), max(i,j)), Vector{Set{Int}}()), Set(K))
            end
        end  
    end 
    G_out = find_colliders_dict(G_out, Csep_sets)
    #sinks = [coll[2] for coll in colliders(G_out)] 
    n_edges_wo_cycles = length(directed_edges(G_out))
    if orient_cycles && !isempty(colliders(G_out))
        G_out = orient_all_cycles_query(G_out, G,C, Csep_sets,degbound,strategy)
    end 
    n_edges_w_cycles = length(directed_edges(G_out))
    return G_out, n_edges_wo_cycles, n_edges_w_cycles
end 



function orient_induced_cycle_query(G_out::CPDAG, V::Vector, G::SimpleDiGraph, C, Csep_sets, degbound, strategy)
    
    sinks = unique([collider[2] for collider in colliders(G_out)])

    indV = induced_subgraph(G_out, V)
    skel = skeleton(indV)
    coll = colliders(indV)
    #sepsets = sep_sets 
    if length(coll) > 1
        return G_out
    end
    (k1, k, k2) = coll[1]
    #TODO: change this to use Graphs.has_path (using excluded vertices)

    for v in setdiff(V, [k])
        for pi in collect(all_simple_paths(G_out.skeleton, v, k))
            #println("Checking path: ", pi)
            if !issubset(pi, V) && isempty(intersect(setdiff(pi,[v,k]), sinks))
                #println("Condition fulfilled!")
                return G_out
            end
        end 
    end  

    #If there is a directed path or a trek containing nodes outside of V, the cycle cannot be oriented
#=     for v in setdiff(V, [k])
        if has_path(G_out.skeleton, v,k;exclude_vertices = union(sinks, setdiff(V, [v,k])))
                #println("Condition fulfilled!")
        return G_out
        end

    end  =#
    neV = setdiff(unique(Iterators.flatten([Graphs.neighbors(skeleton(G_out),v) for v in V])), V)

    #add extra statements to stmts so that cycles can be correctly detected
    if strategy == 1 #naive approach: collect statements for all K outside the cycle (explodes in complexity)
        for K in collect(powerset(neV,0,degbound))
            for i in setdiff(V, coll[1])
                for j in setdiff(V,[i]) 
                    K_j = union(K,[j])
                    if Csep(G,C,K_j,i,k)
                        #push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                        push!(get!(Csep_sets, (i, k), Vector{Vector{Int}}()), Set(K_j))
                    end 
                end
            end 
        end 
    
    elseif strategy == 2 #fixed K for each pair i,k: all nodes in sepset(i,k) not in V. orients "most" cycles (TODO: characterize them!)
        for i in setdiff(V, coll[1])
            #K = setdiff(Csep_sets[i,k], V)
            #K =  []
            for j in setdiff(V,[i,k]) 
                K_j = [j]
                if Csep(G,C,K_j,i,k)
                    #push!(stmts, [i,k,K_j])
                    #push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                    if !(Set(K_j) in Csep_sets[i,k])
                        push!(get!(Csep_sets, (i, k), Vector{Set{Any}}()), Set(K_j))
                    end     
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
                    #push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
                    push!(get!(Csep_sets, (i, j), Vector{Vector{Int}}()), K_j)
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
            #if length(filter(stmt -> i in stmt && k in stmt && length(intersect(V,stmt[3])) == 1 && length(stmt[3]) == minimum([length(t[3]) for t in stmts]), stmts)) == 2 
            #the statement above checks for separating sets 
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
        println("orienting cycle " , V , "of length ", length(V))
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



function orient_all_cycles_query(G_out::CPDAG, G::SimpleDiGraph, C, Csep_sets, degbound,strategy)
    for coll in colliders(G_out)
        cycles = find_induced_cycles(G_out,coll)
        for cycle in cycles 
            G_out = orient_induced_cycle_query(G_out, cycle, G,C, Csep_sets, degbound,strategy)
            if undirected_edges(G_out) == []
                break 
            end 

        end 
    end
    return G_out

end 
#= 
cycles = [] 
for collider in colliders(G_out)
    for cycle in find_induced_cycles(G_out, collider)
            push!(cycles,cycle)
    end 
end 

[orient_induced_cycle_query(G_no_cycles, V, G, C, Csep_sets, 5, 2) for V in cycles]

G_out1 = G_no_cycles
for V in cycles 
    G_out1 = orient_induced_cycle_query(G_no_cycles, V, G, C, Csep_sets, 5, 2)
end   =#
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

 []