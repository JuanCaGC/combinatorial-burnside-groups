#=
Ordinary-character classification of the p=3, r=2, n=2 GL_2(F_3)-action on
B_2(F_3^2) ≅ Z^7 reported in gl_module_codex_report.md (Priority 2).

Independent of that report: takes only the abstract generators T,D,S of
GL_2(F_3) and the three reported 7x7 integer action matrices RT,RD,RS as
input. Builds the full group of order 48 by BFS (closure under the six
generators/inverses), tracking the corresponding product of R-matrices at
each element; a mismatch anywhere would mean the reported matrices do not
define a consistent representation. Zero mismatches occur only when R-matrix
products are composed in the *reverse* of the order stated in prose in
gl_module_codex_report.md ("h after g gives R_g R_h"): the consistent
assignment is R_(g*h) = R_h * R_g, i.e. g ↦ R_g is an anti-homomorphism for
GAP's own left-to-right group multiplication. This does not affect the
character-based classification below, since every character value obtained
is a rational integer, hence real, hence χ(g)=χ(g^{-1}) automatically
(so the anti-homomorphism's character equals that of the corresponding
genuine representation g ↦ R_(g^{-1})). It is flagged here as a correction
to the report's prose, not to its matrices or its own certificate checks.

Once genuineness is established, decomposes the resulting character against
the ordinary character table of GL_2(F_3) (computed directly from the same
matrix group, not looked up).
=#
using Oscar

gap_src = raw"""
BCP3Classify := function()
    local T,D,S,G3,RT,RD,RS,RTi,RDi,RSi,id2,id7,gens,Rgens,
          dict,queue,g,Rg,h,Rh_expected,Rh_known,i,inconsistent,
          ccl,c,rep,Rrep,chi,classsizes,orders,tbl,irr,degs,
          tblreps,perm,r,j,found,chi_ord,n,mults,chii,s,k,res;
    T := [[Z(3)^0, Z(3)^0],[0*Z(3), Z(3)^0]];
    D := [[Z(3),   0*Z(3)],[0*Z(3), Z(3)^0]];
    S := [[0*Z(3), Z(3)^0],[Z(3)^0, 0*Z(3)]];
    G3 := Group(T,D,S);

    RT := [[1,-1,0,0,0,0,0],[0,-1,0,-1,0,0,0],[0,1,1,0,0,0,0],[0,1,0,0,0,0,0],
           [0,0,-1,1,0,0,-1],[-1,0,-1,0,-1,0,0],[1,0,0,0,0,1,0]];
    RD := [[0,0,1,0,0,0,0],[0,0,0,1,0,0,0],[1,0,0,0,0,0,0],[0,1,0,0,0,0,0],
           [-1,0,-1,0,-1,0,0],[0,0,-1,1,0,0,-1],[-1,1,0,0,0,-1,0]];
    RS := [[1,0,0,0,0,0,0],[1,-1,0,0,0,0,0],[-1,0,-1,0,-1,0,0],[0,0,0,0,0,1,0],
           [0,0,0,0,1,0,0],[0,0,0,1,0,0,0],[1,0,0,1,0,1,-1]];
    RTi := RT^-1;; RDi := RD^-1;; RSi := RS^-1;;

    id2 := IdentityMat(2, GF(3));
    id7 := IdentityMat(7, Rationals);
    gens := [T, D, S, T^-1, D^-1, S^-1];
    Rgens := [RT, RD, RS, RTi, RDi, RSi];

    dict := NewDictionary(id2, true);
    AddDictionary(dict, id2, id7);
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
                if Rh_known <> Rh_expected then
                    inconsistent := inconsistent + 1;
                fi;
            fi;
        od;
    od;

    ccl := ConjugacyClasses(G3);;
    chi := [];
    classsizes := [];
    orders := [];
    for c in ccl do
        rep := Representative(c);
        Rrep := LookupDictionary(dict, rep);
        Add(chi, TraceMat(Rrep));
        Add(classsizes, Size(c));
        Add(orders, Order(rep));
    od;

    tbl := CharacterTable(G3);;
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

    n := Size(G3);
    mults := [];
    for chii in irr do
        s := Sum([1..Length(chi_ord)],
                 k -> SizesConjugacyClasses(tbl)[k] * chi_ord[k] * ComplexConjugate(chii[k]));
        Add(mults, s / n);
    od;

    res := rec(
        size_G3 := Size(G3),
        det_RT := DeterminantMat(RT), det_RD := DeterminantMat(RD), det_RS := DeterminantMat(RS),
        closure_size := Size(dict), inconsistencies := inconsistent,
        num_classes := Length(ccl), class_sizes := classsizes, elt_orders := orders,
        chi_ccl_order := chi, irr_degrees := degs,
        class_match := perm, chi_tbl_order := chi_ord,
        multiplicities := mults,
        sum_check := Sum([1..Length(mults)], i -> mults[i]*degs[i]),
        chi_inner_chi := Sum([1..Length(chi_ord)],
            k -> SizesConjugacyClasses(tbl)[k] * chi_ord[k] * ComplexConjugate(chi_ord[k])) / n
    );
    return res;
end;;
"""

GAP.evalstr(gap_src)
result = GAP.gap_to_julia(GAP.Globals.BCP3Classify(); recursive=true)
for (k,v) in pairs(result)
    println(k, " = ", v)
end

# Extra: pull out the two individual irreducible characters (degree 3 at idx6, degree 4 at idx8)
# and a few structural facts (center behavior, unipotent class) to help identify them.
extra_src = raw"""
BCP3Extra := function()
    local T,D,S,G3,tbl,irr,ord,sizes,degs,res;
    T := [[Z(3)^0, Z(3)^0],[0*Z(3), Z(3)^0]];
    D := [[Z(3),   0*Z(3)],[0*Z(3), Z(3)^0]];
    S := [[0*Z(3), Z(3)^0],[Z(3)^0, 0*Z(3)]];
    G3 := Group(T,D,S);
    tbl := CharacterTable(G3);;
    irr := Irr(tbl);;
    ord := OrdersClassRepresentatives(tbl);
    sizes := SizesConjugacyClasses(tbl);
    degs := List(irr, x->x[1]);
    res := rec(
        orders := ord, sizes := sizes, degs := degs,
        irr6 := irr[6], irr7 := irr[7], irr8 := irr[8],
        center_size := Size(Centre(G3))
    );
    return res;
end;;
"""
GAP.evalstr(extra_src)
extra = GAP.gap_to_julia(GAP.Globals.BCP3Extra(); recursive=true)
println()
println("--- extra identification data ---")
for (k,v) in pairs(extra)
    println(k, " = ", v)
end
