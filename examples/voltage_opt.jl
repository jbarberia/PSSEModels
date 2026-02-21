"""
# Optimización de Tensión en Brandsen

Este ejemplo muestra cómo crear un modelo de optimización personalizado extendiendo las funciones base de PSSEModels.
El objetivo es maximizar la tensión en el nodo 2239 (Brandsen) utilizando las consignas de tensión de los parques eólicos de la provincia de Buenos Aires como variables de control.

Para correr este ejemplo:
1. Asegúrate de tener instalado Ipopt y PSSE2PowerModels.
2. Ejecuta: `julia --project=. examples/voltage_opt.jl`
"""

using PSSEModels
using PowerModels
using Ipopt
using JuMP
using Printf

const _PM = PowerModels

function build_voltage_opt(pm::AbstractPowerModel)    
    # Usar las funciones modulares del template
    PSSEModels.variable_standard_psse!(pm)
    PSSEModels.constraint_standard_psse_branch!(pm)
    PSSEModels.constraint_standard_psse_voltage!(pm)

    # Personalización de restricciones de bus
    for (i, bus) in ref(pm, :ref_buses)
        constraint_theta_ref(pm, i)
        constraint_voltage_magnitude_setpoint(pm, i)
    end

    for (i, bus) in ref(pm, :bus)
        constraint_power_balance(pm, i)

        # Lógica personalizada para PV Bus
        if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm, :ref_buses))
            # Si es un parque eólico (Area 5, Owner 11), dejamos la tensión libre para optimizar
            if !(bus["area"] == 5 && bus["owner"] == 11)
                constraint_voltage_magnitude_setpoint(pm, i)
            end

            for j in ref(pm, :bus_gens, i)
                constraint_gen_setpoint_active(pm, j)
            end
        end
    end

    PSSEModels.constraint_standard_psse_dcline!(pm)

    # Añadir restricciones de límites de tensión personalizadas
    for (i, bus) in ref(pm, :bus)
        vm = var(pm, :vm, i)
        if (bus["area"] == 5 && bus["owner"] == 11)
            @constraint(pm.model, vm <= 1.05)
            @constraint(pm.model, vm >= 0.95)
        elseif (bus["area"] == 5 && bus["base_kv"] == 132)
            @constraint(pm.model, vm <= 1.05)
            @constraint(pm.model, vm >= 0.85)
        else
            @constraint(pm.model, vm <= 1.20)
            @constraint(pm.model, vm >= 0.85)
        end
    end

    # Definir la Función Objetivo
    # Maximizar la tensión en el nodo 2239 (Brandsen)    
    @objective(pm.model, Max, var(pm, :vm, 2239))
end

# Función para ejecutar este modelo específico
function run_voltage_opt(file, model_constructor, optimizer; kwargs...)
    return solve_model(
        file,
        model_constructor,
        optimizer,
        build_voltage_opt;
        ref_extensions=[
            ref_add_area_info!,
            ref_add_zone_info!,
            ref_add_owner_info!,
        ], kwargs...)
end

# Cargar datos
filename = joinpath(@__DIR__, "..", "test", "V28p_Trs_2633_sin_py.sav")

# Armar caso en Powermodel
data = prepare_psse_data(filename)

# Valor inicial (después de inicializar psspy en prepare_psse_data)
_, vm0 = psspy.busdat(2239, "PU")

# Define formulation and optimizer
model_constructor = ACPPowerModel
optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "tol"=>1e-4,
    "max_iter"=>200,
    "print_level"=>5,
    "nlp_scaling_method"=>"none",
)

# Correr optimizacion
results = run_voltage_opt(data, ACPPowerModel, optimizer)
println("Estado final: ", results["termination_status"])

# Cargar resultado a PSSE
update_data!(data, results["solution"])
PSSE2PowerModels.build_psse_data(data)
psspy.fnsl()

# Obtener valor final
_, vm1 = psspy.busdat(2239, "PU")

println("\n")
println("-"^80)
@printf("Tensión en Brandsen (2239): %.4f antes\n", vm0)
@printf("Tensión en Brandsen (2239): %.4f despues\n", vm1)
println("-"^80)

