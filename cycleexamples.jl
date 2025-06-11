include("StarPC.jl")

#Demonstrate some points/issues with cycle orientation. 

#Firstly, the statement of the theorem only holds if the induced cycle we are trying to orient 
#contains the unique critical path from i (source)  to k (sink)

G = DAG_from_edges([[1,2],[1,3],[1,4],[2,5],[3,5],[4,5]])
C = randomly_sampled_matrix(G)
l = 2 
C[4,5] = 1000000 #make 1-4-5 critical 1-5 path

G_out, stmts, sep_sets, G, C, degbound = PCstar(G,C,l,1) #two colliders found 
orient_induced_cycle(G_out, [1,2,3,5], G, C, sep_sets, 2, 1) #does not orient
orient_induced_cycle(G_out, [1,2,4,5], G, C, sep_sets, 2, 1) #orients
orient_induced_cycle(G_out, [1,3,4,5], G, C, sep_sets, 2, 1) #orients


#Empirically, using "strategy 1" (i.e. collecting all statements) seems to orient all orientable cycles correctly. Good! 
#PROBLEM: This is once again factorial, so we try to find a smaller/fixed K
#It would be nice to use the minimal separating sets which we have previously collected. (alternatively,)

G = DAG_from_edges([[1,2],[1,3],[2,7],[3,6],[6,7],[4,3],[4,5],[5,6]]) 
C = randomly_sampled_matrix(G)
C[6,7] = 1000000
l = 3 
G_out, stmts, sep_sets, G, C, degbound = PCstar(G,C,l,1)
orient_induced_cycle(G_out, [1,2,3,6,7],G,C,sep_sets,3,1) #orients 
orient_induced_cycle(G_out, [1,2,3,6,7],G,C,sep_sets,3,2) #does not orient 
orient_induced_cycle(G_out, [1,2,3,6,7],G,C,sep_sets,3,3) #orients