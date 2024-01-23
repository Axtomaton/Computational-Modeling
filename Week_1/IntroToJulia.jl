module IntroToJulia

function is_divisible_by_2(num)
    return num % 2 == 0 
end

function my_add(x::Number, y::Number)
    x + y
end

function my_add(x::String, y::String)
    x * y
end

is_divisible_by_3(num) = (num % 3 == 0)

#using ;, anything afte r; is a keyword. Anything before is a parameter. If undefined its set to default value.
function my_plot_setting(;color="blue", 
                        linewidth="1pt",
                        linetype="dashed",
                        fillcolor="red")
    println("Plot settings\n")
    println("color = $(color), linewidth= $(linewidth), linetype = $(linetype), fillcolor = $(fillcolor)",)

end

my_plot_setting()

end