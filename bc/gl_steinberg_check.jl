#=
Independent check that B_n(F_2^n) = (Z/2)^(2^(n(n-1)/2)) is the Steinberg module of GL_n(F_2),
for n = 3 and n = 4.

Route (deliberately different from gl_action.jl, no tracked elimination, no Smith form of
the action): B_n(F_2^n) is an elementary abelian 2-group, so it equals F_2^N / (relation rows
mod 2), N = number of generating tuples. GL_n(F_2) permutes the N tuples (via B.char_perm
on the contragredient matrices) and the relation subspace must be invariant. We build the
quotient module with GAP's MeatAxe. Irreducibility, dimension and composition factors depend
only on the matrix group generated, so they do not depend on the hom versus anti-hom
convention. Identification with Steinberg uses the Brauer character: on odd-order (2-regular)
elements g, |St(g)| = 2-part of |C_G(g)|, and we also compare with n=3 values 8, -1, 1.
=#
include("BurnsideC.jl")
using .BurnsideC, Oscar
const B = BurnsideC

matrows(A) = [[Int(A[i,j]) for j in 1:size(A,2)] for i in 1:size(A,1)]
gapmat(A) = "[" * join(("[" * join(row, ",") * "]" for row in matrows(A)), ",") * "]*Z(2)^0"

function genmats(r)
    T = [i==j ? 1 : 0 for i in 1:r, j in 1:r]; T[1,2] = 1                         # transvection I + E12
    C = zeros(Int, r, r); for i in 1:r; C[mod1(i+1,r), i] = 1; end  # cyclic permutation matrix
    S = [i==j ? 1 : 0 for i in 1:r, j in 1:r]; S[1,1]=0; S[2,2]=0; S[1,2]=1; S[2,1]=1  # swap of coordinates 1,2
    return [T, C, S]
end

gap_src = raw"""
BCStein := function(Ps, Rel, r)
    local M, W, P, w, ok, Q, G, facs, vals, cl, c, g, o, cen, twopart;
    M := GModuleByMats(Ps, GF(2));
    W := Rel;
    ok := true;
    for P in Ps do
        if RankMat(Concatenation(W, W*P)) <> RankMat(W) then ok := false; fi;
    od;
    Q := MTX.InducedActionFactorModule(M, W);
    G := Group(MTX.Generators(Q));
    facs := MTX.CompositionFactors(Q);
    vals := [];
    for c in ConjugacyClasses(G) do
        g := Representative(c);
        o := Order(g);
        if o mod 2 = 1 then
            cen := Size(Centralizer(G, g));
            twopart := 2^PadicValuation(cen, 2);
            Add(vals, [o, Int(BrauerCharacterValue(g)), twopart]);
        fi;
    od;
    return rec(
        relation_space_invariant := ok,
        quotient_dim := MTX.Dimension(Q),
        irreducible := MTX.IsIrreducible(Q),
        absolutely_irreducible := MTX.IsAbsolutelyIrreducible(Q),
        factor_dims := List(facs, MTX.Dimension),
        image_group_order := Size(G),
        odd_classes_order_brauer_2partOfCentralizer := vals
    );
end;;
"""
GAP.evalstr(gap_src)

for r in (3, 4)
    println("=========== r = n = $r ===========")
    n = r
    ctx = B.CharCtx(fill(2, r))
    gens = [ms for ms in B.multisets(ctx.m, n) if B.generates_all(ctx, ms)]
    rows, N = B.bn_quotient(fill(2, r), n, Vector{Int}[]; return_presentation=true)
    @assert N == length(gens)
    col = Dict(g => i for (i,g) in enumerate(gens))
    println("N (generating tuples) = ", N, "   relation rows = ", length(rows))
    rel = zeros(Int, length(rows), N)
    for (i,row) in enumerate(rows), (j,v) in row
        rel[i,j] = mod(v, 2)
    end
    Rm = matrix(GF(2), rel)
    rk, Rr = rref(Rm)
    println("rank of relations mod 2 = ", rk, "  => quotient dimension should be ", N - rk)
    Rbasis = [[Int(lift(ZZ, Rr[i,j])) for j in 1:N] for i in 1:rk]
    Ts = genmats(r)
    println("order of <T,C,S> in GL($r,2) = ",
            GAP.evalstr("Size(Group(" * join(gapmat.(Ts), ",") * "))"),
            "   |GL($r,2)| = ", GAP.evalstr("Size(GL($r,2))"))
    perms = Matrix{Int}[]
    for A in Ts
        af = matrix(GF(2), A)
        cm = [Int(lift(ZZ, transpose(inv(af))[i,j])) for i in 1:r, j in 1:r]
        perm = B.char_perm(ctx, cm)
        tp = [col[sort(perm[g])] for g in gens]
        P = zeros(Int, N, N)
        for i in 1:N; P[i, tp[i]] = 1; end
        push!(perms, P)
    end
    psgap = GAP.evalstr("[" * join(gapmat.(perms), ",") * "]")
    relgap = GAP.evalstr(gapmat(reduce(vcat, (reshape(row, 1, :) for row in Rbasis))))
    t = @elapsed res = GAP.gap_to_julia(GAP.Globals.BCStein(psgap, relgap, r); recursive=true)
    for (k,v) in sort(collect(res); by = x -> string(x[1]))
        println(k, " = ", v)
    end
    println("(MeatAxe+class analysis time: ", round(t, digits=2), "s)")
end
