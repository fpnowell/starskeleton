include("StarPC.jl")

function orient_induced_cycle_var2(G::CPDAG, V::Vector, stmts::Vector, sep_sets::Dict, trueG::SimpleDiGraph, C,degbound)

    indV = induced_subgraph(G, V)
    skel = skeleton(indV)
    coll = colliders(indV)
    sepset = sep_sets 
    
    if length(coll) > 1
        return G
    end
    (k1, k, k2) = coll[1]
    #add extra statements to stmts so that cycles can be correctly detected
    for i in setdiff(V, coll[1])
        for j in setdiff(V,[i]) 
            K_j = union(setdiff(sepset[min(i,k),max(i,k)], V) ,[j])
            if Csep(trueG,C,K_j,i,k)
                #push!(stmts, [i,k,K_j])
                push!(stmts,[minimum([k,i]),maximum([k,i]),K_j])
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


function orient_all_cycles_var2(G::CPDAG, stmts::Vector,sep_sets::Dict, trueG::SimpleDiGraph, C,degbound)
    for coll in colliders(G)
        cycles = find_induced_cycles(G,coll)
        for cycle in cycles 
            G = orient_induced_cycle_var2(G, cycle, stmts,sep_sets, trueG,C,degbound)
            if undirected_edges(G) == []
                break 
            end 

        end 


    end
    return G 

end 


function PCstarvar2(G::SimpleDiGraph,C,degbound)
    (E, stmts, sep_sets) = PC_skeleton(G,C,degbound)
    G_out = cp_dag([],E)
    for triple in get_unshielded_triples(G_out)
        (i,k,j) = triple 
        K = setdiff(union(neighbors(G_out.skeleton,i),neighbors(G_out.skeleton, j)),[i,j])
            if Csep(G,C,K,i,j)
                push!(stmts,[minimum([i,j]),maximum([i,j]),K])
            end 
    end 
    G_out = find_colliders(G_out,stmts)
    #sinks = [coll[2] for coll in colliders(G_out)] 
    G_out = orient_all_cycles_var2(G_out, stmts, sep_sets, G,C,degbound)
    return G_out
end 
#= 
function test_var2(trials, n, p) 
    i = 0
    while i < trials 

    G = parental_ER_DAG(n, p)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)

    G_out1 = PCstar(G,C,l)
    G_out2 = PCstarvar2(G,C,l)
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    
    if !all([Set(directed_edges(G_out1)) == Set(directed_edges(G_out2)),  issubset(directed_edges(G_out1), directed_edges(true_CPDAG))])
        break 
    else 
        i += 1 

    end 
    end  
        return [i,G]

end  =#

i = 0 
while i < 100

    G = parental_ER_DAG(8, 0.3)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    G_out1 = PCstar(G,C,l)
    G_out2 = PCstarvar2(G,C,l)
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    
    if !all([Set(directed_edges(G_out1)) == Set(directed_edges(G_out2)),  issubset(directed_edges(G_out2), directed_edges(true_CPDAG))])
        break 
    else 
        i += 1 

    end 
end 

G = parental_ER_DAG(31, 0.05)
C = randomly_sampled_matrix(G)
l = max_in_degree(G)
#G_out1 = PCstar(G,C,l)
G_out2 = PCstarvar2(G,C,l)
true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])

#TODO: write a function to see if cycles are oriented? 

DAG_to_pdf(DAG_from_edges(directed_edges(true_CPDAG)), "show")
L = [] 

for coll in colliders(true_CPDAG)
    cycles = find_induced_cycles(true_CPDAG, coll)
    for cycle in cycles 
        push!(L, cycle)
    end 
end 

#Comment: In this one example, it doesn't seem like any cycles are being oriented. 
#This is because there were no orientable cycles to begin with! So in a sense it's "all good" 
