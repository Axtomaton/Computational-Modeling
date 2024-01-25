module JuliaFun

function main()
    arr1 = [1, 2, 3]
    arr2 = [4, 5, 6]

    fout = vcat(arr1, arr2)
    println(fout)
    
end


function randomshit()
    arr1 = rand(1:20, 10) #10 numbers random 1 to 20
    println(sort(arr1))

    a = [(1, 2), (3, 10), (2, 6), (5, 1)]
    # sort(a)
    # println(a)

    sort(a, by = el -> el[2])
    println(a)
    # sort([1, -4, -2, 2, 0], by = abs)
    # sort([1, -4, -2, 2, 0], by = arg -> arg*arg)

    arr = [5 2; 3 1]
    sort(arr, dims = 1)
end

function dictionary()
    d1 = Dict{String, Int64}()
    d1["s1"] = 96
    d1["s2"] = 89
    d1["s1"] = 67
    println(d1)
end

function print_idx_value(arr)
    for (idx, el) in enumerate(arr)
        println("$(idx) - $(el)")
    end
end





end