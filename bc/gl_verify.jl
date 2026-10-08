#=
Independent check of the GL_2(F_p)-module structure of the top piece B_2(F_p^2), usage:
    julia --project=. gl_verify.jl 7      (default p = 7)
For p=7 this checks B_2(F_7^2) = (Z/14)^3 x Z^159.

Different route from gl_action_p7.jl / gl_classify_p7.jl:
 * the character of the free quotient is computed from the DEFINITION, as the trace of the
   action of one representative g of each conjugacy class (no BFS closure, no hom versus
   anti-hom bookkeeping: tr(action of g) does not depend on it for an integral character),
 * the torsion block of the action is computed directly for ALL elements of GL_2(F_p)
   and tested against the hypothesis that it depends only on det(g),
 * the splitting test (p <= 7 only) is a linear system over F_ell written independently,
   with the same mathematical formulation as the other script.
=#
include("BurnsideC.jl")
using .BurnsideC, Oscar
using LinearAlgebra: dot
const B = BurnsideC
include("gl_tracked_elimination.jl")

p = length(ARGS) > 0 ? parse(Int, ARGS[1]) : 7
primroot = first(a for a in 2:p-1 if length(unique(powermod(a,k,p) for k in 1:p-1)) == p-1)
println("p=$p primitive root = $primroot")

# ---------- presentation, tracked elimination, Smith form (same certified ingredients) ----------
ctx = B.CharCtx([p,p]); n = 2
gens = [ms for ms in B.multisets(ctx.m, n) if B.generates_all(ctx, ms)]
rows, N = B.bn_quotient([p,p], n, Vector{Int}[]; return_presentation=true)
@assert N == length(gens)
col = Dict(g => i for (i,g) in enumerate(gens))
E, J, M, survivors, trace = tracked_elimination(deepcopy(rows), N)
q = length(survivors)
D, U, V = nrows(M) == 0 ? (M, identity_matrix(ZZ,0), identity_matrix(ZZ,q)) : snf_with_transform(M)
diagonal = [j <= nrows(D) ? Int(D[j,j]) : 0 for j in 1:q]
keep = findall(d -> abs(d) != 1, diagonal)
moduli = diagonal[keep]
Vinv = inv(V)
Qz = (E*V)[:, keep]
Lz = (Vinv*J)[keep, :]
k = length(keep)
@assert Lz * Qz == identity_matrix(ZZ, k)   # quotient maps are mutually inverse on the target side
Lm = [Int(Lz[a,i]) for a in 1:k, i in 1:N]
Qm = [Int(Qz[i,a]) for i in 1:N, a in 1:k]
tors = findall(!=(0), moduli); free = findall(==(0), moduli)
println("N=$N  dim=$k  torsion moduli=", moduli[tors], "  free rank=", length(free))

function tp_of(g)
    af = matrix(GF(p), g)
    cm = [Int(lift(ZZ, transpose(inv(af))[i,j])) for i in 1:2, j in 1:2]
    perm = B.char_perm(ctx, cm)
    return [col[sort(perm[x])] for x in gens]
end
# R[a,b] = sum_i L[a,i] * Q[tp[i], b]   (row action on final coordinates)
function Rfull(tp)
    R = Lm * Qm[tp, :]
    for j in tors, i in 1:k
        R[i,j] = mod(R[i,j], moduli[j])
    end
    return R
end

# ---------- (1) torsion block for ALL elements of GL_2(F_p), dependence on det ----------
do_det = !(length(ARGS) > 1 && ARGS[2] == "nodet")
byDet = Dict{Int, Set{Matrix{Int}}}()
nel = 0
for a in 0:p-1, b in 0:p-1, c in 0:p-1, d in 0:p-1
    do_det || break
    dt = mod(a*d - b*c, p); dt == 0 && continue
    global nel += 1
    tp = tp_of([a b; c d])
    Rtt = Lm[tors, :] * Qm[tp, tors]
    for j in eachindex(tors), i in eachindex(tors)
        Rtt[i,j] = mod(Rtt[i,j], moduli[tors[j]])
    end
    push!(get!(byDet, dt, Set{Matrix{Int}}()), Rtt)
end
do_det && println("(1) elements enumerated = $nel (|GL_2(F_$p)| = $(p*(p-1)^2*(p+1)))")
do_det && println("(1) number of distinct torsion blocks for each det value (1 = depends only on det): ",
        [(dt, length(s)) for (dt,s) in sort(collect(byDet); by = first)])
Rdet = Dict(dt => first(s) for (dt,s) in byDet)
# multiplicities of the characters d -> d^e (e = 0..p-2) in the p-primary part, by orthogonality mod p:
# m_e = (1/(p-1)) sum_d tr(R(d)) d^(-e)  (mod p)
mult = Int[]
for e in 0:p-2
    s = 0
    for (dt, R) in Rdet
        s += (sum(R[i,i] for i in eachindex(tors); init=0) % p) * powermod(dt, mod(-e, p-1), p)
    end
    push!(mult, mod(s * invmod(p-1, p), p))
end
do_det && println("(1) p-primary part: multiplicity of det^e for e=0..", p-2, " = ", mult)
if p == 7
    R2 = mod.(Rdet[primroot], 2)
    println("(1) 2-primary part: block for det=$primroot mod 2 = ", R2, "  (3-cycle permutation matrix = regular rep of Z/3 if a permutation matrix of order 3)")
    println("    distinct blocks mod 2 over all dets: ", length(Set(mod.(R, 2) for R in values(Rdet))))
end

# ---------- (2) free quotient: character from the definition on class representatives ----------
gap_src = replace(raw"""
BCTBL := fail;;
BCReps := function(a)
    local T,D,S,G,cl;
    T := [[1,1],[0,1]]*Z(7)^0;
    D := [[a,0],[0,1]]*Z(7)^0;
    S := [[0,1],[1,0]]*Z(7)^0;
    G := Group(T,D,S);
    BCTBL := CharacterTable(G);
    cl := ConjugacyClasses(BCTBL);
    return rec(order := Size(G),
               reps := List(cl, c -> List(Representative(c), r -> List(r, IntFFE))),
               sizes := List(cl, Size),
               degs := List(Irr(BCTBL), x -> x[1]));
end;;
BCDecomp := function(chi)
    local irr, sizes, n, mults, i, s, k;
    irr := Irr(BCTBL); sizes := SizesConjugacyClasses(BCTBL);
    n := Sum(sizes);
    mults := [];
    for i in [1..Length(irr)] do
        s := Sum([1..Length(chi)], k -> sizes[k]*chi[k]*ComplexConjugate(irr[i][k]));
        Add(mults, Int(s/n));
    od;
    return rec(mults := mults, degs := List(irr, x->x[1]),
               innerprod := Int(Sum([1..Length(chi)], k -> sizes[k]*chi[k]*chi[k])/n));
end;;
BCStVals := function(p)
    local irr, cl, pos, x;
    irr := Irr(BCTBL); cl := ConjugacyClasses(BCTBL);
    x := [[-1,0],[0,1]]*Z(p)^0;
    pos := PositionProperty(cl, c -> x in c);
    return List([1..Length(irr)], i -> [irr[i][1], Int(irr[i][pos])]);
end;;
""", "Z(7)" => "Z($p)")
GAP.evalstr(gap_src)
info = GAP.gap_to_julia(GAP.Globals.BCReps(primroot); recursive=true)
println("(2) |G| = ", info[:order], "  classes = ", length(info[:reps]))
chi = Int[]
for rep in info[:reps]
    g = [Int(rep[i][j]) for i in 1:2, j in 1:2]
    tp = tp_of(g)
    push!(chi, sum(dot(Lm[a,:], Qm[tp, a]) for a in free))
end
println("(2) character values on class representatives: ", chi[1:min(12,length(chi))], " ...")
dec = GAP.gap_to_julia(GAP.Globals.BCDecomp(GAP.GapObj(chi)); recursive=true)
mults = dec[:mults]; degs = dec[:degs]
println("(2) dimension chi(1) = ", chi[findfirst(==(1), [Int(s) for s in info[:sizes]])],
        "   sum mult*deg = ", sum(m*d for (m,d) in zip(mults,degs)),
        "   <chi,chi> = ", dec[:innerprod], "   sum mult^2 = ", sum(m^2 for m in mults))
sig = sort([(d, m) for (d,m) in zip(degs,mults) if m > 0])
println("(2) constituents (degree, multiplicity): ", sig)
for (name, dgr) in (("linear",1), ("cuspidal",p-1), ("twisted Steinberg",p), ("principal series",p+1))
    ms = [m for (d,m) in zip(degs,mults) if d == dgr && m > 0]
    println("    $name (degree $dgr): distinct = ", length(ms), "  multiplicities = ", sort(ms))
end
if p > 2
    stv = GAP.gap_to_julia(GAP.Globals.BCStVals(p); recursive=true)
    # twisted Steinberg St x (chi o det) has value chi(-1) at diag(-1,1): +1 for even chi, -1 for odd chi
    ev = sort([m for (i,(d,m)) in enumerate(zip(degs,mults)) if d == p && m > 0 && stv[i][2] ==  1])
    od = sort([m for (i,(d,m)) in enumerate(zip(degs,mults)) if d == p && m > 0 && stv[i][2] == -1])
    println("    twisted Steinberg by parity of chi: even chi multiplicities = ", ev, "   odd chi multiplicities = ", od,
            "   (", (p-1)÷2, " even and ", (p-1)÷2, " odd characters exist)")
end

# ---------- (3) splitting test, written independently (small p only) ----------
if p <= 7 && length(tors) > 0
    Rgen = [Rfull(tp_of([1 1; 0 1])), Rfull(tp_of([primroot 0; 0 1])), Rfull(tp_of([0 1; 1 0]))]
    println("(3) torsion-rows / free-columns block identically zero for all 3 generators: ",
            all(all(R[i,j] == 0 for i in tors, j in free) for R in Rgen))
    split_src = raw"""
BCSplit := function(ell, Rs, t)
    local F, n, A, S21, S22, Mbig, rhs, g, Sg, blockM, blockC, rk, rkaug;
    F := GF(ell); n := Length(Rs[1]);
    Mbig := []; rhs := [];
    for g in Rs do
        Sg := g * One(F);
        A := ExtractSubMatrix(Sg, [1..t], [1..t]);
        S21 := ExtractSubMatrix(Sg, [t+1..n], [1..t]);
        S22 := ExtractSubMatrix(Sg, [t+1..n], [t+1..n]);
        # unknown Y ((n-t) x t, row-major). Equation S22*Y - Y*A = -S21.
        blockM := KroneckerProduct(S22, IdentityMat(t, F)) - KroneckerProduct(IdentityMat(n-t, F), TransposedMat(A));
        blockC := -Concatenation(S21);
        Append(Mbig, blockM); Append(rhs, blockC);
    od;
    rk := RankMat(Mbig);
    rkaug := RankMat(List([1..Length(Mbig)], i -> Concatenation(Mbig[i], [rhs[i]])));
    return rec(equations := Length(Mbig), unknowns := (n-t)*t, rank := rk, rank_augmented := rkaug,
               solvable := (rk = rkaug));
end;;
"""
    GAP.evalstr(split_src)
    @assert tors == collect(1:length(tors))   # torsion coordinates come first
    for ell in (p == 7 ? (2, 7) : (p,))
        Rs = GAP.GapObj([[Vector{Int}(mod.(R[i,:], ell)) for i in 1:k] for R in Rgen]; recursive=true)
        res = GAP.gap_to_julia(GAP.Globals.BCSplit(ell, Rs, length(tors)); recursive=true)
        println("(3) prime $ell: ", res)
        println("    => the $ell-primary extension ", res[:solvable] ? "SPLITS (equivariant retraction exists)" : "does NOT split (no equivariant retraction M/$(ell)M -> T)")
    end
end
