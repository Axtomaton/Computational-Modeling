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

function squares(num)
    i = 1
    
    while i <= num
        println("Square of $(i) is $(i * i)")
        i+=1
    end 
    println("I am done!")
end

function squares_for(num::Integer)
    for i = 1:num
        println("Square of $(i) is $(i * i)")
    end
end

function squares_lt(num::Integer)
    i = 1
    while i < num
        println("Square of $(i) is $(i*i)")
        i+=1
    end

end

##Fizz  Buzz
function fizzbuzz(num::Integer)
    for i=1:num
        if (i % 3 == 0) && (i % 5 == 0) 
            println("FizzBuzz")
        elseif (i % 3 == 0)
            println("Fizz")
        elseif (i % 5 == 0)
            println("Buzz")
        else
            println(i)
        end
    end
end
#=

=#
function squares_and(num::Integer)
    arr = Array{Int, 1}(undef, num) #1D array of num elements 
    for i=1:num
        arr[i] = i * i
        # push!(arr, i * i) #push into the array 
    end
    arr
end

function squares_arr2(num::Integer)
    [i * i for i = 1:num]
end



end

