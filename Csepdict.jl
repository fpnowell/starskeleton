#markov property dictionary stuff 

include("StarPC.jl")
include("examples/examplegraphs.jl")

function all_top_ordered_DAGS(n::Int64)
    D = []
    L = [(i,j) for i in 1:n, j in 1:n if i<j]
    for E in collect(powerset(L))
        if !isempty(E) 
            G = DAG_from_edges(E)
            push!(D, G)
        end 
    end 
    return D 
end 
    


# randomly samples coefficient matrices C supported on G `trials` many times
# outputs the list of unique C* Markov properties obtained over all samples
function get_cone_reps(G::SimpleDiGraph, trials::Int64)

    cones = []

    for i in 1:trials
        
        C = randomly_sampled_matrix(G)
        ci_stmts = get_Csepstatements(G, C)

        if ! (ci_stmts in cones)
            push!(cones, ci_stmts)

        end
    end

    return cones
end


# graphs, a list of simple digraphs
# make a dictionary whose keys are the DAGs in graphs
# the values are the different CI structures obtained by sampling random matrices C
# the number of samples per graph is given by `trials`
function csep_markov_dict(graphs::Vector, trials::Int64)

    graph_mps = Dict()

    i = 0

    for G in graphs

        graph_mps[G] = get_cone_reps(G, trials)
        i += 1
    end

    if i % 10 == 0
        print(i)
    end
    
    return graph_mps  
end


# graph_mps, is a dictionary of the form created by csep_markov_dict
# the output is the set of all possible CI structures produced by C*-separation
function all_markov_properties(graph_mps)

    return collect(Set(reduce(vcat, values(graph_mps))))
end

# graph_mps, a dictionary of the form produced by csep_markov_dict
# ci_struct, a list of CI statements of the form [i, j, K]
# finds all graphs in the dictionary whose markov property under C*-separation is ci_struct
function find_compatible_graphs(graph_mps, ci_struct, KeepDenseGraphs = false)

    graphs = [G for G in keys(graph_mps) if ci_struct in graph_mps[G]]

    if KeepDenseGraphs 
        return graphs
    end

    min_edges = minimum(map(ne, graphs))

    return [G for G in graphs if ne(G) == min_edges]
end

DAG_4 = filter!(i -> is_connected(i) && nv(i) == 4 , all_top_ordered_DAGS(4)) 

dict = csep_markov_dict(DAG_4, 100)
