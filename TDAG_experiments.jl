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
    

function all_TDAGs(n::Int64)
    D = all_DAGS(n)
    T = []
    for G in D
        if G == transitiveclosure(G) && is_connected(get_skeleton(G)) && nv(G) == n 
            push!(T, G)
        end 
    end 
    return T
end 
#= 
L1 = all_TDAGs(4)

L2 = [] 
for G in L1 
    if nv(G) == 4
        push!(L2,G)
    end 
end 

for G1 in L2, G2 in L2 
    if !(G1 == G2)
        test_for_critical_equivalence(G1, G2, 100)
    end 
end 

for i in 1:234
    test_for_critical_equivalence(L2[i],L2[235],1000)
end 
 =#
#It would appear that no two distinct TDAGs on 4 nodes are critically equivalent. What can we conclude from this?
# Are the transitively closed DAGs precisely the maximal representants of critical equivalence classes? 


#= function same_Cstar_statements(G::SimpleDiGraph, H::SimpleDiGraph)
    C_G = randomly_sampled_matrix(G)
    C_H = randomly_sampled_matrix(H) 
    return get_Csepstatements(G, C_G) == get_Csepstatements(H, C_H)
end   =#

#the sequence is 1, 1, 3, 18, 181,2792,... which is the number of connected partial orders on n elements contained in the linear order This makes sense! 
#In the OEIS, the example for n = 4 is precisely the edge sets of fournodeTDAGs 

threenodeTDAGs = all_TDAGs(3)
fournodeTDAGs = all_TDAGs(4)
fivenodeTDAGs = all_TDAGs(5)

#sixnodeTDAGs = all_TDAGs(6)

#sevennodeTDAGs = all_TDAGs(7)

#eightnodeTDAGs = all_TDAGs(8)

for G1 in fournodeTDAGs, G2 in fournodeTDAGs
    if !(G1 == G2)
        test_for_critical_equivalence(G1, G2, 100)
    end 
end 

L = [collect(edges(G)) for G in fournodeTDAGs]