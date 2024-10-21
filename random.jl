include("main.jl")
#include("starsep.jl")

function generate_random_dag(n::Int, p::Float64)
    G = SimpleDiGraph(n)
    for i in 1:n
        for j in (i+1):n
            # Add directed edge from i to j with probability p
            if rand() < p
                add_edge!(G, i, j)
            end
        end
    end
    return G
end


i = 0
while i < 100
    testgraph = generate_random_dag(7, 0.5)
    #if same_skeleton(testgraph, starsep_skeleton(testgraph)) && issubset(get_dsepstatements(testgraph), get_starsepstatements(testgraph))
    if verify_theorem(testgraph)
        i = i+1
    else
        print("unequal skeletons!")
        break 
    end
end 


