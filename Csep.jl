include("Critical.jl")

function is_type_b(G::SimpleDiGraph, P::Vector, K::Vector)
    return  issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && !(P[2] in K) 
end 

function is_type_c(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && P[2] in K 

end 

function is_type_d(G::SimpleDiGraph, P::Vector, K::Vector)
    bool = false 
    if issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.inneighbors(G, P[3])) && P[3] in K && !(P[2] in K)
        bool = true
    elseif issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.outneighbors(G, P[3])) && P[2] in K && !(P[3] in K)
        bool = true 
    end 
    return bool 
end 

function is_type_e(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1],P[3]], Graphs.outneighbors(G, P[2])) && issubset([P[3],P[5]], Graphs.outneighbors(G, P[4])) && P[3] in K && !(P[2] in K) && !(P[4] in K)
end 

#Question: Is something gained from nesting the conditions here, complexity-wise? 
function Csep(G::SimpleDiGraph, C, K::Vector, i::Int64, j::Int64)
    if issubset([i,j], K)
        return false 
    end 
    G_star = critical_graph(G, K, C)
    undirected_G_star = get_skeleton(G_star)
    paths = collect(all_simple_paths(undirected_G_star, i, j;cutoff = 4)) 
    bool = true 
    for p in paths
        if length(p) == 2 && (Graphs.has_edge(G_star, i,j) || Graphs.has_edge(G_star, j, i))
            bool = false 
            break  
        elseif length(p) == 3 && (is_type_b(G_star, p, K) || is_type_c(G_star, p, K))
            bool = false 
            break 
        elseif length(p) == 4 && is_type_d(G_star, p, K)
            bool = false 
            break  
        elseif length(p) == 5 && is_type_e(G_star, p,K)
            bool = false 
            break 
        else 
            continue 
        end 
    end 
    return bool 
end 

Csep(G::SimpleDiGraph, K, i, j) = Csep(G, constant_weights(G), K, i, j )


function Csepstatements_wrt_nodes(G::SimpleDiGraph, C, i, j)
    L = []
    for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
        if Csep(G,C,K,i,j)
            push!(L, K)
        end
    end 
    return L 
end 

Csepstatements_wrt_nodes(G::SimpleDiGraph, i, j) = Csepstatements_wrt_nodes(G, constant_weights(G), i, j)




function get_Csepstatements(G::SimpleDiGraph, C)
    L = []
    for i in collect(Graphs.vertices(G)), j in 1:i-1
        for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
            if Csep(G,C,K,i,j)
                push!(L,[j,i,K])
            end 
        end 
    end 
    return L 
end 

get_Csepstatements(G::SimpleDiGraph) = get_Csepstatements(G, constant_weights(G))
    

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
function csep_markov_dict(graphs::Vector{SimpleDiGraph}, trials::Int64)

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


# outputs all triples (i, k, j) such that the induced subgraph G[i,j,k] = i - k - j
function get_unshielded_triples(G::SimpleGraph)

    triples = []

    for k in vertices(G)
        for S in powerset(neighbors(G, k), 2)
            (i, j) = Tuple(S)

            if has_edge(G, i, j)
                continue
            end

            push!(triples, (i, k, j))
        end
    end

    return triples
end


# stmts, a list of of statements of the form [i, j, K]
# outputs all triples (i, k, j) such that i -> k <- j is a v-structure based on the statements in stmts
function find_colliders(G::SimpleGraph, stmts::Vector)

    colliders = []

    for triple in get_unshielded_triples(G)

        (i, k, j) = triple

        k_in_sep_set = false

        for C in stmts

            if Set([i, j]) != Set([C[1], C[2]])
                continue
            end

            if k in C[3]
                k_in_sep_set = true
                break
            end
        end

        if !k_in_sep_set
            push!(colliders, (i, k, j))
        end
    end

    return colliders
end


# G, a simple directed acyclic graph
# outputs all triples (i, k, j) such that the induced subgraph G[i,j,k] = i -> k <- j
function find_colliders(G::SimpleDiGraph)

    colliders = []

    for triple in get_unshielded_triples(get_skeleton(G))

        (i, k, j) = triple

        if has_edge(G, i, k) && has_edge(G, j, k)

            push!(colliders, (i, k, j))
        end
    end

    return colliders
end