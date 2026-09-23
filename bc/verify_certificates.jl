# Run: julia --project=. verify_certificates.jl
include(joinpath(@__DIR__, "BurnsideC.jl"))
using .BurnsideC, Oscar
const B = BurnsideC

# Theorem 5.2: include every [H,Y] class, even summands with trivial cokernel.
# Each block is exactly bn_quotient's original presentation, without elimination.
function presentation(st, n)
    rows = B.Row[]
    ncols = 0
    for h in st.hclasses, p in h.pairs
        ctx = B.CharCtx(h.d)
        perms = [B.char_perm(ctx, B._intmat(M)) for M in p[:mats]]
        cl = B.perm_closure(perms)
        block, width = B.bn_quotient(h.d, n, cl === nothing ? perms : cl;
                                     return_presentation=true)
        append!(rows, [B.Row(j + ncols => v for (j, v) in row) for row in block])
        ncols += width
    end
    return rows, ncols
end

# Plain integer arrays, exact arithmetic, and fraction-free Gaussian elimination.
# These verification routines do not call Nemo matrix multiplication/det/SNF.
function integer_det(M)
    a = BigInt[M[i,j] for i in 1:size(M,1), j in 1:size(M,2)]
    n = size(a, 1)
    @assert size(a, 2) == n
    n == 0 && return big(1)
    sign, previous = big(1), big(1)
    for k in 1:n-1
        pivot = findfirst(i -> a[i,k] != 0, k:n)
        pivot === nothing && return big(0)
        p = k + pivot - 1
        if p != k
            a[k,:], a[p,:] = copy(a[p,:]), copy(a[k,:])
            sign = -sign
        end
        for i in k+1:n, j in k+1:n
            value = a[k,k]*a[i,j] - a[i,k]*a[k,j]
            @assert rem(value, previous) == 0
            a[i,j] = div(value, previous)
        end
        previous = a[k,k]
        a[k+1:n,k] .= 0
    end
    return sign*a[n,n]
end

function checks(A, U, V, D)
    arrays = map(M -> BigInt[M[i,j] for i in 1:size(M,1), j in 1:size(M,2)], (A,U,V,D))
    a, u, v, d = arrays
    product = u*a*v == d
    du, dv = integer_det(U), integer_det(V)
    diagonal = all(i == j || iszero(D[i,j]) for i in 1:size(D,1), j in 1:size(D,2))
    diag = [abs(D[i,i]) for i in 1:min(size(D)...)]
    nz = filter(!iszero, diag)
    smith = diagonal && all(!iszero(diag[i]) for i in 1:length(nz)) &&
            all(iszero(rem(nz[i+1], nz[i])) for i in 1:length(nz)-1)
    return product, du, dv, smith, nz
end

# Complete, untruncated integer matrices, one row per line; empty sizes explicit.
function print_matrix(io, name, M)
    println(io, name, " (", size(M,1), " x ", size(M,2), ")")
    for i in 1:size(M,1)
        println(io, join([string(M[i,j]) for j in 1:size(M,2)], " "))
    end
end

open(joinpath(@__DIR__, "snf_certificates.txt"), "w") do io
    for (k, expected) in [(3, ab("Z/2")), (4, ab("(Z/2)^3"))]
        st = bc_structure(symmetric_group(k); name="S_$k")
        rows, ncols = presentation(st, 2)
        original = deepcopy(rows)
        A, U, V, D = certify_snf(rows, ncols)
        product, du, dv, smith, nz = checks(A, U, V, D)
        group = AbGroup(ncols-length(nz), [Int(x) for x in nz if x > 1])
        pipeline = bc(st, 2).total
        println("S_$k n=2: ", npairs(st), " [H,Y] blocks; A size = ", size(A))
        println("U*A*V == D (exact BigInt arithmetic): ", product)
        println("det(U) = ", du, "; abs(det(U)) == 1: ", abs(du) == 1)
        println("det(V) = ", dv, "; abs(det(V)) == 1: ", abs(dv) == 1)
        println("D diagonal, nonzero entries first, divisibility chain: ", smith)
        println("abs(nonzero diagonal entries) = ", nz)
        println("torsion factors = ", [x for x in nz if x > 1], "; free rank = ", group.free)
        println("certificate group = ", group, "; expected = ", expected, "; match: ", group == expected)
        println("bc(st, 2).total = ", pipeline, "; match: ", pipeline == group)
        println("input rows unchanged: ", rows == original)
        @assert product && abs(du) == abs(dv) == 1 && smith
        @assert group == expected == pipeline && rows == original
        println(io, "S_$k n=2; all ", npairs(st), " [H,Y] blocks")
        for (name, M) in zip(("A", "U", "V", "D"), (A, U, V, D))
            print_matrix(io, name, M)
        end
        println()
    end
end

# Rectangular, empty, zero-row, unused-column, negative, and nonunit examples.
for (rows, ncols) in [(B.Row[], 0), (B.Row[], 3), ([B.Row()], 0),
                      ([B.Row(), B.Row()], 3),
                      ([B.Row(1 => -6, 2 => 4)], 3),
                      ([B.Row(1 => 6), B.Row(2 => 10)], 2)]
    original = deepcopy(rows)
    A, U, V, D = certify_snf(rows, ncols)
    product, du, dv, smith, nz = checks(A, U, V, D)
    @assert product && abs(du) == abs(dv) == 1 && smith && rows == original
    @assert first(B.cokernel_group(deepcopy(rows), ncols)) ==
            AbGroup(ncols-length(nz), [Int(x) for x in nz if x > 1])
end
for (rows, ncols) in [(B.Row[], -1), ([B.Row(0 => 1)], 2), ([B.Row(3 => 1)], 2)]
    @assert try
        certify_snf(rows, ncols)
        false
    catch e
        e isa ArgumentError
    end
end
println("Edge cases: 6 certificates and 3 invalid-input checks passed")
println("Full A, U, V, D matrices saved to snf_certificates.txt")
