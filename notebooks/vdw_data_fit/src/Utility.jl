function load_material_properties(path_to_properties_file::String)::Dict{String,Any}
    dd = TOML.parsefile(path_to_properties_file)
    return dd
end

function load_data_table(path_to_data_file::String)::DataFrame
    return CSV.read(path_to_data_file)
end