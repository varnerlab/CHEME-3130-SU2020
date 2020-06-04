function calculateCompressibility(data_table)

    # setup some constants -
    R = 8.314*(1/1000)      # L MPa K^-1 mol^-1
    T_index = 1             # T col index K
    P_index = 2             # P col index MPa
    v_index = 4             # v col index L/mol

    # what is the size of the data table?
    (number_of_rows,number_of_cols) = size(data_table)

    # compute the compressibility -
    Z_array = Float64[]
    P_array = Float64[]
    for row_index = 1:number_of_rows

        # get the T,P and v -
        T_value = data_table[row_index,T_index]
        P_value = data_table[row_index,P_index]
        v_value = data_table[row_index,v_index]

        # compute the Z -
        Z_value = (P_value*v_value)/(R*T_value)
    
        # store the Z and P -
        push!(Z_array,Z_value)
        push!(P_array,P_value)
    end

    # return the array of Z's back to the caller -
    return (Z_array,P_array)
end
