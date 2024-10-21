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
    R = Set(Int64[])
    frontier = TaggedEdge[]
    next_frontier = TaggedEdge[]
    visited = TaggedEdge[]

    D_prime = copy(D)
    original_nv = nv(D)
    # 1. Add a dummy vertex for each node j in J
    for i in 1:length(J)
        add_vertex!(D_prime)
        add_edge!(D_prime, original_nv +i, J[i])
        push!(frontier, TaggedEdge(Edge(original_nv +i, J[i]), false))

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

            # Check if it's a "s -> t" edge or "s <- t" in the original graph 
            s_to_t = s < original_nv +1 ? has_edge(D, s, t) : true 

            # Find all out-edges from t in D_prime (these are the neighbors of t in D)
            for f in outedges(D_prime, t)
                _, u = f

                u_to_t = has_edge(D, u, t)
                t_is_collider = s < original_nv + 1 ? (s_to_t && u_to_t) : false

                # If t is a collider and we've already passed a collider, skip
                t_is_collider && passed_collider && continue

                new_tagged_edge = TaggedEdge(Edge(t, u), passed_collider || t_is_collider)

                # Skip if already visited
                new_tagged_edge in visited && continue 

                # Skip if it's an illegal edge pair
                #FIXME: I don't think I'm ever getting here! What to do...
                (e, Edge(t, u)) in illegal_edges && continue 
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
        frontier = copy(next_frontier)
        next_frontier = TaggedEdge[]
    end
end

function outedges(D::SimpleDiGraph, t::Int64)
    L = []
    for edge in edges(D)
        if src(edge) == t
            push!(L, (t, dst(edge)))
        end
    end
    return L 
end 


# Function to check for star-separation
function star_separation(
    D::SimpleDiGraph,
    J::Vector{Int64},
    L::Vector{Int64}
)
    # 1. Compute the ancestors of L
    L_ancestors = Int64[]
    for v in L
        union!(L_ancestors, ancestors(D,v))
    end

        # 3a. Construct the illegal list of edges
    illegal_edges = Tuple{Edge, Edge}[]
    for s in vertices(D)
        for t in outneighbors(D, s)
            # Handle all (outgoing) edges s -> t
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end

            # Handle cases where t is an ancestor
            for u in inneighbors(D, t)
                if !(t in L_ancestors)
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
        end

        for t in inneighbors(D, s)
            # Handle all (incoming) edges s <- t
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end

            # Handle cases for non-colliders (s <- t <- u)
            for u in inneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
        end
    end


    # 3. Perform the star reachability algorithm
    K_prime = star_reachability(D, illegal_edges, J)

    # 4. Determine the *-separated nodes
    K = collect(vertices(D))
    setdiff!(K, K_prime)
    setdiff!(K, J)
    setdiff!(K, L)

    return K
end