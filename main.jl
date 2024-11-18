using CausalInference, Graphs, TikzPictures, TikzGraphs
using Combinatorics
using Serialization 

include("dsep.jl")
include("starsep.jl")

#QUESTION: in its current state, this simply removes edges from G
#as they appear in sort!(S ...) 
#Is this enough? Something else to consider? 


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

function dsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_dsepstatements(H))
end    

function starsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_starsepstatements(H))
end 


#constructs the underlying undirected graph of a DAG
function get_skeleton(H::SimpleDiGraph)
    n = nv(H)
    G = SimpleGraph(n,0)
    for edge in edges(H)
        add_edge!(G, edge)
    end
    return G 
end 

same_skeleton(H::SimpleDiGraph, G::SimpleGraph) = (get_skeleton(H) == G)

function statement_difference(G::SimpleDiGraph)
    return setdiff(get_starsepstatements(G), get_dsepstatements(G))
end 

#= Checks if the following claim holds for the starsep statements of H: 

"If i indep j given K, then there exists a K_prime contained in K 
such that i indep j given K_prime and (K_prime subset ne(i)\j or K_prime ne(j)\i "

(If this is the case, then we can expect the learning step algorithm to 
output the same skeleton using both separation conditions.

The algorithm iterates through the size of a candidate conditioning set in ne(i)...)
 =#

function verify_claim(H::SimpleDiGraph)
    L = statement_difference(H)
    bool = true
    while !isempty(L)
        statement = pop!(L)
        i, j, K = statement 
        P = collect(powerset(K))
        if any(K_prime -> in([i,j,K_prime],get_starsepstatements(H)) && 
            (issubset(K_prime, setdiff(union(inneighbors(H,i), neighbors(H,i)), [j])) || issubset(K_prime, setdiff(union(inneighbors(H,j), neighbors(H,j)), [i]))), P)
            continue 
        else 
            bool = false 
            break 
        end 
    end 
    return bool 
end 

function DAG_to_pdf(H::SimpleDiGraph, name::String)
    t = plot(H)
    save(PDF(name* ".pdf"), t)
end 


function starsep_statements_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = get_starsepstatements(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 


function dsep_statements_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = get_dsepstatements(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 


function statement_diff_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = statement_difference(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 
