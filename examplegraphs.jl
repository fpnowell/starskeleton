include("main.jl")

function _graph_from_edges(A::Vector{Tuple{Int64, Int64}})
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleDiGraph(n,0)
    for (i,j) in A 
        Graphs.add_edge!(D, i, j)
    end 
    return D 
end  


collider = _graph_from_edges([(1,3),(2,3)])

#dsep(collider, 1, 2, [])

#dsep(collider, 1,2,[3])

v_shape = _graph_from_edges([(1,3),(3,2)])

diamond = _graph_from_edges([(1,2),(1,3),(2,4),(3,4)])

cassio = _graph_from_edges([(1,4),(2,4), (2,5) ,(3,5)])

longcassio_edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]

longcassio = _graph_from_edges(longcassio_edges)


diamondcassio_edges = [(1,4),(2,4), (2,5) ,(3,5), (1,6),(2,6)]

diamondcassio = _graph_from_edges(diamondcassio_edges)

doublecollider = _graph_from_edges([(2,1),(3,1),(2,4),(3,4)])

pyramid = SimpleDiGraph(6,0)

pyramid_edges = _graph_from_edges([(4,6),(5,6), (1,4),(2,4), (2,5) ,(3,5) ])

double_pyramid = _graph_from_edges([(1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,9),(5,9), (6,10),(7,10),(8,11),(9,11)])


cassiovariant = _graph_from_edges([(1,4),(2,4), (2,5) ,(3,5),(4,6), (3,6), (1,7),(7,3)])

#IMPORTANT: CASSIOVARIANT is a counterexample to the one claim about 
#"removing a collider preserves star-separation" 
# 1 and 3 are star separated given {4,5,6} and 1-4-2-5-3 is a d-connecting path
#removing the collider 4, we get suddenly get a *-connecting path through 6
#Because of this, I think we need to remove ALL OF THE DESCENDANTS/ANCESTORS of a collider.
#Only by doing this do we make sure that we not activate a *-connecting path. 

bigv = _graph_from_edges([(1,4),(2,4), (2,5) ,(3,5),(6,4),(6,5)])

y_graph = _graph_from_edges([(1,4),(2,4),(3,4)])

M = _graph_from_edges([(1,2),(2,3),(4,3),(4,5)])
