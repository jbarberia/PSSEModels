"""
Problema de optimización que intenta aumentar la tensión en Brandsen.
El unico recurso utilizado es la consigna de tesnión de parques eólicos en PBA.

Sobre esta base se pueden crear otros modelos.
"""

const _PM = PowerModels

function run_voltage_opt(file, model_constructor, optimizer; kwargs...)
    return solve_model(
        file,
        model_constructor,
        optimizer,
        build_voltage_opt;
        multinetwork=false,
        ref_extensions=[
            ref_add_area_info!,
            ref_add_zone_info!,
            ref_add_owner_info!,
        ], kwargs...)
end


function build_voltage_opt(pm::AbstractPowerModel)
    _PM.variable_bus_voltage(pm, bounded=false)
    _PM.variable_gen_power(pm, bounded=false)
    _PM.variable_branch_power(pm, bounded=false)
    _PM.variable_branch_transform_magnitude(pm, bounded=true)
    PSSEModels.variable_load_power(pm, bounded=false)
    PSSEModels.variable_shunt_admitance(pm, bounded=true)
    _PM.variable_dcline_power(pm, bounded=false)

    for (i, brn) in ref(pm, :branch)
        tm = var(pm, :tm, i)
        fix(tm, brn["tap"]; force=true)
    end

    for (i, shunt) in ref(pm, :shunt)
        bs = var(pm, :bs, i)
        fix(bs, shunt["bs"]; force=true)
    end

    for (i, load) in ref(pm, :load)
        PSSEModels.constraint_fixed_load_power(pm, i)
    end

    for i in ids(pm, :branch)
        PSSEModels.constraint_ohms_y_oltc_from(pm, i)
        PSSEModels.constraint_ohms_y_oltc_to(pm, i)
    end

    constraint_model_voltage(pm)

    for (i, bus) in ref(pm, :ref_buses)
        @assert bus["bus_type"] == 3
        constraint_theta_ref(pm, i)
        constraint_voltage_magnitude_setpoint(pm, i)

        # if multiple generators, fix power generation degeneracies
        if length(ref(pm, :bus_gens, i)) > 1
            for j in collect(ref(pm, :bus_gens, i))[2:end]
                constraint_gen_setpoint_active(pm, j)
                constraint_gen_setpoint_reactive(pm, j)
            end
        end
    end

    for (i, bus) in ref(pm, :bus)
        constraint_power_balance(pm, i)

        # PV Bus Constraints
        if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm, :ref_buses))
            @assert bus["bus_type"] == 2

            # eolico regulando libre la tensión
            if !(bus["area"] == 5 && bus["owner"] == 11)
                constraint_voltage_magnitude_setpoint(pm, i)
            end

            for j in ref(pm, :bus_gens, i)
                constraint_gen_setpoint_active(pm, j)
            end
        end
    end


    for (i, dcline) in ref(pm, :dcline)
        #constraint_dcline_power_losses(pm, i) not needed, active power flow fully defined by dc line setpoints
        constraint_dcline_setpoint_active(pm, i)

        f_bus = ref(pm, :bus)[dcline["f_bus"]]
        if f_bus["bus_type"] == 1
            constraint_voltage_magnitude_setpoint(pm, f_bus["index"])
        end

        t_bus = ref(pm, :bus)[dcline["t_bus"]]
        if t_bus["bus_type"] == 1
            constraint_voltage_magnitude_setpoint(pm, t_bus["index"])
        end
    end

    # Buscar minimo de regularidad de tensiones
    for (i, bus) in ref(pm, :bus)
        vm = var(pm, :vm, i)

        # Generadores eolicos
        if (bus["area"] == 5 && bus["owner"] == 11)
            @constraint(pm.model, vm <= 1.05)
            @constraint(pm.model, vm >= 0.95)

            # ET con subtensiones
        elseif (bus["area"] == 5 && bus["base_kv"] == 132)
            @constraint(pm.model, vm <= 1.05)
            @constraint(pm.model, vm >= 0.85)

            # ET sin subtensiones
        elseif (bus["area"] == 5 && bus["base_kv"] == 132 && bus["vm"] >= 0.95)
            @constraint(pm.model, vm <= 1.05)
            @constraint(pm.model, vm >= 0.95)

            # Otros
        else
            @constraint(pm.model, vm <= 1.20)
            @constraint(pm.model, vm >= 0.85)
        end
    end

    # Maximizar la tension en 2239 - Brandsen
    @objective(pm.model, Max, var(pm, :vm, 2239))

end

@testset failfast = true "voltage optimization" begin
    filename = "V28p_Trs_2633_sin_py.sav"

    psspy.psseinit()
    psspy.case(filename)
    _, vm0 = psspy.busdat(2239, "PU")

    data = build_pm_data()
    merge_zi_connected_buses!(data)
    correct_pv_bus_type!(data)
    set_start_values!(data)

    results = run_voltage_opt(data, ACPPowerModel, optimizer)
    update_data!(data, results["solution"])
    PSSE2PowerModels.build_psse_data(data)
    psspy.fnsl()
    _, vm1 = psspy.busdat(2239, "PU")

    @test results["termination_status"] in (LOCALLY_SOLVED, OPTIMAL)
    @test results["primal_status"] == FEASIBLE_POINT
    @test psspy.solved() == 0
    @test vm1 - vm0 >= 0.0
    
    # Main.@infiltrate
    # psspy.save("output.sav")
end
