using PSSEModels
using PSSE2PowerModels
using PowerModels
using JuMP
using Ipopt

# Define your data file path
filename = joinpath(@__DIR__, "..", "test", "V28p_Trs_2633_sin_py.sav")

# Preparar datos
data = prepare_psse_data(filename)

# Define formulation and optimizer
model_constructor = ACPPowerModel
optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "tol"=>1e-4,
    "max_iter"=>200,
    "print_level"=>5,
    "nlp_scaling_method"=>"none",
)

# Run the standard power flow problem (run_prob)
result = run_prob(data, model_constructor, optimizer)
println("Status: ", result["termination_status"])
