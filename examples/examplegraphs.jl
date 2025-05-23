
# On 3 nodes
collider = DAG_from_edges([(1,3),(2,3)])


threepath = DAG_from_edges([(1,2),(2,3)])

complete_3DAG = DAG_from_edges([[1,2],[2,3],[1,3]])

# On 4 nodes

diamond = DAG_from_edges([(1,2),(1,3),(2,4),(3,4)])

diamond_var = DAG_from_edges([[1,4],[1,2],[2,3],[3,4]]) #non-unique 1-4 path

diamond_double_collider = DAG_from_edges([[1,3],[2,3],[1,4],[2,4]])

diamond__with_14 = DAG_from_edges([(1,2),(1,3),(2,4),(3,4), (1,4)])

complete_4DAG = DAG_from_edges([[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]])

# On >4 nodes 

cassio = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5)])

longcassio_edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]

longcassio = DAG_from_edges(longcassio_edges)


diamondcassio_edges = [(1,4),(2,4), (2,5) ,(3,5), (1,6),(2,6)]

diamondcassio = DAG_from_edges(diamondcassio_edges)

pyramid =DAG_from_edges([(4,6),(5,6), (1,4),(2,4), (2,5) ,(3,5) ])

double_pyramid = DAG_from_edges([(1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,9),(5,9), (6,10),(7,10),(8,11),(9,11)])


cassiovariant = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5),(4,6), (3,6), (1,7),(7,3)])

#IMPORTANT: CASSIOVARIANT is a counterexample to the one claim about 
#"removing a collider preserves star-separation" 
# 1 and 3 are star separated given {4,5,6} and 1-4-2-5-3 is a d-connecting path
#removing the collider 4, we get suddenly get a *-connecting path through 6
#Because of this, I think we need to remove ALL OF THE DESCENDANTS/ANCESTORS of a collider.
#Only by doing this do we make sure that we not activate a *-connecting path. 

bigv = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5),(6,4),(6,5)])


M = DAG_from_edges([(1,2),(2,3),(4,3),(4,5)])
