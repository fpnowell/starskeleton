import Oscar: tropical_semiring, zero, matrix, ncols 
using Graphs


# make the kleene star of C
function kleene_star(C)

    sum(map(d -> C^d, 0:ncols(C)-1))
end


# compute the weight of a path
function path_weight(C, p)

    prod(map(i -> C[p[i], p[i+1]] , 1:length(p)-1))
end


# make the critical DAG given a dag G, a conditioning set K, and weights C
function critical_graph(G::SimpleDiGraph, K::Vector, C)

    V = Graphs.vertices(G)

    # make the kleene star to test for max weighted paths
    Cstar = kleene_star(C);

    # make an empty graph which will be our critical graph that we add edges to
    Gstar = SimpleDiGraph(length(V), 0)

    # loop over every possible edge
    for e in Iterators.product(V, V)

        (i, j) = e

        if i == j
            continue
        end

        # collect critical paths
        crit_paths = [p for p in all_simple_paths(G, i, j) if path_weight(C, p) == Cstar[i, j]]
        
        if length(crit_paths) == 0
            continue
        end

        # check if any critical path factors through K
        # if so we do not add the edge [i, j] otherwise we add it
        if any(map(p -> any(map(k -> k in p[2:length(p)-1], K)), crit_paths))
            continue
        else
            Graphs.add_edge!(Gstar, (i, j))
        end
    end

    return Gstar
end



function constant_weights(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = 1 
        end 
    end 
    return C
end 


