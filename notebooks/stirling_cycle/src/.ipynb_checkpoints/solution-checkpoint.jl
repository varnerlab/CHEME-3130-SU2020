# include my includes -
include("Include.jl")

# load my state table -
function load_state_table(path_to_state_table::String)::DataFrame

    # load the state file -
    return CSV.read(path_to_state_table)
end

# load my constants -
function load_constants_dictionary(path_to_constants_file::String)::Dict{String,Any}
    return JSON.parsefile(path_to_constants_file)
end

# initialize empty path table -
function initialize_empty_path_table()::DataFrame

    # setup -
    path = ["1 -> 2","2 -> 3","3 -> 4","4 -> 1", "cycle"]
    Q = zeros(5)
    W = zeros(5)
    delta_U = zeros(5)
    delta_H = zeros(5)
    delta_S = zeros(5)

    # path table -
    path_table = DataFrame(path=path,Q=Q,W=W,delta_U=delta_U,delta_H=delta_H,delta_S=delta_S)

    # return -
    return path_table
end

# compute delta_U -
function compute_delta_U(stateTable::DataFrame, pathTable::DataFrame, constants::Dict{String,Any})::DataFrame

    # get some constants -
    Cv = constants["Cv"]

    # calcs -
    T1 = stateTable[!,:T][1]
    T2 = stateTable[!,:T][2]
    𝝙U_12 = Cv*(T2-T1)

    T2 = stateTable[!,:T][2]
    T3 = stateTable[!,:T][3]
    𝝙U_23 = Cv*(T3-T2)

    T3 = stateTable[!,:T][3]
    T4 = stateTable[!,:T][4]
    𝝙U_34 = Cv*(T4-T3)

    T4 = stateTable[!,:T][4]
    T1 = stateTable[!,:T][1]
    𝝙U_41 = Cv*(T1-T4)

    # put into the data frame -
    pathTable[!,:delta_U][1] = 𝝙U_12
    pathTable[!,:delta_U][2] = 𝝙U_23
    pathTable[!,:delta_U][3] = 𝝙U_34
    pathTable[!,:delta_U][4] = 𝝙U_41

    # return -
    return pathTable
end

# compute delta_H -
function compute_delta_H(stateTable::DataFrame, pathTable::DataFrame, constants::Dict{String,Any})::DataFrame

    # get some constants -
    Cp = constants["Cp"]

    # calcs -
    T1 = stateTable[!,:T][1]
    T2 = stateTable[!,:T][2]
    𝝙H_12 = Cp*(T2-T1)

    T2 = stateTable[!,:T][2]
    T3 = stateTable[!,:T][3]
    𝝙H_23 = Cp*(T3-T2)

    T3 = stateTable[!,:T][3]
    T4 = stateTable[!,:T][4]
    𝝙H_34 = Cp*(T4-T3)

    T4 = stateTable[!,:T][4]
    T1 = stateTable[!,:T][1]
    𝝙H_41 = Cp*(T1-T4)

    # put into the data frame -
    pathTable[!,:delta_H][1] = 𝝙H_12
    pathTable[!,:delta_H][2] = 𝝙H_23
    pathTable[!,:delta_H][3] = 𝝙H_34
    pathTable[!,:delta_H][4] = 𝝙H_41

    # return -
    return pathTable
end

# compute delta_S -
function compute_delta_S(stateTable::DataFrame, pathTable::DataFrame, constants::Dict{String,Any})::DataFrame

    # get constants -
    Cv = constants["Cv"]
    Rhat = constants["Rhat"]

    # for the isothermal paths, Q/T -or- Rhat*T*log(Vf/Vi)
    # for the constant volume paths, dS = (Cv/T)*dT

    # Path 1 -> 2 (isothermal)
    V1 = stateTable[!,:V][1]
    V2 = stateTable[!,:V][2]
    T1 = stateTable[!,:T][1]
    𝝙S12 = Rhat*T1*log(V2/V1)

    # Path 2 -> 3 (constant volume)
    T2 = stateTable[!,:T][2]
    T3 = stateTable[!,:T][3]
    𝝙S23 = Cv*log(T3/T2)

    # Path 3 -> 4 (isothermal)
    V3 = stateTable[!,:V][3]
    V4 = stateTable[!,:V][4]
    T3 = stateTable[!,:T][3]
    𝝙S34 = Rhat*T3*log(V4/V3)

    # Path 4 -> 1 (constant volume)
    T4 = stateTable[!,:T][4]
    T1 = stateTable[!,:T][1]
    𝝙S41 = Cv*log(T1/T4)

    # update the path table -
    pathTable[!,:delta_S][1] = 𝝙S12
    pathTable[!,:delta_S][2] = 𝝙S23
    pathTable[!,:delta_S][3] = 𝝙S34
    pathTable[!,:delta_S][4] = 𝝙S41

    # return -
    return pathTable
end

function compute_W(stateTable::DataFrame, pathTable::DataFrame, constants::Dict{String,Any})::DataFrame

    # get constants -
    Rhat = constants["Rhat"]

    # we know the constant volume paths give no work, so we won't calc those
    # isothermal paths -

    # Path 1-> 2
    V1 = stateTable[!,:V][1]
    V2 = stateTable[!,:V][2]
    T1 = stateTable[!,:T][1]
    W12 = -Rhat*T1*log(V2/V1)

    # Path 3 -> 4
    V3 = stateTable[!,:V][3]
    V4 = stateTable[!,:V][4]
    T3 = stateTable[!,:T][3]
    W34 = -Rhat*T3*log(V4/V3)

    # update the path table -
    pathTable[!,:W][1] = W12
    pathTable[!,:W][3] = W34

    # return -
    return pathTable
end

function compute_Q(stateTable::DataFrame, pathTable::DataFrame, constants::Dict{String,Any})::DataFrame

    # get constants -
    Rhat = constants["Rhat"]
    Cv = constants["Cv"]

    # for the constant volume paths, we have Q = Cv*𝝙T 
    # for the isothermal paths, we have Q = Rhat*T*ln(Vf/Vi)

    # Path 1 -> 2 (isothermal)
    V1 = stateTable[!,:V][1]
    V2 = stateTable[!,:V][2]
    T1 = stateTable[!,:T][1]
    Q12 = Rhat*T1*log(V2/V1)

    # Path 2 -> 3 (constant volume) 
    T2 = stateTable[!,:T][2]
    T3 = stateTable[!,:T][3]
    Q23 = Cv*(T3-T2)

    # Path 3 -> 4 (isothermal)
    V3 = stateTable[!,:V][3]
    V4 = stateTable[!,:V][4]
    T3 = stateTable[!,:T][3]
    Q34 = Rhat*T3*log(V4/V3)

    # Path 4 -> 1 (constant volume) 
    T4 = stateTable[!,:T][4]
    T1 = stateTable[!,:T][1]
    Q41 = Cv*(T1-T4)

    # update the path table -
    pathTable[!,:Q][1] = Q12
    pathTable[!,:Q][2] = Q23
    pathTable[!,:Q][3] = Q34
    pathTable[!,:Q][4] = Q41

    # return -
    return pathTable
end

function compute_full_path_table(stateTable::DataFrame,constants::Dict{String,Any})::DataFrame

    # initialize empty path table -
    pt = initialize_empty_path_table()

    # compute each of the cols -
    pt = compute_Q(stateTable,pt,constants)
    pt = compute_W(stateTable,pt,constants)
    pt = compute_delta_U(stateTable,pt,constants)
    pt = compute_delta_H(stateTable,pt,constants)
    pt = compute_delta_S(stateTable,pt,constants)

    # return -
    return pt
end