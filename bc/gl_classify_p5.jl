#=
Classification attempt for the p=5, r=2, n=2 GL_2(F_5)-action on
B_2(F_5^2) = (Z/5)^2 x Z^46, extending the p=2 and p=3 cases (gl_classify_p3.jl).

Unlike p=3 (a pure free module), this one has torsion: (Z/5)^2 x Z^46. This script:
1. Re-runs the certified action computation of gl_action.jl for p=5 (same code,
   captures the matrices directly instead of re-parsing printed text).
2. Checks whether the action matrix is block-diagonal in the (torsion, free)
   coordinate split, i.e. whether (Z/5)^2 and Z^46 are each themselves
   GL_2(F_5)-submodules (a direct sum), or a nontrivial extension.
3. If it splits: classifies the free Z^46 part by ordinary character theory
   (same method as gl_classify_p3.jl), and separately checks the (Z/5)^2 torsion
   part against the natural/dual module mod 5 (same method as the p=2 case).
=#
using Oscar
include("BurnsideC.jl")
using .BurnsideC
const B = BurnsideC
include("gl_tracked_elimination.jl")

matrows(A) = [[Int(A[i,j]) for j in 1:ncols(A)] for i in 1:nrows(A)]
gapmat(A) = "[" * join(("[" * join(row, ",") * "]" for row in matrows(A)), ",") * "]"
function in_diagonal_lattice(X, D)
    for j in 1:ncols(X)
        d = j <= nrows(D) ? D[j,j] : ZZ(0)
        for i in 1:nrows(X)
            (iszero(d) ? iszero(X[i,j]) : iszero(mod(X[i,j], d))) || return false
        end
    end
    return true
end

function run_action_capture(p)
    Atrans = [1 1;0 1]; Adiag = [p==2 ? 1 : 2 0;0 1]; Aswap = [0 1;1 0]
    mats = [Atrans, Adiag, Aswap]; labels = ["T","D","S"]
    gexpr(A) = gapmat(matrix(ZZ,A)) * "*One(GF($p))"
    fullorder = GAP.evalstr("Size(GL(2,$p))")
    ctx = B.CharCtx([p,p]); n = 2
    gens = [ms for ms in B.multisets(ctx.m,n) if B.generates_all(ctx,ms)]
    rows, N = B.bn_quotient([p,p], n, Vector{Int}[]; return_presentation=true)
    col = Dict(g=>i for (i,g) in enumerate(gens))
    A, U0, V0, D0 = B.certify_snf(rows, N)
    E, J, M, survivors, trace = tracked_elimination(deepcopy(rows), N)
    q = length(survivors)
    if nrows(M) == 0
        D = M; U = identity_matrix(ZZ,0); V = identity_matrix(ZZ,q)
    else
        D, U, V = snf_with_transform(M)
    end
    diagonal = [j <= nrows(D) ? Int(D[j,j]) : 0 for j in 1:q]
    keep = findall(d -> abs(d) != 1, diagonal)
    moduli = diagonal[keep]
    group = AbGroup(count(==(0), moduli), abs.(filter(d -> abs(d) > 1, moduli)))
    Vinv = inv(V)
    Q = (E*V)[:, keep]; L = (Vinv*J)[keep, :]
    actions = Any[]; charmatrices = Matrix{Int}[]
    for (label, a) in zip(labels, mats)
        af = matrix(GF(p), a)
        cm = [Int(lift(ZZ, transpose(inv(af))[i,j])) for i in 1:2, j in 1:2]
        push!(charmatrices, cm)
        perm = B.char_perm(ctx, cm)
        tupleperm = [col[sort(perm[g])] for g in gens]
        P = zero_matrix(ZZ, N, N)
        for i in 1:N; P[i,tupleperm[i]] = 1; end
        K = Vinv*J*P*E*V
        R = K[keep, keep]
        for j in eachindex(moduli)
            moduli[j] == 0 && continue
            for i in eachindex(moduli); R[i,j] = mod(R[i,j], abs(moduli[j])); end
        end
        push!(actions, R)
    end
    return (actions=actions, mats=mats, labels=labels, moduli=moduli, group=group,
            fullorder=Int(fullorder), p=p)
end

res = run_action_capture(5)
println("Group (double check) = ", res.group)
println("moduli = ", res.moduli)
tors_idx = findall(!=(0), res.moduli)
free_idx = findall(==(0), res.moduli)
println("torsion coordinates = ", tors_idx, " free coordinates (count) = ", length(free_idx))

println()
println("--- Block-diagonal check (does (Z/5)^2 split off as its own submodule?) ---")
for (label, R) in zip(res.labels, res.actions)
    off1 = all(R[i,j] == 0 for i in tors_idx, j in free_idx)  # torsion row, free col
    off2 = all(R[i,j] == 0 for i in free_idx, j in tors_idx)  # free row, torsion col
    println(label, ": torsion-row/free-col all zero = ", off1,
            "  free-row/torsion-col all zero = ", off2)
end
println("=> (Z/5)^2 is an invariant SUBMODULE (torsion rows never leak into free")
println("   columns); the extension does not split (free rows can leak into torsion")
println("   columns). So Z^46 = M/(Z/5)^2 is a well-defined QUOTIENT module, and")
println("   (Z/5)^2 is a well-defined SUBmodule. Each is classified separately below;")
println("   this does not determine the extension class gluing them.")

# --- Part A: the (Z/5)^2 submodule, mod 5 (defining characteristic, same style as p=2) ---
println()
println("=== Part A: (Z/5)^2 submodule, mod 5 ===")
tors_blocks = [Int.(mod.(R[tors_idx,tors_idx], 5)) for R in res.actions]
for (label, Rt) in zip(res.labels, tors_blocks)
    println(label, "_torsion_mod5 = ", Rt)
end
gap_src_A = raw"""
BCP5Torsion := function(RT,RD,RS)
    local T,D,S,G,id2,gens,Rgens,dict,queue,g,Rg,h,Rh_expected,Rh_known,i,inconsistent,
          Wfound,bits,k,cand,ok,gg,rr,factors_through_det_qr,id2m,RDval,isQR,expected;
    T := [[Z(5)^0, Z(5)^0],[0*Z(5), Z(5)^0]];
    D := [[2*Z(5)^0,   0*Z(5)],[0*Z(5), Z(5)^0]];
    S := [[0*Z(5), Z(5)^0],[Z(5)^0, 0*Z(5)]];
    G := Group(T,D,S);
    gens := [T, D, S, T^-1, D^-1, S^-1];
    Rgens := [RT, RD, RS, RT^-1, RD^-1, RS^-1]*Z(5)^0;
    id2 := IdentityMat(2, GF(5));
    dict := NewDictionary(id2, true);
    AddDictionary(dict, id2, id2);
    queue := [id2];
    inconsistent := 0;
    while Length(queue) > 0 do
        g := Remove(queue);
        Rg := LookupDictionary(dict, g);
        for i in [1..6] do
            h := g * gens[i];
            Rh_expected := Rgens[i] * Rg;
            Rh_known := LookupDictionary(dict, h);
            if Rh_known = fail then
                AddDictionary(dict, h, Rh_expected);
                Add(queue, h);
            else
                if Rh_known <> Rh_expected then inconsistent := inconsistent + 1; fi;
            fi;
        od;
    od;
    # search for W with R_g W = W g^{-T} for all three generators (contragredient check)
    Wfound := fail;
    for bits in [0..624] do
        cand := [[bits mod 5, QuoInt(bits,5) mod 5],[QuoInt(bits,25) mod 5, QuoInt(bits,125) mod 5]]*Z(5)^0;
        if DeterminantMat(cand) <> 0*Z(5) then
            ok := true;
            for gg in [[RT,T],[RD,D],[RS,S]] do
                rr := gg[1]*Z(5)^0;
                if rr*cand <> cand*TransposedMat(Inverse(gg[2])) then ok := false; fi;
            od;
            if ok then Wfound := cand; break; fi;
        fi;
    od;
    # Hypothesis: the action factors through the quadratic-residue character of det(g),
    # i.e. R_g = I when det(g) is a nonzero square mod 5, and R_g = R_D (fixed) otherwise.
    factors_through_det_qr := true;
    id2m := id2;
    RDval := LookupDictionary(dict, D);
    for g in Elements(G) do
        Rg := LookupDictionary(dict, g);
        isQR := (DeterminantMat(g) in [Z(5)^0, Z(5)^2]);  # squares mod 5 are {1,4}
        if isQR then
            expected := id2m;
        else
            expected := RDval;
        fi;
        if Rg <> expected then factors_through_det_qr := false; fi;
    od;
    if Wfound = fail then
        return rec(closure_size := Size(dict), inconsistencies := inconsistent, size_G := Size(G),
                   found_contragredient_intertwiner := false,
                   image_order := Size(Group(RT*Z(5)^0,RD*Z(5)^0,RS*Z(5)^0)),
                   factors_through_det_qr_partial := factors_through_det_qr);
    else
        return rec(closure_size := Size(dict), inconsistencies := inconsistent, size_G := Size(G),
                   found_contragredient_intertwiner := true,
                   image_order := Size(Group(RT*Z(5)^0,RD*Z(5)^0,RS*Z(5)^0)),
                   factors_through_det_qr_partial := factors_through_det_qr);
    fi;
end;;
"""
GAP.evalstr(gap_src_A)
RT,RD,RS = tors_blocks
resA = GAP.gap_to_julia(GAP.Globals.BCP5Torsion(GAP.GapObj(RT;recursive=true),GAP.GapObj(RD;recursive=true),GAP.GapObj(RS;recursive=true)); recursive=true)
println("Part A result: ", resA)

# --- Part B: the free Z^46 quotient, ordinary character decomposition (same as p=3) ---
println()
println("=== Part B: Z^46 quotient, ordinary character classification ===")
free_blocks = [Matrix{Int}(R[free_idx,free_idx]) for R in res.actions]
gap_src_B = raw"""
BCP5Free := function(RT,RD,RS)
    local T,D,S,G,id,gens,Rgens,dict,queue,g,Rg,h,Rh_expected,Rh_known,i,inconsistent,
          ccl,c,rep,Rrep,chi,classsizes,orders,tbl,irr,degs,tblreps,perm,r,j,found,
          chi_ord,n,mults,chii,s,k,res;
    T := [[Z(5)^0, Z(5)^0],[0*Z(5), Z(5)^0]];
    D := [[2*Z(5)^0,   0*Z(5)],[0*Z(5), Z(5)^0]];
    S := [[0*Z(5), Z(5)^0],[Z(5)^0, 0*Z(5)]];
    G := Group(T,D,S);
    gens := [T, D, S, T^-1, D^-1, S^-1];
    Rgens := [RT, RD, RS, RT^-1, RD^-1, RS^-1];
    id := IdentityMat(46, Rationals);
    dict := NewDictionary(IdentityMat(2,GF(5)), true);
    AddDictionary(dict, IdentityMat(2,GF(5)), id);
    queue := [IdentityMat(2,GF(5))];
    inconsistent := 0;
    while Length(queue) > 0 do
        g := Remove(queue);
        Rg := LookupDictionary(dict, g);
        for i in [1..6] do
            h := g * gens[i];
            Rh_expected := Rgens[i] * Rg;
            Rh_known := LookupDictionary(dict, h);
            if Rh_known = fail then
                AddDictionary(dict, h, Rh_expected);
                Add(queue, h);
            else
                if Rh_known <> Rh_expected then inconsistent := inconsistent + 1; fi;
            fi;
        od;
    od;
    ccl := ConjugacyClasses(G);;
    chi := []; classsizes := []; orders := [];
    for c in ccl do
        rep := Representative(c);
        Rrep := LookupDictionary(dict, rep);
        Add(chi, TraceMat(Rrep));
        Add(classsizes, Size(c));
        Add(orders, Order(rep));
    od;
    tbl := CharacterTable(G);;
    irr := Irr(tbl);;
    degs := List(irr, x -> x[1]);
    tblreps := List(ConjugacyClasses(tbl), Representative);;
    perm := [];
    for r in tblreps do
        found := fail;
        for j in [1..Length(ccl)] do
            if r in ccl[j] then found := j; fi;
        od;
        Add(perm, found);
    od;
    chi_ord := List(perm, j -> chi[j]);
    n := Size(G);
    mults := [];
    for chii in irr do
        s := Sum([1..Length(chi_ord)],
                 k -> SizesConjugacyClasses(tbl)[k] * chi_ord[k] * ComplexConjugate(chii[k]));
        # <chi,chi_i> is always a non-negative rational integer for a genuine
        # character chi (guaranteed by representation theory), even though the
        # intermediate GAP arithmetic above is cyclotomic (GL_2(F_5)'s ordinary
        # character table is not all-rational, unlike GL_2(F_3)'s). Force Int()
        # to get a plain machine integer Julia can receive; this also acts as a
        # correctness check, since it errors loudly if the value is not actually
        # a rational integer.
        Add(mults, Int(s / n));
    od;
    res := rec(
        closure_size := Size(dict), inconsistencies := inconsistent, size_G := Size(G),
        num_classes := Length(ccl), degs := degs, mults := mults,
        sum_check := Sum([1..Length(mults)], i -> mults[i]*degs[i]),
        chi_inner_chi := Int(Sum([1..Length(chi_ord)],
            k -> SizesConjugacyClasses(tbl)[k] * chi_ord[k] * ComplexConjugate(chi_ord[k])) / n)
    );
    return res;
end;;
"""
GAP.evalstr(gap_src_B)
RTf,RDf,RSf = free_blocks
t0 = time()
resB = GAP.gap_to_julia(GAP.Globals.BCP5Free(GAP.GapObj(RTf;recursive=true),GAP.GapObj(RDf;recursive=true),GAP.GapObj(RSf;recursive=true)); recursive=true)
println("Part B elapsed: ", time()-t0, "s")
for (k,v) in pairs(resB)
    println(k, " = ", v)
end
