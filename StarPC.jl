include("PCstar_dict.jl")
include("PCstar_stmts.jl")
include("PCstar_query.jl")


function test_PCstar(G,C,l) 
    if !is_connected(G)
        return 3
    else 
        #G_out1 = PCstar_query(G,C,l,2)[1]
        #G_out1 = PCstar_stmts(Graphs.nv(G), l, get_Csep_stmts_bounded(G,C,l))
        G_out1 = PCstar_dict(Graphs.nv(G), Csep_dict(G,C,l))
        G_out2 = cp_dag(get_edges(wtr(G,C)[1]), [])
        return G_out1.skeleton == G_out2.skeleton, G_out1.colliders == G_out2.colliders, issubset(directed_edges(G_out1), directed_edges(G_out2))
    end 
end 
