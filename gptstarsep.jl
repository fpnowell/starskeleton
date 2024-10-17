using Graphs, CausalInference

# Define the types for edges and tagged edges
struct Edge
    from::Int64
    to::Int64
end

struct TaggedEdge
    edge::Edge
    passed_collider::Bool
end

# Function to perform the star reachability search
function star_reachability(
    D::SimpleDiGraph,
    illegal_edges::Vector{Tuple{Edge, Edge}},
    J::Vector{Int64}
)
    R = Int64[]
    frontier = TaggedEdge[]
    next_frontier = TaggedEdge[]
    visited = TaggedEdge[]

    D_prime = copy(D)
    # 1. Add a dummy vertex for each node j in J
    for i in 1:length(J)
        add_vertex!(D_prime)
        add_edge!(D_prime, nv(D)+i, J[i])
        push!(frontier, TaggedEdge(Edge(nv(D)+i, J[i]), false))

        # Add to the reachability set
        push!(R, J[i])
        push!(R, nv(D)+i)
    end

    # 2. Add reversed edges to D_prime
    for s in vertices(D)
        for t in outneighbors(D, s)
            add_edge!(D_prime, t, s) # Add the flipped edge
        end
    end

    while true
        # 3. Expand the reachability set
        for tagged_edge in frontier
            e = tagged_edge.edge
            passed_collider = tagged_edge.passed_collider
            s, t = e.from, e.to

            push!(R, t)

            # Check if it's a "s -> t" edge or "s <- t"
            s_to_t = s > 0 ? has_edge(D, s, t) : true

            # Find all out-edges from t in D_prime
            for f in outedges(D_prime, t)
                _, u = f

                u_to_t = has_edge(D, u, t)
                t_is_collider = s > 0 ? (s_to_t && u_to_t) : false

                # If t is a collider and we've already passed a collider, skip
                if t_is_collider && passed_collider
                    continue
                end

                new_tagged_edge = TaggedEdge(Edge(t, u), passed_collider || t_is_collider)

                # Skip if already visited
                if new_tagged_edge in visited
                    continue
                end

                # Skip if it's an illegal edge pair
                if (e, Edge(t, u)) in illegal_edges
                    continue
                end

                # Add to the next frontier
                push!(next_frontier, new_tagged_edge)
            end
        end

        # Mark the current frontier as visited
        union!(visited, frontier)

        # If no more nodes can be reached, return R
        if isempty(next_frontier)
            return R
        end

        # Move to the next frontier
        frontier = next_frontier
        empty!(next_frontier)
    end
end

# Function to check for star-separation
function star_separation(
    D::SimpleDiGraph,
    J::Vector{Int64},
    L::Vector{Int64}
)
    # 1. Compute the descendants Vector
    in_lists = Dict{Int64, Vector{Int64}}[]
    for v in vertices(D)
        in_lists[v] = inneighbors(D, v)
    end

    descendants = Int64[]
    for v in L
        push!(descendants, v)
        union!(descendants, in_lists[v])
    end

    # 3a. Construct the illegal list of edges
    illegal_edges = Tuple{Edge, Edge}[]
    for s in vertices(D)
        for t in vertices(D)
            push!(illegal_edges, (Edge(s, t), Edge(t, s)))
        end
    end

    for s in vertices(D)
        for t in outneighbors(D, s)
            # Handle all (outgoing) edges s -> t
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
            for u in in_lists[t]
                if !(t in descendants)
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
        end

        for t in in_lists[s]
            # Handle all (incoming) edges s <- t
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
            for u in in_lists[t]
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
        end
    end

    # 3. Perform the star reachability algorithm
    K_prime = star_reachability(D, illegal_edges, J)

    # 4. Determine the *-separated nodes
    K = vertices(D)
    setdiff!(K, K_prime)
    setdiff!(K, J)
    setdiff!(K, L)

    return K
end
