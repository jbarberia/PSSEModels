"""
    prepare_psse_data(file::String)

Reads a PSS/E .sav file and prepares the PowerModels data dictionary by:
1. Parsing the .sav file.
2. Merging zero-impedance connected buses.
3. Correcting PV bus types based on connected generators.
4. Setting start values for variables from the power flow solution.
"""
function prepare_psse_data(file::String)
    psspy.psseinit()
    psspy.case(file)
    data = build_pm_data()
    merge_zi_connected_buses!(data)
    correct_pv_bus_type!(data)
    set_start_values!(data)
    return data
end

"""
    prepare_psse_data(data::Dict{String, Any})

Prepares an existing PowerModels data dictionary by:
1. Merging zero-impedance connected buses.
2. Correcting PV bus types based on connected generators.
3. Setting start values for variables from the power flow solution.
"""
function prepare_psse_data(data::Dict{String, Any})
    merge_zi_connected_buses!(data)
    correct_pv_bus_type!(data)
    set_start_values!(data)
    return data
end
