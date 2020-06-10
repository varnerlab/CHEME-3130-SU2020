function plot_model_fit(parameter_array::Array{Float64,1}, path_to_data_file::String, path_to_material_file::String)

    # setup new eos w/estimate parameters -
    # load the data and material properties -
    df = load_data_table(path_to_data_file)
    pd = load_material_properties(path_to_material_file)["methane"]
    Vc = pd["critical_volume"]

    # setup the problem -
    working_fluid_model = buildSingleComponentWorkingFluid(pd)
    vdwEOS = buildVanDerWaalsEquationOfState(working_fluid_model)
    vdwEOS.a = parameter_array[1]
    vdwEOS.b = parameter_array[2]

    # setup the data -
    # get the PVT data -
    PcolName = Symbol("Pressure (MPa)")
    VcolName = Symbol("Volume (l/mol)")
    TcolName = Symbol("Temperature (K)")
    P_data_array = df[!,PcolName]
    V_data_array = df[!,VcolName]
    T_data_array = df[!,TcolName]

    # compute the model pressure array -
    P_model_array = evaluate_model(vdwEOS, df)

    # plot -
    semilogx(V_data_array*(1/Vc),P_data_array,"b",lw=2)
    semilogx(V_data_array*(1/Vc),P_model_array,"g--",lw=2)
    fig = gcf()
    ax = gca()
    ax.set_facecolor("#F5FCFF")
    fig.set_facecolor("#F5FCFF")

    # write -
    savefig("./vdw-Methane-210K.pdf", facecolor=fig.get_facecolor(), edgecolor="none")
end