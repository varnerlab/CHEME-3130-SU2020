# SVNA 8th edition example 10.4
# H = 400x1 + 600x2 + x1 x2(40x1 + 20x2)

struct Model 
    # parameters -
    a::Float64
    b::Float64
    c::Float64
    d::Float64

    function Model(a,b,c,d)
        this = new(a,b,c,d)
    end
end

function estimate_H1_bar(model::Model,x1::Float64)::Float64

    # compute the H -
    H_model = evaluate_real_model(model,x1)

    # compute the slope -
    H_slope = compute_slope(model,x1)

    # compute H1bar -
    H1_bar = H_model + (1-x1)*H_slope

    # return -
    return H1_bar
end

function estimate_H2_bar(model::Model,x1::Float64)::Float64

    # compute the H -
    H_model = evaluate_real_model(model,x1)

    # compute the slope -
    H_slope = compute_slope(model,x1)

    # compute H1bar -
    H2_bar = H_model - x1*H_slope

    # return -
    return H2_bar
end

function compute_slope(model::Model,x1::Float64)

    # use a central difference -
    h = 0.01
    delta_x1_up = x1*(1+h)
    delta_x1_down = x1*(1-h)

    # compute the H function -
    H_up = evaluate_real_model(model,delta_x1_up)
    H_down = evaluate_real_model(model,delta_x1_down)

    # compute the derivative -
    return ((H_up - H_down)/(2*h*x1))
end


function build_model(a::Float64,b::Float64,c::Float64,d::Float64)::Model
    return Model(a,b,c,d)
end

function evaluate_real_model(model::Model, x1::Float64)::Float64

    # get parameters -
    a = model.a
    b = model.b
    c = model.c
    d = model.d

    # compute x2 (we are binary so x2 = 1-x1)
    x2 = 1-x1

    # terms -
    term_1 = a*x1
    term_2 = b*x2
    mixed_term = x1*x2*(c*x1+d*x2)

    # evaluate the H model -
    return (term_1 + term_2 + mixed_term)
end

function evaluate_ideal_model(model::Model, x1::Float64)::Float64
    
    # get parameters -
    a = model.a
    b = model.b

    # The ideal model is the first two terms -
    return (a*x1+b*(1-x1))
end