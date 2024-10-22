longcassio = SimpleDiGraph(9,0)

Edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]

for (i, j) in Edges 
    add_edge!(longcassio, i, j)
end