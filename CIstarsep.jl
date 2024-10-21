using CausalInference, Graphs 
function starsep(g::AbstractGraph, U, V, S; verbose = false)
    T = eltype(g)
    in_seen = falses(nv(g)) # nodes reached earlier backwards
    out_seen = falses(nv(g)) # nodes reached earlier forwards
    descendant = falses(nv(g)) # descendant in s
    isv = falses(nv(g))
    blocked = falses(nv(g))
    passed_collider = falses(nv(g))

    for ve in S
        in_seen[ve] = true
        blocked[ve] = true
    end

    next = Vector{T}()

    # mark vertices with descendants in S
    next = Vector{T}()
    for w in S
        push!(next, w)
        descendant[w] = true
    end

    while !isempty(next)
        for w in inneighbors(g, popfirst!(next))
            if !descendant[w]
                push!(next, w) # push onto queue
                descendant[w] = true
            end
        end
    end

    verbose && println(descendant)

    in_next = Vector{T}()
    out_next = Vector{T}()

    for u in U
        push!(in_next, u) # treat u as vertex reached backwards
        in_seen[u] && throw(ArgumentError("U and S not disjoint."))
        in_seen[u] = true
    end
    if V isa Integer
        in_seen[V] && throw(ArgumentError("U, V and S not disjoint."))
        return starsep_inner!(g, in_next, out_next, descendant, ==(V), blocked, out_seen, in_seen, passed_collider; verbose)
    else
        isv = falses(nv(g))
        for v in V
            in_seen[v] && throw(ArgumentError("U, V and S not disjoint."))
            isv[v] = true
        end
        return starsep_inner!(g, in_next, out_next, descendant, w->isv[w], blocked, out_seen, in_seen, passed_collider; verbose)
    end
end

function starsep_inner!(g, in_next, out_next, descendant, found, blocked, out_seen, in_seen, passed_collider; verbose=false)
    while true
        sin = isempty(in_next)
        sout = isempty(out_next)
        sin && sout && return true # no vertices in the queue

        if !sin # some vertex reach backwards in the queue
            src = popfirst!(in_next)
            for w in outneighbors(g, src) # possible collider at destination
                if !out_seen[w] && (!blocked[w] || descendant[w])
                    verbose && println("<- $src -> $w")
                    found(w) && return false
                    push!(out_next, w)
                    out_seen[w] = true
                    passed_collider[w] = passed_collider[src]
                end
            end
            for w in inneighbors(g, src)
                if !in_seen[w]
                    verbose && println("<- $src <- $w")
                    found(w) && return false
                    push!(in_next, w)
                    in_seen[w] = true
                    passed_collider[w] = passed_collider[src]
                end
            end
        end
        if !sout # some vertex reach forwards in the queue
            src = popfirst!(out_next)
            for w in outneighbors(g, src) # possible collider at destination
                if !out_seen[w] && !blocked[src] && (!blocked[w] || descendant[w])
                    verbose && println("-> $src -> $w")
                    found(w) && return false
                    push!(out_next, w)
                    out_seen[w] = true
                    passed_collider[w] = passed_collider[src]
                end
            end
            for w in inneighbors(g, src) # collider at source
                if !in_seen[w] && descendant[src] && !passed_collider[src] # shielded collider, while at most one collider has been encountered
                    verbose && println("-> $src <- $w")
                    found(w) && return false
                    push!(out_next, w)
                    in_seen[w] = true
                    passed_collider[w] = true
                end
            end
        end
    end
end

function get_starsepstatements(H::SimpleDiGraph)
    L = Any[]
    G = complete_graph(nv(H))
    for  edge in edges(G);
        i = src(edge)
        j = dst(edge)
        ne_ij = setdiff(vertices(G), [i,j]) 
        for K in collect(powerset(ne_ij))
            #TODO: currently missing line 5 of the pseudocode ( (i,k) in G, etc.. )! Do you need this!? 
            if starsep(H, i,j, K);
                push!(L, [i,j,K])
                end
        end
    end
    return L
end

function dsep_skeleton(H::SimpleDiGraph)
    return skel_from_statements(H, get_dsepstatements(H))
end    

#QUESTION: in its current state, this simply removes edges from G
#as they appear in sort!(S) 
#Is this enough? Something else to consider? 
function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
    G = complete_graph(nv(H))
    sort!(S, by = x -> length(x[3]))
    for statement in S
        i, j, K = statement 
        if has_edge(G, i, j)
            rem_edge!(G, i, j)
        end
    end
    return G
end

testgraph = copy(cassio)

add_vertex!(testgraph)

add_edge!(testgraph, 1, 6)

add_edge!(testgraph, 6, 2)