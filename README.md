This is code accompanying the paper "A PC Algorithm for Max-Linear Bayesian Networks" (Améndola, Hollering, Nowell, 2025). 

The main function is `PCstar` (contained in `PCstar.jl` ), a causal discovery algorithm which takes either a true weighted DAG `G,C` with bounded in-degree `degbound`, or a set of C*-separation statements coming from a true DAG `G` as input, 
and outputs a partially oriented graph with the same skeleton, unshielded colliders and orientable cycles as the weighted transitive reduction of`G`. 

Implementations of \*- and C\*-separation are present in `separation.jl`. The file `oracle.jl` collects all separation statements which hold in a given DAG. 

The data in Table 1 of the aforementioned paper was generated using the `run_benchmark` methods contained in `benchmark.jl`.  

The authors thank the developers of OSCAR, Graphs.jl and CausalInference.jl.

