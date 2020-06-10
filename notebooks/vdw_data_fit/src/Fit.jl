function objective_function(x, eos::VanDerWaalsEquationOfState, data::DataFrame)::Float64

    # get parameter guess -
    a = x[1]
    b = x[2]

    # update the eos -
    eos.a = a
    eos.b = b

    # get the PVT data -
    PcolName = Symbol("Pressure (MPa)")
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")
    P_data_array = data[!,PcolName]
    V_data_array = data[!,VcolName]
    T_data_array = data[!,TcolName]

    # compute the model P -
    P_model_array = Array{Float64,1}()
    number_of_data_points = length(T_data_array)
    for index = 1:number_of_data_points
        
        # get the measured V and T -
        V = V_data_array[index]
        T = T_data_array[index]

        # compute pressure -
        P_model_value = pressure(eos,V,T)

        # grab -
        push!(P_model_array, P_model_value)
    end

    # compute the error -
    error = (P_model_array .- P_data_array)

    # penalty term -
    lambda = 10000000.0
    p_term_1 = max(0,-1*a)
    p_term_2 = max(0,-1*b)

    # return -
    return transpose(error)*error + lambda*(p_term_1 + p_term_2)
end

function fit_model(path_to_data_file::String, path_to_material_file::String)

    # load the data and material properties -
    df = load_data_table(path_to_data_file)
    pd = load_material_properties(path_to_material_file)["methane"]

    # setup the problem -
    working_fluid_model = buildSingleComponentWorkingFluid(pd)
    vdwEOS = buildVanDerWaalsEquationOfState(working_fluid_model)

    # setup initial guess -
    initial_guess = [
        rand()*vdwEOS.a ;
        rand()*vdwEOS.b ;
    ];

    # setup the obj funnction -
    OF(p) = objective_function(p, vdwEOS, df)

    # call the optimizer -
    opt_result = optimize(OF,initial_guess,BFGS())
    
    # return -
    return Optim.minimizer(opt_result)
end

function evaluate_model_pressure(eos::VanDerWaalsEquationOfState, data::DataFrame)::Array{Float64,1}

    # get the PVT data -
    PcolName = Symbol("Pressure (MPa)")
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")
    P_data_array = data[!,PcolName]
    V_data_array = data[!,VcolName]
    T_data_array = data[!,TcolName]

    # compute the model P -
    P_model_array = Array{Float64,1}()
    number_of_data_points = length(T_data_array)
    for index = 1:number_of_data_points
        
        # get the measured V and T -
        V = V_data_array[index]
        T = T_data_array[index]

        # compute pressure -
        P_model_value = pressure(eos,V,T)

        # grab -
        push!(P_model_array, P_model_value)
    end    

    # return -
    return P_model_array
end

function evaluate_model_temperature(eos::VanDerWaalsEquationOfState, data::DataFrame)::Array{Float64,1}

    # get the PVT data -
    PcolName = Symbol("Pressure (MPa)")
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")
    P_data_array = data[!,PcolName]
    V_data_array = data[!,VcolName]
    T_data_array = data[!,TcolName]

    # compute the model P -
    T_model_array = Array{Float64,1}()
    number_of_data_points = length(T_data_array)
    for index = 1:number_of_data_points
        
        # get the measured V and T -
        V = V_data_array[index]
        T = T_data_array[index]
        P = P_data_array[index]

        # compute pressure -
        T_model_value = temperature(eos,P,V)

        # grab -
        push!(T_model_array, T_model_value)
    end    

    # return -
    return T_model_array
end