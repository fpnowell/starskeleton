#TODO: this should check if K_prime is a subset of one or the other! Not the union! Although this is a more lax condition, so the counterexample is still valid
function verify_theorem(H::SimpleDiGraph)
    L = statement_difference(H)
    bool = true
    while !isempty(L)
        statement = pop!(L)
        i, j, K = statement 
        P = collect(powerset(K))
        if any(K_prime -> in([i,j,K_prime],get_starsepstatements(H)) && issubset(K_prime, setdiff(union(neighbors(H,i), neighbors(H,j)), [i,j])), P)
            continue 
        else 
            bool = false 
            break 
        end 
    end 
    return bool 
end 

#= function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
        G = complete_graph(nv(H))
        sort!(S,by = x->length(x[3]))
        for edge in edges(G)
            i = src(edge)
            j = dst(edge)
            for k in 1:length(S)
                if in([i,j,S[k][3]],S)
                    rem_edge!(G, i,j)
                end
            end
        end
        return G
end =#

