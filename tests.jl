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

trueDAG3 = generate_random_dag(10,0.7)

C3 = randomly_sampled_matrix(trueDAG3)

stmts3 = get_Csepstatements(trueDAG3, C3)

G3 = PCstar(10,7,stmts3)

Set(get_edges(wtr(trueDAG3, C3)[1])) == Set(vcat(undirected_edges(G3) ,directed_edges(G3))), ne(trueDAG3), ne(wtr(trueDAG3, C3)[1]), length(directed_edges(G3))

