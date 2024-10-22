include("main.jl")

collider = SimpleDiGraph(3, 0)

add_edge!(collider, (1,3))

add_edge!(collider,(2,3))

#dsep(collider, 1, 2, [])

#dsep(collider, 1,2,[3])

v_shape = SimpleDiGraph(3,0)

add_edge!(v_shape, (1,3))
add_edge!(v_shape, (3,2))

