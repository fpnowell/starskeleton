include("main.jl")

#generates a DAG on n nodes with edge (i,j) added with probability p 
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


#script which verifies claims on randomly generated DAGs 

function test_for_condition(k::Int, n::Int, p::Float64)
    i = 0
    while i < k
        testgraph = generate_random_dag(n, p)
        #if same_skeleton(testgraph, starsep_skeleton(testgraph))
        #if issubset(get_dsepstatements(testgraph), get_starsepstatements(testgraph))
        if isempty(statement_difference(testgraph))
        #if verify_claim(testgraph)
            i = i+1
        else
            DAG_to_pdf(testgraph, "counterexample")
            serialize("counterexample.jls", testgraph)
            print("counterexample found!")
            break 
        end
    end 
    
end 



#= i = 0
while i < 100
    testgraph = generate_random_dag(7, 0.5)
    if same_skeleton(testgraph, starsep_skeleton(testgraph)) && issubset(get_dsepstatements(testgraph), get_starsepstatements(testgraph))
    #if verify_claim(testgraph)
        i = i+1
    else
        DAG_to_pdf(testgraph, "counterexample")
        serialize("counterexample.jls", testgraph)
        print("counterexample found!")
        break 
    end
end 

 =#
