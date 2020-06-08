function compressibility(data::DataFrame; R::Float64 = 0.008314)::Array{Float64,1}

    # initialize -
    Z_array = Array{Float64,1}()
    
    # setup the col names -
    PcolName = Symbol("Pressure (MPa)")
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")

    # get cols from the data table -
    P = data[!,PcolName]
    V = data[!,VcolName]
    T = data[!,TcolName]

    # how many data points?
    number_of_data_points = length(T)
    for index = 1:number_of_data_points
        
        # compute the Z -
        tmp_val = (P[index]*V[index])/(R*T[index])

        # grab -
        push!(Z_array,tmp_val)
    end

    # return -
    return Z_array
end

function compressibility(eos::AbstractEquationOfState, data::DataFrame; R::Float64 = 0.008314)::Array{Float64,1}

    # initialize -
    Z_array = Array{Float64,1}()

    # setup the col names -
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")

    # get cols from the data table -
    V = data[!,VcolName]
    T = data[!,TcolName]
    
    # how many data points?
    number_of_data_points = length(T)
    for index = 1:number_of_data_points

        # get V and T -
        V_value = V[index]
        T_value = T[index]

        # compute the pressure using the model -
        P_model = pressure(eos,V_value,T_value)
        
        # compute the Z -
        tmp_val = (P_model*V_value)/(R*T_value)

        # grab -
        push!(Z_array,tmp_val)
    end

    # return -
    return Z_array
end

function compressibility_lk(path_to_data_file::String, path_to_properties_file::String)

    # load the properties dictionary -
    properties_dictionary = load_material_properties(path_to_properties_file)
    properties_dictionary["ωr"] = 0.3978
    data_table = load_data_table(path_to_data_file)

    # lets build a working fluid, and then an equation of state - 
    working_fluid = buildSingleComponentWorkingFluid(properties_dictionary["methane"])
    lk_eos_model = buildLeeKeslerEquationOfState(working_fluid)

    # compute VStar -
    # setup the col names -
    PcolName = Symbol("Pressure (MPa)")
    TcolName = Symbol("Temperature (K)")

    # get cols from the data table -
    P = data_table[!,PcolName]
    T = data_table[!,TcolName]

    # Compute simple fluid -
    Z0_array = Array{Float64,1}()
    number_of_data_points = length(T)
    for index = 1:number_of_data_points
        tmp_value = compute_simple_compressibility_lk(lk_eos_model,P[index],T[index])
        push!(Z0_array,tmp_value)
    end

    # compute the correction -
    Z1_array = Array{Float64,1}()
    for index = 1:number_of_data_points
        tmp_value = compute_complex_compressibility_lk(lk_eos_model, Z0_array[index], P[index], T[index])
        push!(Z1_array,tmp_value)
    end

    # finally, compute Z -
    ω = working_fluid.ω
    Z_lk = Z0_array .+ (ω*Z1_array)

    # return -
    return Z_lk
end