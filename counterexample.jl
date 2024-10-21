include("new_starsep.jl")

counterexample = deserialize("counterexample.jls")

L = statement_difference(counterexample)

threesixstatements = []
statements = get_starsepstatements(counterexample)

for statement in statements
    if statement[1] == 3 && statement[2] == 6 
        push!(threesixstatements, statement)
    end 
end 

#wait, is this even a counterexample? Is "ne(i)" in the theorem the set of directed or undirected neighbors? 
#If undirected I don't think I have a counterexample yet. 

#!!! _verify_theorem(counterexample) yields true. I'm STILL COOKING. 