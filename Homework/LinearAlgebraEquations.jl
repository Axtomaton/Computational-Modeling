##-------------------------------------------------------------------------
## Computational Economics Spring 2024
## Assignment 5: Linear Algebra and Equations
##
## Imporant Instructions:
## 1. Don't change the module name or the filename.
## 2. Read the docstring before each function for what you need to do.
## 3. Don't change function name or signature.
##------------------------------------------------------------------------------
module LinearAlgebraEquations

import LinearAlgebra as LA

##------------------------------------------------------------------------------
"""
1.  Implement the forward substitution algorithm described in the notes to
    solve a lower-triangular system of equations.

    Given a lower triangular matrix L (assume non-zero diagonal elements) of
    dimension m x m, and a vector b of dimension m x 1 your code should return
    the solution as a one dimensional vector.

    Note, you *cannot* use any of the Julia functions or libraries to obtain
    the solution vector. You have to use the forward substitution algorithm 
    from the notes.

    Inputs are L and b where Lz = b.
    The output should be the vector which represents z.

    Example:
        L = [1  0  0
             1  2  0
             2  1  4];
        b = [2,
             4,
             8]
        Should return vector z = [2.0, 
                                  1.0, 
                                  1.75 ]
"""
function forward_substitution(L, b)
    m = size(L, 1) # Get the number of rows of L 
    z = similar(b, Float64)  # Initialize z with the same size as b and type Float64

    for i in 1:m # Loop through the rows of L
        z[i] = (b[i] - sum(L[i, 1:i-1] .* z[1:i-1])) / L[i, i] # Calculate z[i]
    end

    return vec(z) # Return z as a one-dimensional vector
end



##------------------------------------------------------------------------------
"""
2.  Given a matrix m x m matrix A, return a matrix, say P, such that P * A swaps
    first two rows of A.

    Example: If A = [2 1 3;
                     3 4 2;
                     1 5 6]

             P * A = [3 4 2;
                      2 1 3;
                      1 5 6]

    Note, the function should work for A of different sizes (not only 3 x 3 matrices).
    You can assume that A has at least two rows.

    Return value should be the matrix P.
"""
function swap_rows_1_2_matrix(A)
    m, n = size(A) #num of rows and columns from matrix A
    P = Matrix{typeof(A[1, 1])}(LA.I, m, n)  # Create an identity matrix of size m x m
    P[1, :], P[2, :] = P[2, :], P[1, :] #     # Swap the first two rows of P
    return P
end





##------------------------------------------------------------------------------
"""
3.  Given a matrix m x m matrix A, return matrices
        L1, L2, ..., L(m-1)
    discussed in the the algorithm in Figure 3 of the notes.
    Premultiplying A by L(m-1) * ... * L2 * L1 should give an upper triangular matrix.
    Do not worry about carrying out pivoting.

    *Return value* should be array of L matrices [L1, L2, ..., L(m-1)]

    Example: If
    A = [ 26.0  22.0  15.0
          22.0  19.0  13.0
          15.0  13.0   9.0]
    The result should be:
    [
     [1.0 0.0 0.0; -0.8461538461538461 1.0 0.0; -0.5769230769230769 0.0 1.0],
     [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 -0.8000000000000046 1.0]
    ]


    Note, the function should work for A of different sizes (not only 3 x 3 matrices).
    You can assume that A has at least two rows.
"""
function calc_L1L2matrices(A)
    m = size(A, 1)
    lower_matrix = Vector{Array{Float64, 2}}()

    for k in 1:m-1
        L = Matrix{Float64}(LA.I, m, m)  # init L as an identity matrix
        for i in k+1:m
            multiplier = A[i,k] / A[k,k]
            L[i,k] = -multiplier  # Update the lower triangular part of L
            A[i,:] .-= multiplier .* A[k, :]  # apply the transformation to A
        end
        push!(lower_matrix, copy(L)) # append L to the list of lower triangular matrices
    end
    return lower_matrix
end



##------------------------------------------------------------------------------
"""
4.  Write a function that performs Cholesky decomposition of matrix A
    and **returns the lower triangular matrix L**, such that
    A = L * transpose(L).
    You can assume that the input matrix A is a
    symmetric positive definite matrix.
"""
function cholesky_decomposition(A)
    return LA.cholesky(A).L #use built in function
end



##------------------------------------------------------------------------------
"""
5.  Write a function that performs QR factorization of matrix A
    Return a tuple where the first matrix is
    Q - the orthogonal matrix as defined in the notes, and the second matrix is
    R - an upper triangular matrix.

    For a couple of examples check that Q * R = A
    
    Return value should be a tuple (Q, R) where Q is a matrix 
    with the same dimensions as matrix A and R is an upper 
    triangular matrix.
"""
function qrfactorization(A)
    Q, R = LA.qr(A) #use built in function
    return Q, R #return Q and R as a tuple
end


##------------------------------------------------------------------------------
"""
6.  See the attached PDF file for this problem. This is an application from
    Industrial organization/Game Theory.

    Return value should be an array of equilibrium quantities.

    Example:
    1. For R = 100, b = 3, costvec = [40,40]
       expected output: [6.666666666666666, 6.666666666666667]

    2. For R = 100, b = 3, costvec = [30,40]
       expected output = [8.888888888888888, 5.555555555555556]
"""
function cournot_equilibrium(R, b, costvec)
    n = length(costvec) # firms
    A = zeros(Float64, n, n) # populate coefficient matrix
    c = zeros(Float64, n) # vector of constants

    for i in 1:n
        for j in 1:n
            if i == j
                A[i,j] = 2.0
            else
                A[i,j] = 1.0
            end
        end
        c[i] = (Float64(R) - Float64(costvec[i])) / Float64(b)
    end

    q = A \ c

    return q
end


function main()

# L = [1 0 0; 
#     1 2 0; 
#     2 1 4]

# b = [2, 4, 8]
# println(forward_substitution(L, b)) #LOOKS GOOD!!

#QUESTION 2 
# A = [2 1 3;
#     3 4 2;
#     1 5 6]

# P = swap_rows_1_2_matrix(A)
# println(P * A) #LOOKS GOOD!!

#QUESTION 3
# A = [ 26.0  22.0  15.0
#           22.0  19.0  13.0
#           15.0  13.0   9.0]

# println(calc_L1L2matrices(A))
# LOOKS GOOD!

#QUESTION 4
# A = [10.0 3.0 4.0;
#      3.0 10.0 5.0;
#      4.0 5.0 13.0]
    
# decomp = cholesky_decomposition(A)
# println(decomp)


#QUESTION 5
# Define a matrix A
A = [1.0 2.0 3.0;
     4.0 5.0 6.0;
     7.0 8.0 9.0]

# Perform QR factorization
Q, R = qrfactorization(A) 

# Check if Q * R equals A
println(Q * R ≈ A)  # Should return true for equality 

#QUESTION 6
# println(cournot_equilibrium(100, 3, [40, 40])) #YES
# println(cournot_equilibrium(100, 3, [30, 40])) #YES

end

# main()
end ## end module
