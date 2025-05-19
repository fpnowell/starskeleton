#include("StarPC.jl")

#example 1: unique collider 4->5<-6, source at 1
G1 = DAG_from_edges([(1,2),(2,4),(1,3),(3,6),(6,5),(4,5)])
G1_cp = cp_dag([], get_edges(G1)) #start with skeleton of WTR
C1 = randomly_sampled_matrix(G1)
find_colliders(G1_cp, get_Csepstatements(G1,randomly_sampled_matrix(G1))) #find colliders
find_cycles(G1_cp, (4,5,6))
PCstar(6, 2, get_Csepstatements(G1,C1)) #careful, with constant weights we have genericity problems
PCstarvar2(G1, C1, 2, orient_cycles = true)
PCstar(G1, C1, 2)
#example 2: unique collider, source at 6

G2 = DAG_from_edges([(1,2),(2,3),(6,1),(3,4),(6,5),(4,5)])
C2 = randomly_sampled_matrix(G2)
C2[6,5] = 100000 #make sure that 65 is critical 
G2_cp = cp_dag([], get_edges(G2)) #start with skeleton of WTR

G2stmts = get_Csepstatements(G2,C2)

PCstar(6,2,get_Csepstatements(G2,C2))
PCstar(G2, C2, 2)
#example 3, source at 4

G3 = DAG_from_edges([(2,1),(3,2),(1,6),(4,3),(6,5),(4,5)])
C3 = randomly_sampled_matrix(G3)
C3[4,5] = 100000 #make sure that 45 is critical 
G3_cp = cp_dag([], get_edges(G3)) #start with skeleton of WTR

G3stmts = get_Csepstatements(G3,C3)

PCstar(6,2, G3stmts)

#CPDAGs are indistinguishable 

#example 4: two colliders 

G4 = DAG_from_edges([[1,2,[2,3],[3,4],[4,6],[1,5],[5,6]])
C4 = randomly_sampled_matrix(G4)

G4_cp = cp_dag([],get_edges(G4))

G4stmts = get_Csepstatements(G4,C4)

PCstar(6,2, G4stmts)
PCstarvar2(G4,C4, 2; orient_cycles = true)


G5 = DAG_from_edges([(6,5),(1,6),(1,2),(3,2),(4,3),(4,5)])

get_Csepstatements(G4) == get_Csepstatements(G5)