include("StarPC.jl")
include("examples/examplegraphs.jl")

trueDAG = DAG_from_edges([(2,1),(1,3),(2,4),(3,4),(5,1),(5,6),(6,3),(6,7)])
C = randomly_sampled_matrix(trueDAG)

stmts = get_Csepstatements(trueDAG, C)

PCstar(7, 3, stmts)

trueDAG2 = diamond_21

C2 = randomly_sampled_matrix(trueDAG2)

stmts2 = get_Csepstatements(trueDAG2,C2)

PCstar(4, 2, stmts2)

trueDAG3 = generate_random_dag(13,0.7)

C3 = randomly_sampled_matrix(trueDAG3)

s#tmts3 = get_Csepstatements(trueDAG3, C3)

stmts3 = get_Csep_stmts_var(trueDAG3, C3)

G3 = PCstar(13,9,stmts3)

Set(get_edges(wtr(trueDAG3, C3)[1])) == Set(vcat(undirected_edges(G3) ,directed_edges(G3))), ne(trueDAG3), ne(wtr(trueDAG3, C3)[1]), length(directed_edges(G3))

serialize("global_markov_example_13.jls", stmts3 )

DAG_to_pdf(trueDAG3, "example_13")

serialize("truedag_example_13.jls", stmts3)

serialize("C_matrix_example_13.jls", C3)

#maximum indegree 9 


G = parental_ER_DAG(9, 0.15)
C = randomly_sampled_matrix(G)

l = max_in_degree(G)

stmts = get_Csep_stmts_bounded(G,C,2)

G_out = PCstar(20, 4, stmts)

Set(get_edges(wtr(G, C)[1])) == Set(vcat(undirected_edges(G_out) ,directed_edges(G_out))), ne(G), ne(wtr(G, C)[1]), length(directed_edges(G_out))

#= stmts = get_Csep_stmts_var(G, C)
k = max_in_degree(G)

stmts2 = get_Csep_stmts_bounded(G, C ,7)
G_pc_1 = PCstar(15,7,stmts)
G_pc_2 = PCstar(15,7,stmts2)



Set(get_edges(wtr(G, C)[1])) == Set(vcat(undirected_edges(G_pc_2) ,directed_edges(G_pc_2))), ne(G), ne(wtr(G, C)[1]), length(directed_edges(G_pc_2))
 =#