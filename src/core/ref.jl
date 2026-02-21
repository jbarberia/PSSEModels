
"""
    ref_add_area_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})

Extends the PowerModels reference dictionary with PSS/E area information.
"""
function ref_add_area_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    apply_pm!(_ref_add_area_info!, ref, data; apply_to_subnetworks = true)
end


function _ref_add_area_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    area = unique([bus["area"] for (i, bus) in ref[:bus]])
    ref[:area] = area

    ref[:area_bus] = Dict(a => [] for a in area)
    for (i, bus) in ref[:bus]
        a = bus["area"]
        push!(ref[:area_bus][a], bus["index"])
    end
    
    ref[:area_load] = Dict(a => [] for a in area)
    for (i, load) in ref[:load]
        b = load["load_bus"]
        a = ref[:bus][b]["area"]
        push!(ref[:area_load][a], load["index"])
    end

    ref[:area_gen] = Dict(a => [] for a in area)
    for (i, gen) in ref[:gen]
        b = gen["gen_bus"]
        a = ref[:bus][b]["area"]
        push!(ref[:area_gen][a], gen["index"])
    end
end


"""
    ref_add_zone_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})

Extends the PowerModels reference dictionary with PSS/E zone information.
"""
function ref_add_zone_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    apply_pm!(_ref_add_zone_info!, ref, data; apply_to_subnetworks = true)
end


function _ref_add_zone_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    zone = unique([bus["zone"] for (i, bus) in ref[:bus]])
    ref[:zone] = zone
 
    ref[:zone_bus] = Dict(z => [] for z in zone)
    for (i, bus) in ref[:bus]
        z = bus["zone"]
        push!(ref[:zone_bus][z], i)
    end 
    
    ref[:zone_load] = Dict(z => [] for z in zone)
    for (i, load) in ref[:load]
        b = load["load_bus"]
        z = ref[:bus][b]["zone"]
        push!(ref[:zone_load][z], load["index"])
    end

    ref[:zone_gen] = Dict(z => [] for z in zone)
    for (i, gen) in ref[:gen]
        b = gen["gen_bus"]
        z = ref[:bus][b]["zone"]
        push!(ref[:zone_gen][z], gen["index"])
    end
end


"""
    ref_add_owner_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})

Extends the PowerModels reference dictionary with PSS/E owner information.
"""
function ref_add_owner_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    apply_pm!(_ref_add_owner_info!, ref, data; apply_to_subnetworks = true)
end


function _ref_add_owner_info!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    owner = unique([bus["owner"] for (i, bus) in ref[:bus]])
    ref[:owner] = owner
 
    ref[:owner_bus] = Dict(z => [] for z in owner)
    for (i, bus) in ref[:bus]
        o = bus["owner"]
        push!(ref[:owner_bus][o], i)
    end 
    
    ref[:owner_load] = Dict(z => [] for z in owner)
    for (i, load) in ref[:load]
        b = load["load_bus"]
        o = ref[:bus][b]["owner"]
        push!(ref[:owner_load][o], load["index"])
    end

    ref[:owner_gen] = Dict(z => [] for z in owner)
    for (i, gen) in ref[:gen]
        b = gen["gen_bus"]
        o = ref[:bus][b]["owner"]
        push!(ref[:owner_gen][o], gen["index"])
    end
end
