include("main.jl")

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


function get_skeleton(H::SimpleDiGraph)
    n = nv(H)
    G = SimpleGraph(n,0)
    for edge in edges(H)
        add_edge!(G, edge)
    end
    return G 
end 

same_skeleton(H::SimpleDiGraph, G::SimpleGraph) = (get_skeleton(H) == G)

i = 0
while i < 100
    testgraph = generate_random_dag(7, 0.5)
    if same_skeleton(testgraph, dsep_skeleton(testgraph))
        i = i+1
    else 
        print("unequal skeletons!")
        break 
    end
end 

