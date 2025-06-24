include("oracle.jl")


#Dictionary version of PCstar, which starts from dictionaries 
#keys are pairs (i,j), values are separating sets
function PC_skel_dict(n,sep_dict)
    E = []
    #sep_sets = Dict{Tuple{Int, Int}, Vector{Int}}()
    for j in 1:n, i in 1:(j-1)
        if !haskey(sep_dict, (i,j))
            push!(E,(i,j))
        end 
    end 
    return E, sep_dict
end 

function PCstar_dict(n, sep_dict)
    E, sep_dict = PC_skel_dict(n, sep_dict)
    G_out = cp_dag([],E)
    G_out = find_colliders_dict(G_out, sep_dict)
    G_out = orient_all_cycles_dict(G_out, sep_dict)
    return G_out

end 