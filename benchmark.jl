using CSV
using DataFrames

include("StarPC.jl")    


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
    G_out , n1, n2 = PCstar_query(G,C,l,2;orient_cycles = true )
    #G_out3 = orient_all_cycles(G_no_cycles, G,C,sep_sets, l, 3)
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    return n1, n2, length(directed_edges(true_CPDAG)), length(edges(G)), (issubset(directed_edges(G_out), directed_edges(true_CPDAG)) && G_out.skeleton == true_CPDAG.skeleton && G_out.colliders == true_CPDAG.colliders )

end 

#(length(directed_edges(G_out1)),issubset(directed_edges(G_out1), directed_edges(true_CPDAG))),

function save_results_to_csv(f, inputs; filename="results.csv")
    results = []

    for i in 1:length(inputs)
        println("computing DAG " ,  i  ,  " out of " , length(inputs) , " ... ")
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
    save_results_to_csv(key_values, DAGs; filename = "$n indeg $l.csv " )
end 





threeDAGs= []
i = 0 
while i < 10
    G = parental_ER_DAG(10,0.2)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 3
        push!(threeDAGs, [G,C,l])
        i+= 1
    end 
end 

save_results_to_csv(key_values, threeDAGs;filename = "10_3_test.csv")

#= test = [] 
for DAG in threeDAGs
    G,C,l = DAG
    G_out = PCstarvar2(G,C,l;orient_cycles = true)[1]
    true_CPDAG = cp_dag(get_edges(wtr(G,C)[1]),[])
    push!(test, issubset(directed_edges(G_out), directed_edges(true_CPDAG)))

end 
 =#
fourDAGs= []
i = 0 
while i < 100
    G = parental_ER_DAG(10, 0.3)
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
    G = parental_ER_DAG(10, 0.33)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 5
        push!(fiveDAGs, [G,C,l])
        i+= 1
    end 
end 

save_results_to_csv(key_values, fiveDAGs)

for (i, elem) in enumerate(fourDAGs)
    G, C, l = elem 
    try
        G_no_cycles, stmts, sep_sets, G, C, degbound  = PCstar(G,C,l,1)
        #G_out1 = orient_all_cycles(G_no_cycles, G,C,sep_sets, l, 1)
        G_out2 = orient_all_cycles(G_no_cycles, G,C,sep_sets, l, 2)
    catch
        @warn "Error on element $i" 
        break 
    end
end 

three15DAGs = [] 
i = 0 
while i < 10

    G = parental_ER_DAG(15, 0.1)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 3 
        push!(three15DAGs, [G,C,l])
        i+= 1 
    end 
end 

save_results_to_csv(key_values, three15DAGs)

four15DAGs = [] 
i = 0 
while i < 10

    G = parental_ER_DAG(15, 0.15)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 4
        push!(four15DAGs, [G,C,l])
        i+= 1 
    end 
end 

save_results_to_csv(key_values, four15DAGs)

five15DAGs = [] 
i = 0 
while i < 10

    G = parental_ER_DAG(15, 0.2)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 5
        push!(five15DAGs, [G,C,l])
        i+= 1 
    end 
end 


save_results_to_csv(key_values, five15DAGs)


four20DAGs = []
i = 0 
while i < 10

    G = parental_ER_DAG(20, 0.15)
    C = randomly_sampled_matrix(G)
    l = max_in_degree(G)
    if l == 4
        push!(four20DAGs, [G,C,l])
        i+= 1 
    end 

end 

save_results_to_csv(key_values, four20DAGs)



G = parental_ER_DAG(20, 0.2)
C = randomly_sampled_matrix(G)
l = max_in_degree(G)