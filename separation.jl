using Graphs, CausalInference
include("graphfunctions.jl")

#unweighted starseparation 

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
#= INPUT: G, a DAG
        J, a set of nodes
        illegal_edges, a set of pairs of "illegal"  edges of G 

OUTPUT: 
        R, the set of all nodes reachable from R which pass through at most one pair of illegal edges
 =#
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
#=      INPUT:  D, a DAG 
                J, a set of nodes (the "starting" set)
                L, a set of nodes disjoint from K (the separating set)

      OUTPUT:   K, the set of all nodes in D which are star separated from J given L 

The algorithm works similar to Geiger, Verma, Pearl "d -SEPARATION: FROM THEOREMS TO ALGORITHMS"
with a new condition for illegal pairs of edges in step iii of algorithm 2  =#


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

    # 2. Collect the list of illegal pairs of edges
    illegal_edges = Tuple{Edge, Edge}[]
    for s in vertices(D)
        for t in outneighbors(D, s)
            # Handle cases s -> t -> u, where t in L ("t is a non-collider in L")
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end

            # Handle cases s -> t <- u,  where t not in an(L) ("t is a collider not in an(L)")
            for u in inneighbors(D, t)
                if !(t in L_ancestors)
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end
        end

        for t in inneighbors(D, s)
            # Handle cases s <- t -> u, where t in L ("t is a non-collider in L)
            for u in outneighbors(D, t)
                if t in L
                    push!(illegal_edges, (Edge(s, t), Edge(t, u)))
                end
            end

            # Handle cases s <- t <- u, where t in L ("t is a non-collider in L")
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

function starsep(H::SimpleDiGraph, i::Int64, j::Int64, K::Vector{Int64})
    return in(j, star_separation(H, [i], K))
end



##Cseparation 

function Csep(G::SimpleDiGraph, C, K::Vector, i::Int64, j::Int64)
    if issubset([i,j], K)
        return false 
    end 
    G_star = critical_graph(G, K, C)
    undirected_G_star = get_skeleton(G_star)
    paths = collect(all_simple_paths(undirected_G_star, i, j;cutoff = 4)) 
    bool = true 
    for p in paths
        if length(p) == 2 && (Graphs.has_edge(G_star, i,j) || Graphs.has_edge(G_star, j, i))
            bool = false 
            break  
        elseif length(p) == 3 && (is_type_b(G_star, p, K) || is_type_c(G_star, p, K))
            bool = false 
            break 
        elseif length(p) == 4 && is_type_d(G_star, p, K)
            bool = false 
            break  
        elseif length(p) == 5 && is_type_e(G_star, p,K)
            bool = false 
            break 
        else 
            continue 
        end 
    end 
    return bool 
end 

Csep(G::SimpleDiGraph, K, i, j) = Csep(G, constant_weights(G), K, i, j )

