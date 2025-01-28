include("main.jl")
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
function induced_subgraph(G::CPDAG, V::Vector)

    D = [e for e in directed_edges(G) if issubset(e, V)]
    E = [e for e in undirected_edges(G) if issubset(e, V)]

    cp_dag(D, E)
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


function orient_induced_cycle(G::CPDAG, V::Vector, stmts::Vector)

    indV = induced_subgraph(G, V)
    skel = skeleton(indV)
    coll = colliders(indV)

    if length(coll) > 1
        return G
    end

    (k1, k, k2) = coll[1]

    sep_dict = Dict()

    for i in V

        if i in coll[1]

            sep_dict[i] = 1
            continue
        end

        for stmt in filter(stmt -> i in stmt && k in stmt, stmts)

            if length(intersect(V, stmt[3])) == 1
                sep_dict[i] = 1
                break
            end
        end
    end

    for i in V
        
        if !haskey(sep_dict, i)
            sep_dict[i] = 0
        end
    end

    source = k1

    for i in setdiff(V, coll[1])

        (j, l) = neighbors(skel, i)

        if length(V) == 4 && sep_dict[i] == 1
            source = i
        



        elseif sep_dict[i] == 1 && sep_dict[j] != sep_dict[l]
            source = i
            break

        elseif length(V) == 5 && sep_dict[i] == 1 
            if length(filter(stmt -> i in stmt && k in stmt && length(intersect(V,stmt[3])) == 1, stmts)) == 2 
                source = i 
                break
            end
  
        end
    end

    if source == k1
        
        return G
    end 


    D = [e for e in directed_edges(G)]
    E = [e for e in undirected_edges(G)]
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

    return cp_dag(D, setdiff(E, union(D, reverse.(D))))
end




function find_cycles(G, coll)
    #TODO: implement a way of checking if the subgraph is an induced cycle
    (k1, k, k2) = coll 
    skel = skeleton(induced_subgraph(G, setdiff(vertices(G), [k])))
    paths = collect(all_simple_paths(skel, k1, k2))
    for path in paths 
        push!(path,k)
        end 
    return paths 
end

function PCstar(stmts, n)
    skel = skel_from_statements(complete_graph(n), stmts) 
    G = cp_dag([],get_edges(skel)) 
    find_colliders(G, stmts)
    M = 

end 

function orient_all_cycles(G)
    colls = colliders(G)
    M = [find_cycles(G,coll) for coll in colls ]
end 

D = [(3,5), (4,5)]
E = [(2,1), (1,3),(4,2)]
H = DAG_from_edges(vcat(D, E))
G = cp_dag(D, E)
C = randomly_sampled_matrix(H)
Cstar = kleene_star(C)
stmts = get_Csepstatements(H, C)
coll = colliders(G)
V = 1:5
orient_induced_cycle(G, collect(V), stmts)
M = find_cycles(G, coll[1])

for V in M 
    if skeleton(induced_subgraph(G, V)) == _graph_from_edges(push!([(V[i],V[i+1]) for i in 1:(length(V)-1)], (V[1],V[length(V)]))) 
        G = orient_induced_cycle(G, V, stmts)
    end 
end 



println(G)