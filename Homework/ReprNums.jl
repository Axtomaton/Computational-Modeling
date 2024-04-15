##-------------------------------------------------------------------------
## Computational Economics Spring 2024
## Assignment 3: Representing numbers
##
## Imporant Instructions:
## 1. Don't change the module name or the filename.
## 2. Read the docstring before each function for what you need to do.
##    Read what the function is expected to return.
## 3. Don't change function name or signature.
## 4. Don't import any libraries not already imported.
##------------------------------------------------------------------------------
module ReprNums

##------------------------------------------------------------------------------
"""
1. Write a function for converting positive decimal integers to unsigned
binary numbers (that is, there is no sign-bit).

`posdecint` is the decimal integer that is to be converted to binary.

The return value, which is the binary number, should be an array of bits.

Hint: use the algorithm we discussed in the class.

Examples:
    pos_decint_to_bin(1) = [1]
    pos_decint_to_bin(2) = [1, 0]
    pos_decint_to_bin(100) = [1, 1, 0, 0, 1, 0, 0]
    pos_decint_to_bin(135) = [1, 0, 0, 0, 0, 1, 1, 1]
"""
function pos_decint_to_bin(posdecint)
    if posdecint == 0 ##Base Case
        return [0]
    end
    
    bits = Array{Int64,1}()
    while posdecint > 0 # While the number is greater than 0
        remainder = posdecint % 2
        push!(bits, remainder) #push the remainder to the array
        posdecint ÷= 2 # Divide by 2 to get to the next value
    end
    return reverse(bits)
end


##------------------------------------------------------------------------------
"""
2. Write a function for converting binary numbers to integers
Assume that there is no sign-bit.

`bitsarr` is the array of bits that represent the binary number.

Examples:
    pos_dec_to_bin([1,0]) = 2
    pos_dec_to_bin([1, 1, 0, 0, 1, 0, 0]) = 100
    pos_dec_to_bin([1, 0, 0, 0, 0, 1, 1, 1]) = 135
"""
function pos_bin_to_dec(bitsarr)
    n = length(bitsarr)
    highestpower = n - 1 #highest power of 2, last one is 2^0
    intVal = 0
    for i in 1:n #front indexes first left to right
        intVal += bitsarr[i] * 2^(highestpower)
        highestpower -= 1
    end
    return intVal
end


##------------------------------------------------------------------------------
"""
This is a function for adding to two binary numbers.
You don't have to modify it. It is something you can use
for implementing other functions in your assignment.

It takes two arrays of bits, and then performs binary 
addition, and returns the resulting binary number as an 
array of bits.
"""
function add_binary(bitarr1, bitarr2)
    n1 = length(bitarr1)
    n2 = length(bitarr2)
    n = max(n1, n2)

    ## pad the bit arrays with zeroes to make them equal length
    bitarr1 = vcat([0 for _ in 1:(n-n1)], bitarr1)
    bitarr2 = vcat([0 for _ in 1:(n-n2)], bitarr2)

    res = [0 for _ = 1:n]
    carry = 0
    for i = 0:(n - 1)
        b1 = bitarr1[end-i]
        b2 = bitarr2[end-i]
        carry, resbit = divrem(b1 + b2 + carry, 2)
        res[end-i] = resbit
    end
    if carry > 0
        res = vcat(carry, res)
    end
    res
end


##------------------------------------------------------------------------------
"""
3. Write a function for converting integers (both positive and negative) to
*signed* binary numbers. The first bit in the array must be the sign bit.
See the part "How can we represent negative numbers?" in Section 2
of the notes on representing numbers.

`int10` is the decimal integer that is to be converted to binary.
It can be positive or negative.

The resulting binary number should be an array of bits.

Hint: Use the add_binary function defined above to add 1 when converting
negative integers.

Examples:
    decint_to_bin(1) = [0, 1]
    decint_to_bin(10) = [0, 1, 0, 1, 0]
    decint_to_bin(100) = [0, 1, 1, 0, 0, 1, 0, 0]
    decint_to_bin(-1) = [1, 1]
    decint_to_bin(-37) = [1, 0, 1, 1, 0, 1, 1]

"""
function decint_to_bin(int10::Int)
    if int10 == 0
        return [0]  # Base case
    elseif int10 > 0 
        bin_num = Int[]
        while int10 > 0
            pushfirst!(bin_num, Int(mod(int10, 2)))
            int10 = div(int10, 2)
        end
        return vcat([0], bin_num)
    else # negative
        bin_num = Int[]
        int10 = abs(int10)
        while int10 > 0
            pushfirst!(bin_num, Int(mod(int10, 2)))
            int10 = div(int10, 2)
        end
        for i in eachindex(bin_num)
            bin_num[i] = 1 - bin_num[i]
        end
        bin_num[end] += 1
        if bin_num[end] == 2
            bin_num[end] = 0
            for i in length(bin_num)-1:-1:1
                if bin_num[i] == 1
                    bin_num[i] = 0
                else
                    bin_num[i] = 1
                    break
                end
            end
        end
        return vcat([1], bin_num)
    end
end



##------------------------------------------------------------------------------
"""
4. Write a function between that calculates the bits to the right of
the radix point for a given decimal number between 0 and 1 and returns these 
bits as an array.

The function shoud take two arguments, the decimal number and the number of bits
to be returned.

For example:
    frac_to_bin(0.25, 2) = [0, 1]
    (0.25 in decimal = 0.01 in binary. [0,1] are the bits to the right of the radix point).

    frac_to_bin(0.25, 4) = [0, 1, 0, 0]
    (0.25 in decimal = 0.01 in binary. [0,1] are the bits to the right of the radix point.
    Since we want 4 bits, we are filling the rest with zeroes)

    frac_to_bin(0.1, 13) = [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]
"""
function frac_to_bin(decnum::Float64, numbits)
    numbits = Int(numbits)
    bits = Array{Int}(undef, numbits)
    
    for i in 1:numbits
        decnum *= 2
        if decnum >= 1
            bits[i] = 1
            decnum -= 1
        else
            bits[i] = 0
        end
        if decnum == 0 || i == numbits
            break
        end
    end
    return bits
end






##------------------------------------------------------------------------------
"""
5. Assuming that the given bits array, `bitsarr` represents bits to the right of
the radix point, convert them to the fractional decimal number.

Examples:
    bin_to_decfrac([1,0]) = 0.5
    bin_to_decfrac([1, 1, 0, 0, 1, 0, 0]) = 0.78125
    bin_to_decfrac([1, 0, 0, 0, 0, 1, 1, 1]) = 0.52734375
"""
function bin_to_decfrac(bitsarr)
    numerator = 0
    for i in eachindex(bitsarr)
        numerator += bitsarr[i] * 2^-float(i)
    end
    
    return numerator
end

##------------------------------------------------------------------------------
"""
6. Write a function that returns fixed point representation 
as a *string* of a decimal number with a fractional part.

Assume that all numbers are positive and there is *no* sign bit.

Don't worry about overflow for the whole part. However, you may
have to pad the resulting binary with zeroes to make up the number of bits
specified in the variable `numbits_whole`

The function should take three arguments:
    - decimal number with possibly a fractional part (decnum)
    - number of bits to represent the whole number (numbits_whole)
    - number of bits to represent the fractional part (numbits_frac)

Hint 1: Use the pos_decint_to_bin function to convert the whole part (padding
the whole part with zeroes, if necessary to ensure that you have as many bits as numbits_whole).
Use the frac_to_bin function to convert the fractional part.
Combine the two array into a string separating them with radix point '.'

Hint 2: How to get the whole part and the fractional part of the decimal number `decnum`?
    You can use the `modf` function. The fractional part may not be exactly the same as
    the one in the input `decnum`, but you don't need to worry about it. The function
    `frac_to_bin` should work fine with it. Remeber to convert the whole part to an integer.


Examples:
    fixed_point_repr(10.5, 10, 20) = "0000001010.10000000000000000000"
    fixed_point_repr(0.1, 10, 20) = "0000000000.00011001100110011001"
    fixed_point_repr(35.63, 10, 20) = "0000100011.10100001010001111010"
"""
function fixed_point_repr(decnum, numbits_whole, numbits_frac)
    dec, whole = modf(decnum)
    binleft = pos_decint_to_bin(whole)
    left = zeros(Int, numbits_whole)

    count = 1
    for i in numbits_whole:-1:1
        if count > length(binleft)
            break
        end
        left[i] = binleft[count]
        count += 1
    end

    binright = frac_to_bin(dec, numbits_frac)
    left, right = join(string.(left), ""), join(string.(binright), "")
    return left * "." * right
end




"""
7. Write the code for finding all numbers (in the decimal system)
that can be exactly represented with fixed point representation
where 4 bits are allocated for the integral part and 3 bits are allocated for
the fractional part. The return value should be the sorted value 
of decimal numbers that can be represented.

Assume that there is no sign bit. We are considering only positive numbers.

Hint: start with finding all possible combinations of 0s and 1s you can form
for the whole part and the fractional part. Each combination corresponds to
a decimal number. Convert all these combinations to their corresponding decimal
value. The array of these decimal values should be the return value of this function.

Check: the array should have 128 elements.
"""
function all_nums_fixed_point_repr()
    decimal_values = Array{Float64}(undef, 0)
    for whole in 0:15  # 4 bits for the integral part (2^3 + 2^2 + 2^1 + 2^0 = 15)
        for frac in 0:7  # 3 bits for the fractional part (2^2 + 2^1 + 2^0 = 7)
            decimal_value = whole + frac / 8.0 #divide by 8 because 2^3 = 8
            push!(decimal_values, decimal_value)
        end
    end
    # println(length(decimal_values)) ##128 yup
    return sort(decimal_values)
end


"""
8. Write the code for finding all numbers (in the decimal system)
that can be exactly represented with floating point representation
where 4 bits are allocated for storing the biased exponent, where the bias = 7;
and 3-bits are allocated for the fractional part.

Assume that there is no sign bit. We are considering only positive numbers.

Like in the IEEE-754 system, treat the cases of 0000 and 1111 for the exponent as
special. For the case where exponent bits are 0000 and fractional part is not equal
to 000, the number represented is f_{10} \times 2^(-6). These are the denormalized numbers.

Hint: start with finding all possible combinations of 0s and 1s you can form
for the exponent and the fractional part. Each combination corresponds to
a decimal number. Convert all these combinations to their corresponding decimal
value. The array of these decimal values should be the return value of this function.

Remember to add the Inf and NaN values at the end. The return value should be 
an array of the decimal numbers that can be represented. 

Check: the array should have 122 elements.
"""
function all_nums_floating_point_repr()
    decimal_values = Array{Float64}(undef, 0)
    
    for frac in 1:7  # Fraction cannot be zero
        decimal_value = frac / 8.0 * 2.0^float(-6) #divide by 8 because 2^3 = 8 and 2^(-6) = 1/64
        push!(decimal_values, decimal_value)
    end
    
    # Normalized numbers
    for exp in 1:14  # Exponent cannot be zero or all ones
        for frac in 0:7
            decimal_value = (frac / 8.0 + 1) * 2.0^float(exp - 7)
            push!(decimal_values, decimal_value)
        end
    end
    
    # Exponent = 0, fraction = 0 represents zero
    push!(decimal_values, 0.0)
    # Exponent = 15, fraction = 0 represents Inf
    push!(decimal_values, Inf)
    push!(decimal_values, NaN)
    
    # println(length(unique(decimal_values))) ##122 yup
    return sort(unique(decimal_values))
end

function main()
    #LOOKS GOOD
    # println(pos_decint_to_bin(1))
    # println(pos_decint_to_bin(2))  #[1, 0]
    # println(pos_decint_to_bin(100))  #[1, 1, 0, 0, 1, 0, 0]
    # println(pos_decint_to_bin(135))  #[1, 0, 0, 0, 0, 1, 1, 1]
    
    #LOOKS GOOD
    # println(pos_bin_to_dec([1,0])) # 2
    # println(pos_bin_to_dec([1, 1, 0, 0, 1, 0, 0]))  # 100
    # println(pos_bin_to_dec([1, 0, 0, 0, 0, 1, 1, 1]))  # 135

    #LOOKS GOOD
    # println(decint_to_bin(1)) # [0, 1]
    # println(decint_to_bin(10)) # [0, 1, 0, 1, 0]
    # println(decint_to_bin(100)) # [0, 1, 1, 0, 0, 1, 0, 0]
    # println(decint_to_bin(-1)) # [1, 1]
    # println(decint_to_bin(-37)) # [1, 0, 1, 1, 0, 1, 1]

    #LOOKS GOOD
    #println(frac_to_bin(0.25, 2)) # [0, 1]
    #println(frac_to_bin(0.25, 4)) # [0, 1, 0, 0]
    #println(frac_to_bin(0.1, 13)) # [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]

    ##LOOKS GOOD
    # println(bin_to_decfrac([1,0])) # 0.5
    # println(bin_to_decfrac([1, 1, 0, 0, 1, 0, 0])) # 0.78125
    # println(bin_to_decfrac([1, 0, 0, 0, 0, 1, 1, 1])) # 0.52734375
    
    ##LOOKS GOOD
    # println(fixed_point_repr(10.5, 10, 20)) #"0000001010.10000000000000000000"
    # println(fixed_point_repr(0.1, 10, 20))  #"0000000000.00011001100110011001"
    # println(fixed_point_repr(35.63, 10, 20)) #"0000100011.10100001010001111010"

    #LOOKS GOOD
    # println(all_nums_fixed_point_repr())
    #LOOKS GOOD 
    # println(all_nums_floating_point_repr())

    ##NEED TO FIX   
    # println(fixed_point_repr(53.24, 10, 8)) #0000101011.00111101
    # println(fixed_point_repr(12.56, 12, 12)) #000000000011.100011110101
    # println(fixed_point_repr(0.1, 10, 20)) #0000000000.00011001100110011001
    # # println(fixed_point_repr(10.5, 10, 20)) #0000000101.10000000000000000000
    # println(frac_to_bin(0.77, 12.0)) # [1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1]
    # println(frac_to_bin(0.25, 2.0)) # [0, 1]
    # println(frac_to_bin(0.25, 4.0)) # [0, 1, 0, 0]
    # println(frac_to_bin(0.1, 13.0)) # [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]
    # println(frac_to_bin(0.45, 8.0)) # [0, 1, 1, 1, 0, 0, 1, 1]
    # println(frac_to_bin(0.77, 12.0)) # [1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1]

    #good
    println(decint_to_bin(-2))
    println(decint_to_bin(-37))
    println(decint_to_bin(2))
    println(decint_to_bin(1))
    println(decint_to_bin(100)) 


end
main()

end ## end module