include("main.jl")

cassio = SimpleDiGraph(5,0)

cassioedges = [(1,4),(2,4), (2,5) ,(3,5)]

for edge in cassioedges;
    add_edge!(cassio, edge)
end

cassio_statements = get_dsepstatements(cassio)

cassio_dsepskeleton = dsep_skeleton(cassio)

#long_cassio = SimpleDiGraph()

#= dseporacle(1,3,[4,5],cassio)
dseporacle(1,3,[4],cassio) =#