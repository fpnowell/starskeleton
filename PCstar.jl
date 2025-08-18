include("PCstar_dict.jl")
include("PCstar_stmts.jl")
include("PCstar_query.jl")


#PCstar allows for three types of arguments 

#1. A true DAG (G,C) + a bound on the in-degree
PCstar(G,C,degbound::Int64) = PCstar_query(G,C,degbound;orient_cycles = true,apply_rules = true)[1]

#2. The number of vertices n of the true DAG, its maximal in-degree degbound and a complete set of separation stmts 
PCstar(n,degbound, stmts::Vector) = PCstar_stmts(n, degbound, stmts) 

#3. The number of vertices of the true DAG and a "Csep_dictionary", with keys indexed by non-adjacent pairs and values being minimal separating sets
PCstar(n,sep_dict::Dict) = PCstar_dict(n,sep_dict )


#By default, cycles are oriented. 
#For fine-tuning, use the individual PCstar_query, PCstar_stmts, PC_star_dict individually. 