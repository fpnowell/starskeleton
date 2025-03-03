include("oracle.jl")


function PCstar(n, degbound, stmts) 
    E = skeleton_edges_from_statements(n, degbound,stmts)
    G = cp_dag([],E)
    G = find_colliders(G, stmts)
    G = orient_all_cycles(G,stmts)
    return G 

end 

function PC_skeleton(G::SimpleDiGraph,C, degbound)
    n = Graphs.nv(G)
    E = [] 
    stmts = []
    for i in 1:n, j in 1:(i-1) 
        separated = false 
        for K in collect(powerset(setdiff(1:n,[i,j]),0,degbound))
            if Csep(G,C,K,i,j)
                push!(stmts,[j,i,K])
                separated = true 
                break 
            end 
        end 
        if !separated 
            push!(E, (j,i))
        end 
    end 
    return unique(E), stmts
end 

function PCstar(G::SimpleDiGraph,C,degbound)
    (E, stmts) = PC_skeleton(G,C,degbound)
    G_out = cp_dag([],E)
    for triple in get_unshielded_triples(G_out)
        (i,k,j) = triple 
        K = setdiff(union(neighbors(G_out.skeleton,i),neighbors(G_out.skeleton, j)),[i,j])
            if Csep(G,C,K,i,j)
                push!(stmts,[minimum([i,j]),maximum([i,j]),K])
            end 
    end 
    G_out = find_colliders(G_out,stmts)
    G_out = orient_all_cycles_var(G_out, stmts, G,C,degbound)
    return G_out
end 

#PROBLEM: PCstar is not orienting cycles. I need to gather more statements for this! 

#TODO: write modified cycle orientation function 

function orient_induced_cycle_var(G::CPDAG, V::Vector, stmts::Vector, trueG::SimpleDiGraph, C,degbound)

    indV = induced_subgraph(G, V)
    skel = skeleton(indV)
    coll = colliders(indV)

    
    if length(coll) > 1
        return G
    end
    (k1, k, k2) = coll[1]
    #add extra statements to stmts
    
    #K = setdiff(neighbors(G.skeleton, k), union(V,sinks))
    for K in collect(powerset(setdiff(Graphs.vertices(trueG),V),0,degbound))
        for i in setdiff(V, coll[1])
            for j in setdiff(V,[i]) 
                K_j = union(K,[j])
                if Csep(trueG,C,K_j,i,k)
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
        
        return G
    end 


    D = [e for e in directed_edges(G)]
    E = [e for e in undirected_edges(G)]
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

function orient_all_cycles_var(G::CPDAG, stmts, trueG::SimpleDiGraph, C,degbound)
    for coll in colliders(G)
        cycles = find_induced_cycles(G,coll)
        for cycle in cycles 
            G = orient_induced_cycle_var(G, cycle, stmts,trueG,C,degbound)
        end 
    end
    return G 

end 


G = parental_ER_DAG(7, 0.3)
C = randomly_sampled_matrix(G)
l = max_in_degree(G)


G_out = PCstar(G,C,l)

true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])





function test_PCstar(G,C,l) 
    if !is_connected(G)
        return 3
    else 
        G_out1 = PCstar(G,C,l)

        G_out2 = PCstar(Graphs.nv(G), l, get_Csep_stmts_bounded(G,C,l))
        #G_out2 = cp_dag(get_edges(wtr(G,C)[1]), [])

        return G_out1.skeleton == G_out2.skeleton, G_out1.colliders == G_out2.colliders, G_out1.directed_edges == G_out2.directed_edges
    end 
end 

k = 1 

while k < 100 
    if all(test_PCstar(G,C,l))
        k += 1 

        G = parental_ER_DAG(11, 0.3)
        C = randomly_sampled_matrix(G)
        l = max_in_degree(G)

    else 
        println("AAAA")
        break 
    end 
end 

k 
