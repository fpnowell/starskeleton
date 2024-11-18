include("main.jl")
function graph_from_edges(A::Vector{Tuple{Int64, Int64}})
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleDiGraph(n,0)
    for (i,j) in A 
        add_edge!(D, i, j)
    end 
    return D 
end  


collider = SimpleDiGraph(3, 0)

add_edge!(collider, (1,3))

add_edge!(collider,(2,3))

#dsep(collider, 1, 2, [])

#dsep(collider, 1,2,[3])

v_shape = SimpleDiGraph(3,0)

add_edge!(v_shape, (1,3))
add_edge!(v_shape, (3,2))

diamond = SimpleDiGraph(4,0)

diamond_edges = [(1,2),(1,3),(2,4),(3,4)]

for edge in diamond_edges;
    add_edge!(diamond,edge)
end 

cassio = SimpleDiGraph(5,0)

cassioedges = [(1,4),(2,4), (2,5) ,(3,5)]

for edge in cassioedges;
    add_edge!(cassio, edge)
end


longcassio = SimpleDiGraph(9,0)

longcassio_edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]

for (i, j) in longcassio_edges
    add_edge!(longcassio, i, j)
end

diamondcassio = SimpleDiGraph(6,0)

diamondcassio_edges = [(1,4),(2,4), (2,5) ,(3,5), (1,6),(2,6)]

for (i,j) in diamondcassio_edges 
    add_edge!(diamondcassio, i, j)
end 

doublecollider = SimpleDiGraph(4,0)

dc_edges = [(2,1),(3,1),(2,4),(3,4)]

for (i,j) in dc_edges
    add_edge!(doublecollider, i, j)
end

pyramid = SimpleDiGraph(6,0)

pyramid_edges = union(cassioedges, [(4,6),(5,6)])

for (i,j) in pyramid_edges
    add_edge!(pyramid, i,j)
end 

double_pyramid = SimpleDiGraph(11, 0)

double_pyramid_edges = [(1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,9),(5,9), (6,10),(7,10),(8,11),(9,11)]

for (i,j) in double_pyramid_edges
    add_edge!(double_pyramid, i, j)
end 

cassiovariant = graph_from_edges(union(cassioedges, [(4,6), (3,6), (1,7),(7,3)]))

#IMPORTANT: CASSIOVARIANT is a counterexample to the one claim about 
#"removing a collider preserves star-separation" 
# 1 and 3 are star separated given {4,5,6} and 1-4-2-5-3 is a d-connecting path
#removing the collider 4, we get suddenly get a *-connecting path through 6
#Because of this, I think we need to remove ALL OF THE DESCENDANTS/ANCESTORS of a collider.
#Only by doing this do we make sure that we not activate a *-connecting path. 

bigv = graph_from_edges(union(cassioedges, [(6,4),(6,5)]))

y_graph = graph_from_edges([(1,4),(2,4),(3,4)])
