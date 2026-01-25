function variable_load_power(pm::AbstractActivePowerModel; kwargs...)
    variable_load_power_real(pm; kwargs...)
end


function constraint_power_balance(pm::_PM.AbstractActivePowerModel, n::Int, i::Int, bus_arcs, bus_arcs_dc, bus_arcs_sw, bus_gens, bus_storage, bus_loads, bus_shunts)
    p    = get(_PM.var(pm, n),    :p, Dict()); _PM._check_var_keys(p, bus_arcs, "active power", "branch")
    pg   = get(_PM.var(pm, n),   :pg, Dict()); _PM._check_var_keys(pg, bus_gens, "active power", "generator")
    pd   = get(_PM.var(pm, n),   :pd, Dict()); _PM._check_var_keys(pd, bus_loads, "active power", "load")
    ps   = get(_PM.var(pm, n),   :ps, Dict()); _PM._check_var_keys(ps, bus_storage, "active power", "storage")
    psw  = get(_PM.var(pm, n),  :psw, Dict()); _PM._check_var_keys(psw, bus_arcs_sw, "active power", "switch")
    p_dc = get(_PM.var(pm, n), :p_dc, Dict()); _PM._check_var_keys(p_dc, bus_arcs_dc, "active power", "dcline")
    gs   = Dict(k => _PM.ref(pm, n, :shunt, k, "gs") for k in bus_shunts)
    
    cstr = JuMP.@constraint(pm.model,
        sum(p[a] for a in bus_arcs)
        + sum(p_dc[a_dc] for a_dc in bus_arcs_dc)
        + sum(psw[a_sw] for a_sw in bus_arcs_sw)
        ==
        sum(pg[g] for g in bus_gens)
        - sum(ps[s] for s in bus_storage)
        - sum(pd[d] for d in bus_loads)
        - sum(gs[s] for s in bus_shunts)
    )

    if _IM.report_duals(pm)
        _PM.sol(pm, n, :bus, i)[:lam_kcl_r] = cstr        
    end
end


function constraint_ohms_y_oltc_from(pm::AbstractActivePowerModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr)    
    p_fr  = var(pm, n,  :p, f_idx)
    va_fr = var(pm, n, :va, f_bus)
    va_to = var(pm, n, :va, t_bus)

    JuMP.@constraint(pm.model, p_fr == -b*(va_fr - va_to))
end


function constraint_ohms_y_oltc_to(pm::AbstractActivePowerModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr)
    # nothing becuase simetric model
end
