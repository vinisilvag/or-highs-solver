using JuMP
using HiGHS

mutable struct Graph
    n::Int
    g::Array{Array{Int}}
    w::Matrix{Float64}
end

function read_input(file)
    n = 0
    g = [[]]
    w = [[]]

    for line in eachline(file)
	q = split(line, "\t")

	if q[1] == "n"
            n = parse(Int64, q[2])
	    g = [[] for _ = 1:n]
	    w = zeros(Float64, (n, n))
	elseif q[1] == "e"
	    v = parse(Int64, q[2])
	    u = parse(Int64, q[3])
	    ww = parse(Float64, q[4])
	    
	    push!(g[v], u)
	    push!(g[u], v)
	    w[v, u] = ww
	    w[u, v] = ww
	end
    end
	
    return Graph(n, g, w)
end

function print_solution(data, x, y, sol)
    println("VERTICES")

    for i = 1:data.n
	if value(y[i]) == 1
	    print("$(i) ")
	end
    end

    println()
end

file = open(ARGS[1], "r")
data = read_input(file)

model = Model(HiGHS.Optimizer)

@variable(model, x[1:data.n, 1:data.n], Bin)
@variable(model, y[1:data.n], Bin)

for i = 1:data.n
    for j in data.g[i]
	@constraint(model, x[i, j] <= y[i])
	@constraint(model, x[i, j] <= y[j])
	@constraint(model, x[i, j] >= y[i] + y[j] - 1)
    end
end

@objective(model, Max, sum(x[i, j] * data.w[i, j] for i = 1:data.n for j = 1:data.n))

print(model)

optimize!(model)

sol = objective_value(model)
# println("TP1 2021421869 = ", sol)

print_solution(data, x, y, sol)
