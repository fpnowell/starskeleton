

function star_d_difference(G::SimpleDiGraph)
    return setdiff(get_starsepstatements(G), get_dsepstatements(G))
end 

function star_d_difference_wrt_nodes(G::SimpleDiGraph, i::Int64, j::Int64)
    L = star_d_difference(G)
    output = []
    for statement in L
        k, l, K = statement 
        if k == i && l == j
            push!(output, K)
        end 
    end 
    return output
end 


function star_d_statements_unequal(H::SimpleDiGraph)
    return !isempty(star_d_difference(H))
end 


function verify_claim(H::SimpleDiGraph)
    L = star_d_difference(H)
    bool = true
    while !isempty(L)
        statement = pop!(L)
        i, j, K = statement 
        P = collect(powerset(K))
        if any(K_prime -> in([i,j,K_prime],get_starsepstatements(H)) && 
            (issubset(K_prime, setdiff(union(inneighbors(H,i), neighbors(H,i)), [j])) || issubset(K_prime, setdiff(union(inneighbors(H,j), neighbors(H,j)), [i]))), P)
            continue 
        else 
            bool = false 
            break 
        end 
    end 
    return bool 
end 

function claim_false(H::SimpleDiGraph)
    return !verify_claim(H)

end 

