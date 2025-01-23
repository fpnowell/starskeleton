struct CPDAG

    vertices::Vector
    sources::Vector
    skeleton::SimpleGraph
    directed_edges::Vector
    undirected_edges::Vector
    colliders::Vector
end


function Base.show(io::IO, G::CPDAG)
    E = undirected_edges(G)
    D = directed_edges(G)
    print(io, "Partially oriented graph with directed edges $(D) and undirected edges $(E)")
  end
  

function vertices(G::CPDAG)

    return G.vertices
end

function skeleton(G::CPDAG)

    return G.skeleton
end


function undirected_edges(G::CPDAG)

    return G.undirected_edges
end


function directed_edges(G::CPDAG)

    return G.directed_edges
end


function colliders(G::CPDAG)

    return G.colliders
end


# 
function induced_subgraph(G::CPDAG)

    # TODO
end


# D is the directed edges as a vector of tuples
# E is the undirected edges as a vector of tuples
function cp_dag(D::Vector, E::Vector)

    skel = _graph_from_edges(vcat(D, E))
    V = collect(Graphs.vertices(skel))
    coll = []

    for triple in get_unshielded_triples(skel)
        
        (i, k, j) = triple

        if (i, k) in D && (j, k) in D
            
            push!(coll, (i, k, j))
        end
    end

    return CPDAG(V, [], skel, D, E, coll)
end


# outputs all triples (i, k, j) such that the induced subgraph G[i,j,k] = i - k - j
function get_unshielded_triples(G::SimpleGraph)

    triples = []

    for k in Graphs.vertices(G)
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


function get_unshielded_triples(G::CPDAG)

    return get_unshielded_triples(skeleton(G))
end


# stmts, a list of of statements of the form [i, j, K]
# outputs all triples (i, k, j) such that i -> k <- j is a v-structure based on the statements in stmts
function find_colliders(G::CPDAG, stmts::Vector)

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

    D = [e for e in directed_edges(G)]

    for coll in colliders

        (i, k, j) = coll
        push!(D, (i, k))
        push!(D, (j, k))
    end

    E = setdiff(undirected_edges(G1), vcat(D, [reverse(e) for e in D]))

    return cp_dag(D, E)
end


function orient_induced_cycle(G::CPDAG, C::Vector, stmts::Vector)

    indC = induced_subgraph(G, C)
    coll = colliders(indC)

    if length(coll) > 1
        return G
    end

    (k1, k, k2) = coll[1]

    sep_dict = Dict()

    for i in C

        if i in coll[1]

            sep_dict[i] = 1
            continue
        end

        for stmt in filter(stmt -> i in stmt && k in stmt, stmts)

            if length(intersect(C, stmt[3])) == 1
                sep_dict[i] = 1
                break
            end
        end
    end

    for i in C
        
        if !haskey(sep_dict, i)
            sep_dict[i] = 0
        end
    end

    cur_node = setdiff(neighbors(skel, k1), [k1])[1]
    prev_node = k1
    source = k1

    while cur_node != k2

        next_node = setdiff(neighbors(skel, cur_node), [prev_node])[1]
        

        if sep_dict[next_node] == 1 && sep_dict[cur_node] == 0
            
            source = next_node
            break
        end

        if sep_dict[next_node] == 0 && sep_dict[cur_node] == 1

            source = cur_node
            break
        end

        prev_node = cur_node
        cur_node = next_node
    end

    if source == k1
        
        return G
    end


    D = [e for e in directed_edges(H)]
    E = [e for e in undirected_edges(H)]
    prev_node = source
    cur_node = neighbors(skel, prev_node)[1]

    while !(cur_node == k)

        push!(D, (prev_node, cur_node))
        new_node = setdiff(neighbors(skel, cur_node), [prev_node])[1]
        prev_node = cur_node
        cur_node = new_node
        
    end


    prev_node = source
    cur_node = neighbors(skel, prev_node)[2]

    while !(cur_node == k)

        push!(D, (prev_node, cur_node))
        new_node = setdiff(neighbors(skel, cur_node), [prev_node])[1]
        prev_node = cur_node
        cur_node = new_node
        
    end

    return cp_dag(D, setdiff(E, D))
end


function orient_cycle_with_source(G, C, source)

    
    
    (k1, k, k2) = colliders(induced_subgraph(G, C))[1]

    
end


G = DAG_from_edges([(1, 2), (1, 3), (2, 4), (3, 5), (4, 6), (5, 6)])
H = cp_dag([(4, 6), (5, 6)], [(1, 2), (1, 3), (2, 4), (3, 5)])
stmts = get_Csepstatements(G, randomly_sampled_matrix(G))
coll = colliders(H)
C = [1,2,3,4,5,6]