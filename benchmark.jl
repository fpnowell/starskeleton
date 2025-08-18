#methods for generating .csv data with results of PCstar
using CSV
using DataFrames

include("PCstar.jl")    



#INPUT: a weighted DAG with in-degree l
#OUTPUT: The tuple #edges(G) , #edges(G^tr), #edges directed by PCstar w/o cycles, #edges with cycle orientation, boolean checking correctness
function table_entries(G,C,l)
    G_out , n1, n2 = PCstar_query(G,C,l;orient_cycles = true, apply_rules = true  )
    #G_out3 = orient_all_cycles(G_no_cycles, G,C,sep_sets, l, 3)
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    return length(edges(G)), length(directed_edges(true_CPDAG)), n1, n2, (issubset(directed_edges(G_out), directed_edges(true_CPDAG)) && G_out.skeleton == true_CPDAG.skeleton && G_out.colliders == true_CPDAG.colliders )

end 

#Function which writes table_entries to a .csv file. 

function save_results_to_csv(f, inputs; filename="results.csv")
    results = []

    for i in 1:length(inputs)
        println("Computing CPDAG " ,  i  ,  " out of " , length(inputs) , " ... ")
        output = f(inputs[i]...)
        if output[5] == false
            throw(ErrorException("Something's wrong at index $i !!! Returning inputs."))
            return inputs  # Alternatively, just throw without returning if preferred
        end

        push!(results, output isa Tuple ? output : (output,))
    end

    df = DataFrame(results)
    CSV.write(filename, df)
end

#generate .csv with table_entries data for #trials-many randomly generated parental_ER_DAGs 
function run_benchmark(trials, n,  p, l )
    DAGs = []
    #first generate the DAGs
    i = 0 
    while i < trials 
        G = parental_ER_DAG(n,p)
        C = randomly_sampled_matrix(G)
        if max_in_degree(G) == l 
            push!(DAGs, [G,C,l])
            i +=1
        end 
    end 
    println("Running benchmarks...")
    save_results_to_csv(table_entries, DAGs; filename = "$n indeg $l.csv " )
end 


#gather .csv files 

#10 node DAGs 

#run_benchmark(100, 10, 0.2, 3)
#run_benchmark(100, 10, 0.25, 4)
#run_benchmark(100, 10, 0.3, 5)

#15 node DAGs 

#run_benchmark(100, 15, 0.1, 3)
#run_benchmark(100, 15, 0.15, 4)
#run_benchmark(100, 15, 0.2, 5)

#22 node DAGs 

#run_benchmark(10, 22, 0.07, 3)
#run_benchmark(10, 22, 0.1, 4)
#run_benchmark(10, 22, 0.15, 5)

#31 node DAGs 


#run_benchmark(1, 31, 0.05, 3)
#run_benchmark(1, 31, 0.075, 4)
#run_benchmark(1, 31, 0.1, 5)


