
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

Edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]

for (i, j) in Edges 
    add_edge!(longcassio, i, j)
end