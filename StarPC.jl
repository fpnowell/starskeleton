include("oracle.jl")


function PCstar(n, degbound, stmts) 
    E = skeleton_edges_from_statements(n, degbound,stmts)
    G = cp_dag([],E)
    G = find_colliders(G, stmts)
    #G = orient_all_cycles(G,stmts)
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
                push!(stmts,[i,j,K])
            end 
    end 
    G_out = find_colliders(G_out,stmts)
    G_out = orient_all_cycles(G_out, stmts)
    return G_out
end 

#PROBLEM: PCstar is not orienting cycles. I need to gather more statements for this! 

G = parental_ER_DAG(20, 0.1)
C = randomly_sampled_matrix(G)
l = max_in_degree(G)

function test_PCstar(G,C,l) 
    if !is_connected(G)
        return 3
    else 
        G_out1 = PCstar(G,C,l)

        #G_out2 = PCstar(Graphs.nv(G), l, get_Csep_stmts_bounded(G,C,l))
        G_out2 = cp_dag(get_edges(wtr(G,C)[1]), [])

        return G_out1.skeleton == G_out2.skeleton, G_out1.colliders == G_out2.colliders, G_out1.directed_edges == G_out2.directed_edges
    end 
end 

G_out = PCstar(G,C,l)

true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])