#Generic graph functions functions

using Graphs, TikzGraphs, TikzPictures, Serialization, Combinatorics
import Oscar: tropical_semiring, zero, matrix, ncols 

##skeleton retrieval functions 
function get_skeleton(H::SimpleDiGraph)
    n = Graphs.nv(H)
    G = SimpleGraph(n,0)
    for edge in Graphs.edges(H)
        Graphs.add_edge!(G, edge)
    end
    return G 
end 

same_skeleton(H::SimpleDiGraph, G::SimpleGraph) = (get_skeleton(H) == G)

function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
    G = complete_graph(nv(H))
    sort!(S, by = x -> length(x[3]))
    for statement in S
        i, j, K = statement 
        if has_edge(G, i, j) && (all( k-> has_edge(G, i, k), K) || all( k-> has_edge(G, k,j), K)) #line 5 of pseudocode
            rem_edge!(G, i, j)
        end
    end
    return G
end

#TODO: this is closer to the pseudocode, but it's better to work with just tuples. 

function skeleton_edges_from_statements(n, degbound, stmts)
    G = complete_graph(n)
    filter!(stmt -> length(stmt[3]) < degbound +1 , stmts)
    for stmt in stmts
        i,j,K = stmt
        if has_edge(G, i, j) && (all( k-> has_edge(G, i, k), K) || all( k-> has_edge(G, k,j), K)) #line 5 of pseudocode
            rem_edge!(G, i, j)
        end
    end
    return get_edges(G)

end 


#general edge to graph, graph to pdf functionality 

function DAG_to_pdf(H::SimpleDiGraph, name::String)
    t = TikzGraphs.plot(H)
    TikzGraphs.save(PDF(name* ".pdf"), t)
end 

function graph_to_pdf(H::SimpleGraph, name::String)
    t = TikzGraphs.plot(H)
    TikzGraphs.save(PDF(name* ".pdf"), t)
end 

function _graph_from_edges(A::Vector)
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleGraph(n,0)
    for (i,j) in A 
        Graphs.add_edge!(D, i, j)
    end 
    return D 
end  

function DAG_from_edges(A::Vector)
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleDiGraph(n,0)
    for (i,j) in A 
        Graphs.add_edge!(D, i, j)
    end 
    return D 
end  

function DAG_from_edges(n, E)
    G = SimpleDiGraph(n,0)
    for edge in E
        Graphs.add_edge!(G, edge[1],edge[2])
    end
    G
end 

function get_edges(G::SimpleDiGraph)
    n = nv(G)
    return [(i,j) for i in 1:n ,j in 1:n if has_edge(G,i,j)]
end 

function get_edges(G::SimpleGraph)
    n = nv(G)
    return [(i,j) for i in 1:n, j in 1:n if (has_edge(G,i,j) && i < j)]
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


##Functions for generating random DAGs


function generate_random_dag(n::Int, p::Float64)
    G = SimpleDiGraph(n)
    for i in 1:n
        for j in (i+1):n
            # Add directed edge from i to j with probability p
            if rand() < p
                add_edge!(G, i, j)
            end
        end
    end
    return G
end


function find_graph_with_property(k::Int, n::Int, p::Float64, has_property)
    i = 0
    while i < k
        testgraph = generate_random_dag(n, p)
        if !has_property(testgraph)
            i = i+1
        else
            DAG_to_pdf(testgraph, "example")
            serialize("example.jls", testgraph)
            print("example found!")
            break 
        end
    end 
    if i == k 
        print("no example found!")
    end 
end 


function all_DAGs(n::Int64)
    D = []
    L = [(i,j) for i in 1:n, j in 1:n if i<j]
    perms = permutations(1:n)
    for E in collect(powerset(L))
        if !isempty(E) 
            for perm in perms 
                F = [(perm[i],perm[j]) for (i,j) in E] 

                push!(D, sort(F))
            end 

        end 

    end     
    return DAG_from_edges.(collect(Set(D)))

end



###Modified Erdosz-Reinyi (from Ben's M2 code)

function parental_ER_DAG(n, p)
    E = []
    for j in 2:n
        P = Bernoulli(p*sqrt((n-1)/(j-1))) #this is not always well-defined. Problem?
        for i in 1:j-1
            if rand(P)
                push!(E, (i,j))
            end 
        end 
    end 
    G = DAG_from_edges(n,E)
    degs = [indegree(G,i) for i in 1:n] #Do I need this? 
    exps = exp_indegree(n,p)
    stdvs = stdv_indegree(n,p)
    deg_bounds = vcat([(0,0)],[(maximum([0,i-2*j]), i + 2*j) for (i,j) in zip(exps, stdvs)])
    #check for degree bounds, and connectedness 
    while !(within_deg_bounds(deg_bounds, G) && is_connected(G))
        E = []
        for j in 2:n
            P = Bernoulli(p*sqrt((n-1)/(j-1)))
            for i in 1:j-1
                if rand(P)
                    push!(E, (i,j))
                end 
            end 
        end 
    G = DAG_from_edges(E)
    end  
    return G 
end 

function exp_indegree(n,p)
    return [p*sqrt(j-1)*sqrt(n-1) for j in 2:n]

end 

function stdv_indegree(n,p)
    return [sqrt((j-1)*p*sqrt((n-1)/(j-1))*(1-p*sqrt((n-1)/(j-1)))) for j in 2:n]
end 

function within_deg_bounds(deg_bounds, G)
    return all(indegree(G, j) >= deg_bounds[i][1] && indegree(G, j) <= deg_bounds[i][2] for (i,j) in zip(1:nv(G),1:nv(G)))
end 


##Weighted DAG functionality 


# make the kleene star of C
function kleene_star(C)

    sum(map(d -> C^d, 0:ncols(C)-1))
end



# compute the weight of a path
function path_weight(C, p)

    prod(map(i -> C[p[i], p[i+1]] , 1:length(p)-1))
end




function wtr(G::SimpleDiGraph, C)
    #iterate through edges of G and check whether the edge is the critical path
    #if this is not the case, remove 
    G_tr = SimpleDiGraph(nv(G), 0)
    Cstar = kleene_star(C)
    for (i,j) in get_edges(G)
        if C[i,j] == Cstar[i,j]
            add_edge!(G_tr, i, j)
        else 
            Cstar[i,j] = zero(tropical_semiring(max))
        end 
    end 

    return G_tr, Cstar
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


function randomly_sampled_matrix(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = rand(1:10000)
        end 
    end 
    return C

end 

##Critical graph functionality 


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


##CPDAG functions 

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

##Collider stuff 

# outputs all triples (i, k, j) such that the induced subgraph G[i,j,k] = i - k - j
function get_unshielded_triples(G::SimpleGraph)

    triples = []

    for k in collect(Graphs.vertices(G))
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

    E = setdiff(undirected_edges(G), vcat(D, [reverse(e) for e in D]))

    return cp_dag(unique(D), E)
end

##Cycle orientation functions 


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
            if length(filter(stmt -> i in stmt && k in stmt && length(intersect(V,stmt[3])) == 1 && length(stmt[3]) == minimum([length(t[3]) for t in stmts]), stmts)) == 2 
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

    return cp_dag(unique(D), setdiff(E, union(D, reverse.(D))))
end




function find_cycles(G, coll)
    #TODO: this can be optimized
    (k1, k, k2) = coll 
    skel = skeleton(induced_subgraph(G, setdiff(vertices(G), [k])))
    paths = collect(all_simple_paths(skel, k1, k2))
    for path in paths 
        push!(path,k)
        end 
    return paths 
end


function find_induced_cycles(G, coll)
    #Currently, this filters the cycles, returning only those which are not included in a larger induced subcycle. 
    #Is this correct? 
    all_cycles = find_cycles(G,coll)
    sorted_cycles = sort(all_cycles, by=length)
    
    minimal_cycles = Vector{}()
    for s in sorted_cycles
        if !any(issubset(t,s) for t in minimal_cycles)
            push!(minimal_cycles, s)
        end 
    end 
    return minimal_cycles
end


function orient_all_cycles(G, stmts)
    for coll in colliders(G)
        cycles = find_induced_cycles(G,coll)
        for cycle in cycles 
            G = orient_induced_cycle(G, cycle, stmts)
        end 
    end
    return G 
end 