include("oracle.jl")


function PCstar(n, degbound, stmts) 
    E = skeleton_edges_from_statements(n, degbound,stmts)
    G = cp_dag([],E)
    G = find_colliders(G, stmts)
    G = orient_all_cycles(G,stmts)
    return G 

end 


stmts = get_Csepstatements(generate_random_dag(7, 0.5))