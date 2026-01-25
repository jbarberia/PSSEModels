function variable_load_power(pm::AbstractPowerModel; kwargs...)
    variable_load_power_real(pm; kwargs...)
    variable_load_power_imag(pm; kwargs...)
end


function variable_load_power_real(pm::AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    pd = var(pm, nw)[:pd] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :load)], base_name="$(nw)_pd",
        start = comp_start_value(ref(pm, nw, :load, i), "pd_start")
    )

    if bounded
        for (i, load) in ref(pm, nw, :load)
            JuMP.set_lower_bound(pd[i], get(load, "pd_min", -99.99))
            JuMP.set_upper_bound(pd[i], get(load, "pd_max",  99.99))
        end
    end

    report && _IM.sol_component_value(pm, pm_it_sym, nw, :load, :pd, ids(pm, nw, :load), pd)
end


function variable_load_power_imag(pm::AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    qd = var(pm, nw)[:qd] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :load)], base_name="$(nw)_qd",
        start = comp_start_value(ref(pm, nw, :load, i), "qd_start")
    )

    if bounded
        for (i, load) in ref(pm, nw, :load)
            JuMP.set_lower_bound(qd[i], get(load, "qd_min", -99.99))
            JuMP.set_upper_bound(qd[i], get(load, "qd_max",  99.99))
        end
    end

    report && _IM.sol_component_value(pm, pm_it_sym, nw, :load, :qd, ids(pm, nw, :load), qd)
end


function variable_shunt_admitance(pm::AbstractPowerModel; nw::Int=nw_id_default, bounded::Bool=true, report::Bool=true)
    bs = var(pm, nw)[:bs] = JuMP.@variable(pm.model,
        [i in ids(pm, nw, :shunt)], base_name="$(nw)_bs",
        start = comp_start_value(ref(pm, nw, :shunt, i), "bs_start")
    )

    if bounded
        for (i, shunt) in ref(pm, nw, :shunt)
            JuMP.set_lower_bound(bs[i], get(shunt, "bs_min", shunt["bs"]))
            JuMP.set_upper_bound(bs[i], get(shunt, "bs_max", shunt["bs"]))
        end
    end

    report && _IM.sol_component_value(pm, pm_it_sym, nw, :shunt, :bs, ids(pm, nw, :shunt), bs)
end
