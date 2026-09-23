# validate.jl -- reproduce the published values of Tschinkel-Yang-Zhang, arXiv:2112.12801
#
#   julia --project=. validate.jl            # quick tier  (seconds to ~1 min)
#   julia --project=. validate.jl full       # + S_7, S_8 (minutes; see REPORT.md)
#   julia --project=. validate.jl crosscheck # definition-level check vs Theorem 5.2
#   julia --project=. validate.jl demo       # per-[H,Y] breakdown of C2 x S3 (Section 6.5)
include(joinpath(@__DIR__, "BurnsideC.jl"))
using .BurnsideC
using Oscar
using Printf

# ---------------------------------------------------------------- groups -----
function subgroup_of_S(k, gens...)
    S = symmetric_group(k)
    return sub(S, [cperm(S, g...) for g in gens])[1]
end
group_A5()   = alternating_group(5)
group_D(p)   = dihedral_group(PermGroup, 2p)               # order 2p
group_C2S3() = subgroup_of_S(6, [[1,2,3,4,5,6]], [[1,6],[2,5],[3,4]])   # paper 6.5
group_ASL23() = subgroup_of_S(9, [[2,5,8],[3,9,6]], [[2,4,3,7],[5,6,9,8]], [[1,2,3],[4,5,6],[7,8,9]])
group_PSL27() = subgroup_of_S(8, [[3,6,7],[4,5,8]], [[1,8,2],[4,5,6]])
group_A6()    = subgroup_of_S(6, [[1,2],[3,4,5,6]], [[1,2,3]])
function heis(p)      # Heisenberg group of order p^3, exponent p (p odd), as a permutation group
    GAP.evalstr("Image(IsomorphismPermGroup(ExtraspecialGroup($(p^3), \"+\")))")
end
group_D4() = dihedral_group(PermGroup, 8)
gapgrp(s) = GAP.evalstr(s)

# ------------------------------------------------------------ bookkeeping ----
mutable struct Tally
    ok::Int; bad::Int; rows::Vector{Any}
end
const T = Tally(0, 0, [])

# structures are expensive (GAP subgroup lattices) so cache them per group
const STRUCT = Dict{String,Any}()
getstruct(name, mk) = get!(STRUCT, name) do
    st = bc_structure(mk(); name=name)
    @printf("  (GAP: %d classes [H,Y] of |G|=%d enumerated in %.2fs)\n", npairs(st), st.order, st.gap_seconds)
    st
end

function check(label, st, n, expected::AbstractString; note="")
    r = bc(st, n)
    exp = ab(expected)
    ok = r.total == exp
    ok ? (T.ok += 1) : (T.bad += 1)
    push!(T.rows, (label, ok))
    @printf("  [%s] %-16s computed: %-46s paper: %-42s %6.2fs  (%d classes [H,Y])%s\n",
            ok ? " OK " : "FAIL", label, format_ab(r.total), format_ab(exp), r.seconds, r.npairs,
            isempty(note) ? "" : "  # " * note)
    return r
end

function header(s)
    println("\n", "="^100, "\n", s, "\n", "="^100)
end

# expected nonzero summands as (|H|, |Y|, value)
function check_summands(label, r, expected)
    got = sort([(prod(s.d), s.Ysize, format_ab(s.value)) for s in r.summands if !iszero(s.value)])
    exp = sort([(h, y, format_ab(ab(v))) for (h, y, v) in expected])
    ok = got == exp
    ok ? (T.ok += 1) : (T.bad += 1)
    push!(T.rows, (label, ok))
    println("  [", ok ? " OK " : "FAIL", "] ", label)
    println("        computed: ", got)
    ok || println("        paper   : ", exp)
end

# number of classes [H,Y] by |H|, for the Heisenberg-group formula of Section 6.2
function check_count(label, st, expected::Dict)
    got = Dict{Int,Int}()
    for h in st.hclasses; got[prod(h.d)] = get(got, prod(h.d), 0) + length(h.pairs); end
    ok = got == expected
    ok ? (T.ok += 1) : (T.bad += 1)
    push!(T.rows, (label, ok))
    println("  [", ok ? " OK " : "FAIL", "] ", label, "   computed: ", sort(collect(got)), ok ? "" : "   paper: $(sort(collect(expected)))")
end

# ----------------------------------------------------------------- tiers -----
function quick()
    header("Symmetric groups S_n   (paper Section 6.3 table)")
    st3 = getstruct("S3", () -> symmetric_group(3))
    check("BC_2(S_3)", st3, 2, "Z/2")
    check("BC_3(S_3)", st3, 3, "0")
    stc3 = getstruct("C3", () -> cyclic_group(PermGroup, 3))
    check("BC_2(C_3)", stc3, 2, "Z", note="paper Sec. 4: BC_2(C_3) = Z")
    st4 = getstruct("S4", () -> symmetric_group(4))
    check("BC_2(S_4)", st4, 2, "(Z/2)^3")
    check("BC_3(S_4)", st4, 3, "0")
    check_summands("S_4: contributing [H,Y] = (C3,C3),(K4,K4),(C4,C4), each Z/2 [Sec 6.3]",
                   bc(st4, 2), [(3,3,"Z/2"), (4,4,"Z/2"), (4,4,"Z/2")])
    st5 = getstruct("S5", () -> symmetric_group(5))
    check("BC_2(S_5)", st5, 2, "(Z/2)^6 × Z/4")
    check("BC_3(S_5)", st5, 3, "0")
    st6 = getstruct("S6", () -> symmetric_group(6))
    check("BC_2(S_6)", st6, 2, "(Z/2)^31 × (Z/4)^3 × Z/8")
    check("BC_3(S_6)", st6, 3, "(Z/2)^5 × Z/4")

    header("A_5  (Section 6.4)")
    sta5 = getstruct("A5", group_A5)
    check("BC_2(A_5)", sta5, 2, "(Z/2)^3")
    for n in 3:9
        check("BC_$n(A_5)", sta5, n, "0")
    end
    check_summands("A_5: [(C3,C3)]=Z/2 and [(C5,C5)]=(Z/2)^2 [Sec 6.4]",
                   bc(sta5, 2), [(3,3,"Z/2"), (5,5,"(Z/2)^2")])

    header("C_2 x S_3 = D_6 = <(1..6),(1,6)(2,5)(3,4)>  (Section 6.5, geometric application)")
    stc = getstruct("C2xS3", group_C2S3)
    r = check("BC_2(C2×S3)", stc, 2, "(Z/2)^5 × Z/4")
    check("BC_3(C2×S3)", stc, 3, "0", note="paper: BC_3(G)=0")
    check_summands("C2×S3: B2([H1,H1])=Z/2, B2([H2,H2])=(Z/2)^2, B2([H1,H3])=Z/2, B2([H3,H3])=Z/2×Z/4",
                   r, [(3,3,"Z/2"), (4,4,"(Z/2)^2"), (3,6,"Z/2"), (6,6,"Z/2 × Z/4")])

    header("Dihedral groups D_p (order 2p)  — paper's formula is an experimental observation")
    for p in (5, 7, 11, 13, 17, 19, 23)
        rk = (p - 5) * (p - 7) ÷ 24
        pred = join(filter(!isempty, [rk > 0 ? "Z^$rk" : "", "(Z/2)^$((p-3)÷2)", "Z/$((p^2-1)÷12)"]), " × ")
        stp = getstruct("D$p", () -> group_D(p))
        check("BC_2(D_$p)", stp, 2, pred; note="formula: Z^((p-5)(p-7)/24) × (Z/2)^((p-3)/2) × Z/((p²-1)/12)")
    end

    header("Central extensions of abelian groups (Section 6.2)")
    st = getstruct("D4", group_D4)
    check("BC_2(D_4)", st, 2, "(Z/2)^3")
    st = getstruct("He3", () -> heis(3))
    check("BC_2(He_3)", st, 2, "Z^26")
    check("BC_3(He_3)", st, 3, "Z^4")
    check_count("He_3: #[Z/p,Z/p] = 3p+5 and #[(Z/p)^2,(Z/p)^2] = p+1  (p=3)", st, Dict(3 => 14, 9 => 4))
    st = getstruct("He5", () -> heis(5))
    check("BC_2(He_5)", st, 2, "Z^124")
    check("BC_3(He_5)", st, 3, "(Z/2)^36 × Z^36")
    check_count("He_5: #[Z/p,Z/p] = 3p+5 and #[(Z/p)^2,(Z/p)^2] = p+1  (p=5)", st, Dict(5 => 20, 25 => 6))

    header("Primitive subgroups of the plane Cremona group (Section 6.4)")
    st = getstruct("ASL23", group_ASL23)
    check("BC_2(ASL(2,3))", st, 2, "(Z/2)^7 × Z^13")
    check("BC_3(ASL(2,3))", st, 3, "Z/2 × Z")
    check("BC_4(ASL(2,3))", st, 4, "0"); check("BC_5(ASL(2,3))", st, 5, "0")
    st = getstruct("PSL27", group_PSL27)
    check("BC_2(PSL(2,7))", st, 2, "(Z/2)^3 × Z")
    check("BC_3(PSL(2,7))", st, 3, "Z/2")
    check("BC_4(PSL(2,7))", st, 4, "0")
    st = getstruct("A6", group_A6)
    check("BC_2(A_6)", st, 2, "(Z/2)^7 × Z/4 × Z")
    check("BC_3(A_6)", st, 3, "Z/2 × Z")
    check("BC_4(A_6)", st, 4, "0")
end

function full()
    header("S_7, S_8  (stretch; GAP subgroup-class enumeration dominates)")
    st7 = getstruct("S7", () -> symmetric_group(7))
    check("BC_2(S_7)", st7, 2, "(Z/2)^57 × (Z/4)^12 × (Z/8)^2 × Z/3")
    check("BC_3(S_7)", st7, 3, "(Z/2)^16 × Z/4")
    st8 = getstruct("S8", () -> symmetric_group(8))
    check("BC_2(S_8)", st8, 2, "(Z/2)^290 × (Z/4)^30 × (Z/8)^6 × Z/16 × (Z/3)^2 × Z")
    check("BC_3(S_8)", st8, 3, "(Z/2)^122 × (Z/4)^4 × Z/8 × Z")
end

# Definition-level check: relations (C),(V),(B2) incl. Theta_2 straight on SC_n(G)
function crosscheck()
    header("Cross-check: Theorem 5.2 implementation  vs  definition-level (C),(V),(B2) with Theta_2")
    cases = [("S_3", () -> symmetric_group(3), 1:4), ("S_4", () -> symmetric_group(4), 1:4),
             ("D_4", group_D4, 1:3), ("D_5", () -> group_D(5), 1:3),
             ("C2×S3", group_C2S3, 1:4), ("A_5", group_A5, 1:3),
             ("S_5", () -> symmetric_group(5), 2:2),
             # groups containing V4×C3, C6×C6, ...: these exercise "min #generators of H^" < #primary factors
             ("D4×C3", () -> gapgrp("DirectProduct(DihedralGroup(IsPermGroup,8), CyclicGroup(IsPermGroup,3))"), 1:3),
             ("C6×C6", () -> gapgrp("DirectProduct(CyclicGroup(IsPermGroup,6), CyclicGroup(IsPermGroup,6))"), 1:2),
             ("S3×S3", () -> gapgrp("DirectProduct(SymmetricGroup(3), SymmetricGroup(3))"), 1:3),
             ("S_6", () -> symmetric_group(6), 2:2)]
    for (nm, mk, ns) in cases
        G = mk()
        st = bc_structure(G; name=nm)
        for n in ns
            a = bc(st, n).total
            t = @elapsed (b, info) = bc_direct(G, n)
            ok = a == b
            ok ? (T.ok += 1) : (T.bad += 1)
            push!(T.rows, ("crosscheck $nm n=$n", ok))
            @printf("  [%s] BC_%d(%-6s) Thm5.2: %-28s definition-level: %-28s (%d generators, %d relations, %.1fs)\n",
                    ok ? " OK " : "FAIL", n, nm, format_ab(a), format_ab(b), info.ngens, info.nrels, t)
        end
    end
    header("Sanity: imposing the (redundant) vanishing  sum_{i in I} b_i = 0  changes nothing  (paper (4.3))")
    for (nm, mk, n) in [("S_4", () -> symmetric_group(4), 2), ("S_5", () -> symmetric_group(5), 2),
                        ("A_5", group_A5, 3), ("C2×S3", group_C2S3, 3), ("ASL(2,3)", group_ASL23, 3)]
        st = bc_structure(mk(); name=nm)
        a = bc(st, n).total; b = bc(st, n; extra_vanishing=true).total
        ok = a == b
        ok ? (T.ok += 1) : (T.bad += 1)
        push!(T.rows, ("subset-vanishing $nm n=$n", ok))
        @printf("  [%s] BC_%d(%-9s) plain: %-30s with subset-sum vanishing: %s\n", ok ? " OK " : "FAIL", n, nm, format_ab(a), format_ab(b))
    end
end

function demo()
    header("Demo: C2 x S3, per-[H,Y] decomposition of BC_2  (paper Section 6.5)")
    st = getstruct("C2xS3", group_C2S3)
    r = bc(st, 2)
    println("  ", r, "        paper: (Z/2)^5 × Z/4\n")
    @printf("  %-8s %-12s %-14s %-6s %-9s %-7s  %s\n", "H", "|H| gens", "Y", "|Y|", "|N∩N(Y)|", "|Aut-im|", "B_2([H,Y])")
    for s in r.summands
        @printf("  %-8s %-12s %-14s %-6d %-9d %-7s  %s\n", s.Hdesc, join(s.Hgens, ","), s.Ydesc, s.Ysize,
                s.stabsize, string(s.autsize), iszero(s.value) ? "0" : format_ab(s.value))
    end
    println("\n  Invariant factors of BC_2: ", BurnsideC.invariant_factors(r.total), "   free rank: ", r.total.free)
end

function summary()
    header("SUMMARY")
    println("  passed: $(T.ok)   failed: $(T.bad)")
    for (l, ok) in T.rows
        ok || println("  FAILED: ", l)
    end
end

mode = isempty(ARGS) ? "quick" : ARGS[1]
if mode == "quick"; quick()
elseif mode == "full"; quick(); full()
elseif mode == "crosscheck"; crosscheck()
elseif mode == "demo"; demo()
elseif mode == "all"; quick(); crosscheck(); full()
else error("unknown mode $mode") end
mode == "demo" || summary()
