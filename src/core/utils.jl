"""
    set_start_values!(data::Dict{String, Any})

Initializes start values for PowerModels variables (va, vm, pg, qg, etc.) 
based on the current values in the PSS/E case.
"""
function set_start_values!(data::Dict{String, Any})
for (i,bus) in data["bus"]
        bus["va_start"] = bus["va"]
        bus["vm_start"] = bus["vm"]
    end

    for (i,gen) in data["gen"]
        gen["pg_start"] = gen["pg"]
        gen["qg_start"] = gen["qg"]
    end
    
    for (i,load) in data["load"]
        load["pd_start"] = load["pd"]
        load["qd_start"] = load["qd"]
    end

    flows = calc_branch_flow_ac(data)["branch"]    
    for (i, brn) in data["branch"]
        brn["tm_start"] = brn["tap"]        
        brn["tm_min"] = !haskey(brn, "tm_min") ? brn["tap"] : brn["tm_min"]
        brn["tm_max"] = !haskey(brn, "tm_max") ? brn["tap"] : brn["tm_max"]

        brn["pf_start"] = flows[i]["pf"]
        brn["pt_start"] = flows[i]["pt"]
        brn["qf_start"] = flows[i]["qf"]
        brn["qt_start"] = flows[i]["qt"]
    end

    for (i, shunt) in data["shunt"]
        shunt["bs_start"] = shunt["bs"]
        shunt["bs_min"] = !haskey(shunt, "bs_min") ? shunt["bs"] : shunt["bs_min"]
        shunt["bs_max"] = !haskey(shunt, "bs_max") ? shunt["bs"] : shunt["bs_max"]
        
        if get(shunt, "mode", 0) == 0
            shunt["bs_min"] = shunt["bs"]
            shunt["bs_max"] = shunt["bs"]
        end        
    end
end
