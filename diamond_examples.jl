include("main.jl")

#Example 1: Diamond with 1-4 edge and constant weights 

G1 = DAG_from_edges([(1,2),(1,3),(2,4),(3,4), (1,4)])

C1 = constant_weights(G1)

statements = get_Csepstatements(G1, C1)

G1skel = Csep_skeleton(G1)

#Example 2: "Complete" DAG on 4 nodes 

G2 = DAG_from_edges([(1,2),(1,3),(1,4),(2,3),(2,4),(3,4)])

G2skel = Csep_skeleton(G2) #by default, weights are assumed to be constant

C_star_skeletons_unequal(G2) #checks if skeleton retrieval step outputs different graphs

#Csep condition cuts all edges not on critical directed paths 

#Example 3: diamond with 2-1 edge 

G3 = DAG_from_edges([(1,3),(2,1),(2,4),(3,4)])

G3skel = Csep_skeleton(G3) #(2,4) is cut

#change weights s.t. [2,4] is a critical path

C3 = constant_weights(G3)
C3[2,4] = 5

G3skelvar = Csep_skeleton(G3, C3) #(2,4) no longer cut 

#TODO: Write a function which checks wheteher the output of PC contains all of the critical paths in the original DAG 

