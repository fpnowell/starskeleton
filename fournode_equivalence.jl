include("main.jl")

function same_Cstar_statements(G::SimpleDiGraph, H::SimpleDiGraph)
    C_G = randomly_sampled_matrix(G)
    #the matrices should be supported on the DAG 
    C_H = randomly_sampled_matrix(H) 
    return get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H)
end 

function critically_equivalent_to_closure(G::SimpleDiGraph, k::Int64)
    H = transitiveclosure(G)
    i = 0
    while i < k
        C_G = randomly_sampled_matrix(G)
        #the matrices should be supported on the DAG 
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

function randomly_sampled_matrix(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = rand(1:100)
        end 
    end 
    return C

end 

function test_for_critical_equivalence(G::SimpleDiGraph, H::SimpleDiGraph, k::Int64)
    i = 0
    while i < k
        C_G = randomly_sampled_matrix(G)
        C_H = randomly_sampled_matrix(H)
        if !(get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H))
            i = i+1
        else
            serialize("matrices.jls", [C_G, C_H])
            print("example found!")
            break 
        end
    end 
    if i == k 
        print("no example found!")
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
            serialize("matrices.jls", [C_G, C_H])
            print("example found!")
            break 
        end
    end 
    if i == k 
        print("no example found!")
    end 

end 

function all_DAGS(n::Int64)
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

    

function all_transitively_closed_DAGS(n::Int64)
    D = all_DAGS(n)
    T = []
    for G in D
        if G == transitiveclosure(G)
            push!(T, G)
        end 
    end 
    return T
end 

L1 = all_transitively_closed_DAGS(4)

L2 = [] 

for G in L1 
    if ne(G) > 3
        push!(L2,G)
    end 
end 

for G1 in L2, G2 in L2 
    if !(G1 == G2)
        test_for_critical_equivalence(G1, G2, 1000)
    end 
end 

#It would appear that no two distinct transitively closed DAGs on 4 nodes are critically equivalent. What can we conclude from this?
# Are the transitively closed DAGs precisely the maximal representants of critical equivalence classes? 