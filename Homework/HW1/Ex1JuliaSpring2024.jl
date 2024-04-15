##-------------------------------------------------------------------------
## Computational Economics Spring 2023
## Assignment 1: Basics of Julia
##
## Imporant Instructions:
## 1. Don't change the module name or the filename.
## 2. Read the docstring before each function for what you need to do.
## 3. Don't change function name or signature.
## 4. You should not import any packages other than those already imported.
##-------------------------------------------------------------------------
module Ex1JuliaSpring2024

import Random

##-------------------------------------------------------------------------
"""
    freqdist(iter)

Write a function `freqdist` that takes an
iterable and returns a dictionary that shows the frequency count of each
value in the iterable. 

For example:

    freqdist([5, 1, 5, 3, 5, 2, 6, 2, 2, 5]) = 
        Dict(1 => 1, 2 => 3, 3 => 1, 5 => 4, 6 => 1)

    freqdist("hello world") = Dict('w' => 1, 'h' => 1, 'd' => 1, 'l' => 3,
                    'e' => 1, 'r' => 1, 'o' => 2, ' ' => 1)

    Key-value pairs in dictionaries are not ordered. So your output may not
    exactly match the above. What is important is that all the keys are present,
    and they have the correct value.
"""
function freqdist(iter)
    dict = Dict{Char, Integer}()
    for item in iter
        haskey(dict, item) ? dict[item] +=1 : (dict[item] = 1)
    end
    return dict
end

##-------------------------------------------------------------------------
"""
    has_duplicates(arr)

Write a function called `has_duplicates` that takes an array and returns true if
there is any element that appears more than once. It should not modify the
original array. 

Example: 
    
    has_duplicates([10, 15, 5, 8]) ## should return false.
    has_duplicates([8, 9, 4, 9, 10]) ## should return true.
"""
function has_duplicates(arr)
    return (length(Set(arr)) != length(arr)) #if the set which contains unique value is not the same size as arr, it has a dup.
end

##-------------------------------------------------------------------------
"""
    prob_same_bday(numpeople)

Write a function `prob_same_bday` that takes the
number of people in a group, `numpeople`,
as an argument and uses *simulation* to calculate the probability that any two
or more people have the same birthday.

Assume that there are only 365 days in the year (assume leap years do not exist),
and anyone in the group has a birthday on one of these 365 days.

To use *simulation*, do the following 
(I will use `numpeople` = 25 in this example, but your code should work 
for other values of `numpeople`. Your functions should not depend on value of 25, 
but should instead use `numpeople`).:
0. Create a variable `samebday` and initialize it to zero.
1. Generate a random sample of 25 numbers (because `numpeople` = 25 in this example)
   from 1 through 365. Each number represents a person's birthday. 
   Hint: Look up the `rand` function to draw a random sample of integers 
   from a given range.
2. If any two numbers in the sample of 25 numbers is the same, increase 
   `samebday` by 1.  
3. Repeat steps 1 and 2 for 5000 times.
4. The probability is given by `samebday`/5000.
   Your function should return this value.

Example: 
    prob_same_bday(5) = 0.0222
    prob_same_bday(25) = 0.56

"""
function prob_same_bday(numpeople)
    Random.seed!(1)
    samebday = 0
    for rep = 1:5000
        arr = rand(1:365, numpeople)
        if length(arr) != length(Set(arr)) #we have a dup since set contains all the unique vals.
            samebday += 1
        end
    end
    return samebday / 5000
end

##-------------------------------------------------------------------------
"""
    sort_tuples(arr_tuples, idx)

Write a function sort_tuples(arr_tuples) that takes an array of tuples 
and sorts them in the ascending order, by the value in position `idx` in the tuple.

Examples:

    sort_tuples([(2,5), (3,4), (3,6), (1,6)], 1) 
    ## returns [(1, 6), (2, 5), (3, 4), (3, 6)]

    sort_tuples([(2,5), (3,4), (3,6), (1,6)], 2) 
    ## returns [(3, 4), (2, 5), (3, 6), (1, 6)]

    sort_tuples([(35, 60, 'c'), (31, 96, 'h'), (2, 25, 'd'), (17, 75, 'a')], 3)
    ## returns [(17, 75, 'a'), (35, 60, 'c'), (2, 25, 'd'), (31, 96, 'h')]
"""
function sort_tuples(arr_tuples, idx)
    return sort!(arr_tuples, by = e -> e[idx]) #sort based on idx
end


##-------------------------------------------------------------------------
"""
    simpsons(f, a, b, n)

Calculate integral of function `f` (should be a function of one variable) 
between `a` and `b` (a < b) using the Simpson's rule. 

Parameter `n` is an *even* integer - higher the `n` the better is the approximation 
of the integral.

(This exercise is taken from SICP, although the goal there and here is 
different.)

Given `f`, `a`, `b`, `n`, the function should return the value: 

    h/3 * (y_{0} + 4*y_{1} + 2*y_{2} + 4*y_{3} + 2*y_{4} + ... + 4*y_{n-1} + y_{n})

    where, h = (b - a)/n and y_{k} = f(a + k*h)

Example:

    simpsons(x -> x^2, 0, 2, 100) ## 2.666666666666667
    simpsons(x -> x^2, 0, 2, 1000) ## 2.666666666666665
"""
function simpsons(f, a, b, n)
    #f: function 
    h = (b - a) /n  
    # 2, 4, 2, 4,
    val = 0 
    #1,4,2,4,2,4,2,.... 1
    for i=1:n-1
        val += (i*2 % 4 == 2) ? 4 *f(a + i*h) : 2 *f(a + i*h) 
    end
    
    return (h/3 * (f(a + 0*h) + f(a + n*h) + val))

end

function calculate_y_(func, val)
    return 
end

##-------------------------------------------------------------------------
"""
Write a function that takes a letter and an array of words as an argument 
and count the number of words in the list which have that letter.  

Examples: 
    When wordlist = list of words in wordlist_lawler.txt as the wordlist
    you should get the following output:

	numwords_with_letter('a', wordlist) ## 40387
	numwords_with_letter('e', wordlist) ## 44524
"""
function numwords_with_letter(letter, wordlist)
    count = 0
    open(wordlist, "r") do fp
        while !eof(fp)
            line = readline(fp)
            # println(line)\
            occursin(string(letter), line) ? count += 1 : continue
        end
    end
    return count
end


##-------------------------------------------------------------------------
"""
Write a function that takes a letter, a position, and an array of words
(called wordlist) as an argument. The function should count the 
number of words in `wordlist` which have the `letter` in position `position`.

Examples: 
    When wordlist = list of words in wordlist_lawler.txt as the wordlist
    you should get the following output:

	numwords_with_letter_in_position('a', 1) ## 5583
	numwords_with_letter_in_position('q', 6) ## 78
"""
function numwords_with_letter_in_position(letter, position, wordlist)
    count = 0
    open(wordlist, "r") do fp
        while !eof(fp)
            line = readline(fp)
            # word = []{String}
            if (length(line) < position) ##If the position value is greater than the word, skips it to avoid the error. Was made b/c of whitespace at end of file
                continue
            end 
            line[position] == letter ? count+=1 : continue
            
        end
    end
    return count
end

##-------------------------------------------------------------------------
"""
Write a function that returns a 
dictionary with letters 'a' to 'z' as keys, and for each letter 
the number of words containing the letter as value using the argument 
`wordlist` (where `wordlist` is an array of words). 

If `wordlist` equals the list of words in wordlist_lawler.txt, 
the output should be a Dictionary with entries like the following. 
There will be more entries than shown here, and your order may not match 
the one shown below.

Dict(
	'n' => 32952
	'f' => 6917
	'w' => 4185
	'd' => 18507	
)

"""
function numwords_each_letter(wordlist)
    dict = Dict{Char, Integer}()
    open(wordlist, "r") do fp
        while !eof(fp)
            line = readline(fp)
            for values in Set{Char}(line)
                haskey(dict, values) ? dict[values] +=1 : (dict[values] = 1)
            end
        end
    end
    return dict
end

##TESTING

function main()
    # println(freqdist("hello world")) ##WORKS
    # has_duplicates([10, 15, 5, 8]) ## should return false. ##WORKS
    # has_duplicates([8, 9, 4, 9, 10]) ## should return true. ##WORKS
    # println(has_duplicates([10, 15, 5, 8])) ##WORKS
    # println(has_duplicates([8, 9, 4, 9, 10])) ##WORKS
    # println(prob_same_bday(5)) ##WORKS
    # println(prob_same_bday(25)) ##WORKS
    # println(sort_tuples([(35, 60, 'c'), (31, 96, 'h'), (2, 25, 'd'), (17, 75, 'a')], 3)) ##WORKS
    # println(numwords_with_letter('a', "ECON411/Homework/HW1/wordlist_lawler.txt")) ##WORKS
    # println(numwords_with_letter('e', "ECON411/Homework/HW1/wordlist_lawler.txt")) ##WORKS

    # println(numwords_with_letter_in_position('a', 1, "ECON411/Homework/HW1/wordlist_lawler.txt")) ##WORKS
    # println(numwords_each_letter("ECON411/Homework/HW1/wordlist_lawler.txt")) ##WORKS
    # println(simpsons(x -> x^2, 0, 2, 100))
    # println(simpsons(x -> x^2, 0, 2, 1000))



end

main()


end ## end module