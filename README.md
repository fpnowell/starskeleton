This is code accompanying the paper "A PC Algorithm for Max-Linear Bayesian Networks" (Améndola, Hollering, Nowell, 2025). 

The main function is `PCstar`, a causal discovery algorithm which takes either a true weighted DAG `G,C` with bounded in-degree `degbound`, or a set of C*-separation statements coming from a true DAG `G` as input, 
and outputs a partially oriented graph approximating `G`. 

Implementations of *- and C*-separation are present in `separation.jl`. `oracle.jl` collects all separation statements which hold in a given DAG. 

The data in Table 1 of the aforementioned paper was generated using the methods in `benchmark.jl`. 

The authors thank the developers of OSCAR, Graphs.jl and CausalInference.jl.

