function load_material_properties(path_to_properties_file::String)::Dict{String,Any}
    dd = TOML.parsefile(path_to_properties_file)
    return dd
end

function load_data_table(path_to_data_file::String)::DataFrame
    return CSV.read(path_to_data_file)
end

function compute_compressibility(path_to_data_file::String, path_to_properties_file::String)

    # load the properties dictionary -
    properties_dictionary = load_material_properties(path_to_properties_file)
    data_table = load_data_table(path_to_data_file)

    # lets build a working fluid, and then an equation of state - 
    working_fluid = buildSingleComponentWorkingFluid(properties_dictionary["methane"])

    # let's use the vdw -
    vdw_eos_model = buildVanDerWaalsEquationOfState(working_fluid)
    pr_eos_model = buildPengRobinsonEquationOfState(working_fluid)

    # compute the data Z, and the model Z -
    Z_data = compressibility(data_table)

    # compute Z_model -
    Z_model_vdw = compressibility(vdw_eos_model, data_table)
    Z_model_pr = compressibility(pr_eos_model, data_table)
    Z_model_lk = compressibility_lk(path_to_data_file, path_to_properties_file)

    # packagae -
    Z_model_array = [Z_model_vdw Z_model_pr Z_model_lk]

    # return -
    return (Z_data,Z_model_array,properties_dictionary,data_table)
end