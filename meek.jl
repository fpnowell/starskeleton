#functions which apply Meek's orientation rules (https://arxiv.org/pdf/1302.4972), taken from CausalInference.jl
# https://mschauer.github.io/CausalInference.jl/latest/
include("graphfunctions.jl")

#functions which convert 
function cp_dag_to_Graph(G)
    G_out = DAG_from_edges(vcat(directed_edges(G), undirected_edges(G)))
    for e in undirected_edges(G)
        add_edge!(G_out, reverse(e))
    end 
    return G_out
end 

function Graph_to_cp_dag(G)
    D = []
    E = [] 
    for e in get_edges(G)
        i,j = e
        if has_edge(G, j,i)
            if !((min(i,j),max(i,j)) in E) 
                push!(E, (min(i,j),max(i,j)))
            end 
        else 
                push!(D, (i,j))
        end 
    end 
    return cp_dag(D,E)
end 
        
function apply_meek(G)
    Gvar = cp_dag_to_Graph(G)
    Gout = meek_rules!(Gvar;rule4 = true )
    return Graph_to_cp_dag(Gout )
end 

