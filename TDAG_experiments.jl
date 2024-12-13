include("main.jl")

#CLAIM 1: A Graph and its transitive closure are critically equivalent.

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

function critically_equivalent_to_closure(G::SimpleDiGraph, k::Int64)
    H = transitiveclosure(G)
    i = 0
    while i < k
        C_G = randomly_sampled_matrix(G)
        C_H = randomly_sampled_matrix(H)
        if !(get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H))
            i = i+1
        else
            return true 
            break 
        end
    end 
    if i == k 
        return false 
    end 
end 

critically_equivalent_to_closure(G::SimpleDiGraph) = critically_equivalent_to_closure(G, 1000)
not_equivalent_to_closure(G::SimpleDiGraph) = !critically_equivalent_to_closure(G)
#find_graph_with_property(100, 6, 0.7, not_equivalent_to_closure)

#the tests above support CLAIM 1 

#CLAIM 2: No two distinct TDAGs are critically equivalent


function test_for_critical_equivalence(G::SimpleDiGraph, H::SimpleDiGraph, k::Int64)
    i = 0
    C_G = randomly_sampled_matrix(G)
    while i < k
        C_H = randomly_sampled_matrix(H)
        if !(get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H))
            i = i+1
        else
            serialize("matrices.jls", [C_G, C_H])
            print("EXAMPLE FOUND!!!")
            break 
        end
    end 
    if i == k 
        print("...")
    end 

end 

function test_for_critical_equivalence(k::Int64)
    i = 0
    while i < k
        G = generate_random_dag(4,0.5)
        H = generate_random_dag(4,0.5)
        C_G = randomly_sampled_matrix(G)
        C_H = randomly_sampled_matrix(H)
        if !(get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H))
            i = i+1
        else
            serialize("matrices.jl", [C_G, C_H])
            print("!!!EXAMPLE FOUND!!!!")
            break 
        end
    end 
    if i == k 
        print("...")
    end 

end 

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
    

function all_top_ordered_TDAGs(n::Int64)
    D = all_top_ordered_DAGs(n)
    T = []
    for G in D
        if G == transitiveclosure(G) && is_connected(get_skeleton(G)) && nv(G) == n 
            push!(T, G)
        end 
    end 
    return T
end 