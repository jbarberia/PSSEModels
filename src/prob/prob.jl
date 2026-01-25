function run_prob(file, model_constructor, optimizer; kwargs...)
    return solve_model(
        file,
        model_constructor,
        optimizer,
        build_prob;
        multinetwork=false,
        ref_extensions=[
            ref_add_area_info!,
            ref_add_zone_info!,
            ref_add_owner_info!,
        ], kwargs...)
end


function build_prob(pm::AbstractPowerModel)
    _PM.variable_bus_voltage(pm, bounded = false)
    _PM.variable_gen_power(pm, bounded = false)
    _PM.variable_branch_power(pm, bounded = false)
    _PM.variable_branch_transform_magnitude(pm, bounded = true)
    PSSEModels.variable_load_power(pm, bounded = false)
    PSSEModels.variable_shunt_admitance(pm, bounded = true)
    _PM.variable_dcline_power(pm, bounded = false)

    for (i, brn) in ref(pm, :branch)        
        tm = var(pm, :tm, i)
        fix(tm, brn["tap"]; force=true)
    end

    for (i, shunt) in ref(pm, :shunt)
        bs = var(pm, :bs, i)
        fix(bs, shunt["bs"]; force=true)
    end
    
    for (i, load) in ref(pm, :load)
        constraint_fixed_load_power(pm, i)        
    end

    for i in ids(pm, :branch)
        PSSEModels.constraint_ohms_y_oltc_from(pm, i)
        PSSEModels.constraint_ohms_y_oltc_to(pm, i)
    end

    constraint_model_voltage(pm)

    for (i,bus) in ref(pm, :ref_buses)
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

    for (i,bus) in ref(pm, :bus)
        constraint_power_balance(pm, i)

        # PV Bus Constraints
        if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm,:ref_buses))
            # this assumes inactive generators are filtered out of bus_gens
            @assert bus["bus_type"] == 2

            constraint_voltage_magnitude_setpoint(pm, i)
            for j in ref(pm, :bus_gens, i)
                constraint_gen_setpoint_active(pm, j)
            end
        end
    end


    for (i,dcline) in ref(pm, :dcline)
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

end

