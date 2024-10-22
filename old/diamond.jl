include("main.jl")


diamond = SimpleDiGraph(4,0)

diamond_edges = [(1,2),(1,3),(2,4),(3,4)]

for edge in diamond_edges;
    add_edge!(diamond,edge)
end 


#= 
rem_edge!(diamond, 2,4)
get_dsepstatements(diamond)
collect(edges(dsep_skeleton(diamond)))
=#