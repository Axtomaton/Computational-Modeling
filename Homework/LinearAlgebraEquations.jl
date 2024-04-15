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
    m = size(L, 1)
    z = similar(b, Float64)  # Initialize z with the same size as b

    for i in 1:m
        z[i] = (b[i] - sum(L[i, 1:i-1] .* z[1:i-1])) / L[i, i]
    end

    return vec(z)
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
    # Swap the first two rows of P
    P[1, :], P[2, :] = P[2, :], P[1, :]
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
end




function main()

# L = [1 0 0; 
#     1 2 0; 
#     2 1 4]

# b = [2, 4, 8]
# println(forward_substitution(L, b))

A = [2 1 3;
    3 4 2;
    1 5 6]

P = swap_rows_1_2_matrix(A)
println(P * A) #LOOKS GOOD!!





end

main()
end ## end module
