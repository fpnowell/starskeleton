# this function is deprecated
# our original definition did not induce an equivalence relation on graphs
function compute_mecs(graph_list, t)

    mecs = Dict([])

    for G in graph_list

        if length(mecs) == 0 
            mecs[G] = [G]
            continue
        end

        found_existing_class = false

        for H in keys(mecs)

            if are_crit_equiv(G, H, t)
                mecs[H] = push!(mecs[H], G)
                found_existing_class = true
                break
            end
        end

        if !found_existing_class
            mecs[G] = [G]
        end
    end

    return mecs
end

# deprecated test for critical equivalence
function are_crit_equiv(G::SimpleDiGraph, H::SimpleDiGraph, t::Int64)

    conesG = get_cone_reps(G, t)
    conesH = get_cone_reps(H, t)

    return any(i -> i in conesH, conesG)
end