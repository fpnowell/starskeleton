struct CPDAG

    vertices::Vector
    sources::Vector
    skeleton::SimpleGraph
    directed_edges::Vector
    undirected_edges::Vector
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


# D is the directed edges as a vector of tuples
# E is the undirected edges as a vector of tuples
function cp_dag(D::Vector, E::Vector)

    skel = _graph_from_edges(vcat(D, E))
    V = Graphs.vertices(skel)
    S = []

    return CPDAG(V, S, skel, D, E)
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