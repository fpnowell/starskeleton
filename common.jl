#Generic functions

using Graphs, TikzGraphs, TikzPictures, Serialization 

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


function get_edges(G::SimpleDiGraph)
    n = nv(G)
    return [(i,j) for i in 1:n ,j in 1:n if has_edge(G,i,j)]
end 

function get_edges(G::SimpleGraph)
    n = nv(G)
    return [(i,j) for i in 1:n, j in 1:n if (has_edge(G,i,j) && i < j)]
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