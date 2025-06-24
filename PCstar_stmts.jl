include("oracle.jl")


#'original'PCstar, which constructs the CPDAG given a full list of statements (get_Csepstatements(G,C))
function PCstar_stmts(n, degbound, stmts) 
    E ,stmts, sep_sets = PC_skeleton_stmts(n, degbound, stmts)
    G_out = cp_dag([],E)
    G_out = find_colliders(G_out, stmts)
    G_out = orient_all_cycles_stmts(G_out,stmts, sep_sets)
    return G_out 
end 

function PC_skeleton_stmts(n, degbound, stmts) 
    E = []
    sep_sets = Dict{Tuple{Int, Int}, Vector{Int}}()

    for j in 1:n, i in 1:(j-1)
        #sep_sets[i,j] = []
        separated = false 
        for stmt in stmts 
            if i == stmt[1] && j == stmt[2]
                sep_sets[i,j] = stmt[3]
                separated = true 
                break 
            end 

        end 
        if !separated
            push!(E, (i,j))
        end 
    end 
    return unique(E), stmts, sep_sets
end 