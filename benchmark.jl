
using CSV
using DataFrames

include("StarPCvar2.jl")


#PLAN for benchmarks: --- #nodes    #degree     #trials         #avg true edges         #avg edges w/o cycles       #avg. edges with cycles
#                            10          3          1000
#                            10          4          1000
#                            10          5          1000
#                            15          3          100       
#                            15          4          100
#                            15          5          100
#                            24          3          10
#                            24          4          10 
#                            24          5??        10 
#                            31         3           3
#                           ... However many you manage to do.    


function key_values(G,C,l)
    G_no_cycles, stmts, sep_sets, G, C, degbound  = PCstarvar2(G,C,l)
    G_w_cycles= orient_all_cycles_var2(G_no_cycles, stmts, sep_sets, G,C,degbound)
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    return length(directed_edges(G_no_cycles)), length(directed_edges(G_w_cycles)), length(directed_edges(true_CPDAG))


end 
"""
save_results_to_csv(f, inputs; filename="results.csv")

Evaluates function `f` on each element of `inputs` and writes the results to a CSV file.

- `f`: a function that returns either a single value or a tuple of values.
- `inputs`: a collection of inputs (e.g., vectors, tuples) to be passed to `f`.
- `filename`: the name of the output .csv file (default: "results.csv").
"""
function save_results_to_csv(f, inputs; filename="results.csv")
    results = []

    for x in inputs
        output = f(x...)
        push!(results, output isa Tuple ? output : (output,))
    end

    df = DataFrame(results)
    CSV.write(filename, df)
end

threeDAGs= []
i = 0 
while i < 100
    G = parental_ER_DAG(15, 0.2)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 3 
        push!(threeDAGs, [G,C,l])
        i+= 1
    end 
end 

save_results_to_csv(key_values, threeDAGs)

fourDAGs= []
i = 0 
while i < 100
    G = parental_ER_DAG(15, 0.2)
    C = randomly_sampled_matrix(G)
    l= max_in_degree(G)
    if l == 4
        push!(fourDAGs, [G,C,l])
        i+= 1
    end 
end 

save_results_to_csv(key_values, fourDAGs)


fiveDAGs= []
i = 0 
while i < 100
    G = parental_ER_DAG(15, 0.25)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 5
        push!(fiveDAGs, [G,C,l])
        i+= 1
    end 
end 

save_results_to_csv(key_values, fiveDAGs)