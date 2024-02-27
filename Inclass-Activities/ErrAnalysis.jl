function calc_exp(numIter)
    x = 3.0
    for i = 1:numIter
        x = (0.1 * x - 0.2) * 30.0
    end
    return x
end

function calc_exp2(numIter)
    x = 3.0
    for i = 1:numIter
        x = (3.0 * x - 6.0)
    end
    return x
end

function main()
    println(calc_exp(100))
    println(calc_exp(10))
    println(calc_exp2(10))   
    println(calc_exp2(100))   


end
main()