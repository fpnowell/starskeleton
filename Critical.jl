#include("main.jl")
using Oscar
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


##########################################
# Examples
##########################################
diamond = SimpleDiGraph(4,0)
diamond_edges = [(1,2),(1,3),(2,4),(3,4), (1, 4)]
for edge in diamond_edges;
    Graphs.add_edge!(diamond,edge)
end 
G = diamond

T = tropical_semiring(max)
z = zero(T)
C = matrix(T, [[z, 1, 2, 1], [z, z, z, 3], [z, z, z, 5], [z, z, z, z]])
critical_graph(G, [3], C)



##########################################
# Examples
##########################################

T = tropical_semiring(max)
z = zero(T)
G1 = _graph_from_edges([(1,2),(1,3),(3,4),(2,3)])
C1=  matrix(T, [[z, 1, 1, z], [z, z, z, 2], [z, z, z, 1], [z, z, z, z]])
G1star = critical_graph(G1, [], C1)
G1star_given2 = critical_graph(G1, [2], C1)
G1star_given1 = critical_graph(G1, [1],C1)
E = collect(Graphs.edges(G1star))

G2 = _graph_from_edges([(2,1),(1,3),(2,4),(3,4)])
C2 = matrix(T, [[z,z,1,z],[1,z,z,2],[z,z,z,1],[z,z,z,z]])
G2star = critical_graph(G2, [],C2)
G2star_given2 = critical_graph(G2, [2], C2)
G2star_given1 = critical_graph(G2, [1], C2)
C_cassio = matrix(T, [[z,z,z,1,z],[z,z,z,1,1],[z,z,z,z,1],[z,z,z,z,z],[z,z,z,z,z]])

