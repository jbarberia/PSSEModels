using PSSE2PowerModels
using PSSEModels
using PowerModels
using Ipopt
using JuMP
using Test

optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "tol"=>1e-4,
    "max_iter"=>200,
    "print_level"=>5,
    "nlp_scaling_method"=>"none",
)

include("powerflow.jl")
include("voltage_opt.jl")
