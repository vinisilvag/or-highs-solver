using JuMP
using HiGHS

mutable struct Graph
  n::Int
  g::Array{Array{Int}}
end

function read_input(file)
  n = 0
  g = [[]]

  for line in eachline(file)
    q = split(line, "\t")

    if q[1] == "n"
      n = parse(Int64, q[2])
      g = [[] for _ = 1:n]
    elseif q[1] == "e"
      v = parse(Int64, q[2])
      u = parse(Int64, q[3])
      push!(g[v], u)
      push!(g[u], v)
    end
  end

  return Graph(n, g)
end

function print_solution(data, x, sol)
  println("$(sol) VERTICES")

  for i = 1:data.n
    if value(x[i]) == 1
      print("$(i) ")
    end
  end

  println()
end

file = open(ARGS[1], "r")
data = read_input(file)

model = Model(HiGHS.Optimizer)

set_silent(model)

@variable(model, x[1:data.n], Bin)

for i = 1:data.n
  for j in data.g[i]
    @constraint(model, x[i] + x[j] <= 1)
  end
end

@objective(model, Max, sum(x[i] for i = 1:data.n))

# print(model)

optimize!(model)

sol = objective_value(model)
println("TP1 2021421869 = ", sol)

# print_solution(data, x, sol)
