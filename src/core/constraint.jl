function constraint_fixed_load_power(pm::_PM.AbstractPowerModel, i::Int; nw::Int=nw_id_default)
    load = ref(pm, nw, :load, i)
    load_pd = load["pd"]
    load_qd = load["qd"]
    
    pd = get(var(pm, nw), :pd, nothing)
    qd = get(var(pm, nw), :qd, nothing)
    
    !isnothing(pd) && fix(pd[i], load_pd; force=true)
    !isnothing(qd) && fix(qd[i], load_qd; force=true)
end
