# bc_structure.g -- group-theoretic input for Theorem 5.2 of Tschinkel-Yang-Zhang.
#
#   BC_n(G) = (+)_{[H,Y]}  B_n(H) / (C_(H,Y))
#
# BCStructure(G) returns one record per G-conjugacy class of NONTRIVIAL abelian
# subgroups H, each carrying one entry per class [H,Y], i.e. per N_G(H)-orbit of
# subgroups Y with  H <= Y <= Z_G(H).  All entries are plain integers/lists so
# they cross the GAP -> Julia boundary without any object wrappers.
#
# Coordinates: H = <g_1> x ... x <g_k> (IndependentGeneratorsOfAbelianGroup),
# d_i = |g_i|.  For g in N_G(H)  n  N_G(Y)  the action on H is recorded as the
# integer matrix M with  g_j^g = prod_i g_i^(M[j][i]).

BCStructure := function(G)
  local res, cl, H, gens, d, C, N, Ys, inter, orbs, orb, Y, S, mats, g, M, pairs, desc;
  res := [];
  for cl in ConjugacyClassesSubgroups(G) do
    H := Representative(cl);
    if Size(H) > 1 and IsAbelian(H) then
      gens := IndependentGeneratorsOfAbelianGroup(H);
      d    := List(gens, Order);
      C    := Centralizer(G, H);
      N    := Normalizer(G, H);
      if Size(C) = Size(H) then
        Ys := [H];
      else
        inter := IntermediateSubgroups(C, H);
        Ys := Concatenation([H], inter.subgroups, [C]);
      fi;
      # classes of Y under N_G(H)  (G-classes of pairs (H',Y') with H' ~ H)
      orbs  := Orbits(N, Ys, OnPoints);
      pairs := [];
      for orb in orbs do
        Y := orb[1];
        S := Normalizer(N, Y);            # = N_G(H) n N_G(Y)
        mats := [];
        for g in SmallGeneratingSet(S) do
          M := List(gens, x -> IndependentGeneratorExponents(H, x^g));
          if M <> IdentityMat(Length(d)) then Add(mats, M); fi;
        od;
        if Size(Y) <= 2000 then desc := StructureDescription(Y);
        else desc := Concatenation("order ", String(Size(Y))); fi;
        Add(pairs, rec(Ysize := Size(Y), Ydesc := desc, orbitsize := Length(orb),
                       stabsize := Size(S), mats := mats));
      od;
      Add(res, rec(d := d, Hsize := Size(H), Hdesc := StructureDescription(H),
                   Hgens := List(gens, String), classsize := Size(G)/Size(N),
                   Csize := Size(C), Nsize := Size(N), pairs := pairs));
    fi;
  od;
  return res;
end;

# ---- data for the definition-level computation (small groups only) --------
# Returns everything needed to run the relations (C),(V),(B2) of the paper
# directly on SC_n(G), without using Theorem 5.2:
#  elts     : elements of G (sorted list), we identify elements with positions
#  gensG    : positions of a generating set of G
#  conj[a]  : for each generator a, the permutation  x -> a x a^-1  (positions)
#  subs     : all abelian nontrivial subgroups H: rec(elts, gens, d, exps)
#             elts = sorted positions, gens = positions of independent gens,
#             exps[i] = exponent vector of elts[i] w.r.t. gens
#  cent[i]  : positions of Z_G(H_i)
#  allsubs  : all subgroups of G as sorted position lists (candidates for Y)
BCDirectData := function(G)
  local els, pos, gensG, conj, subs, allsubs, K, t, pl, s, ig, seen, sg;
  els := AsSSortedList(G);
  pos := x -> Position(els, x);
  sg := SmallGeneratingSet(G);
  conj := List(sg, a -> List(els, x -> pos(a * x * a^-1)));
  allsubs := [];
  subs := [];
  seen := [];                       # sorted position lists already recorded
  for K in List(ConjugacyClassesSubgroups(G), Representative) do
    for t in RightTransversal(G, Normalizer(G, K)) do
      s  := K^t;
      pl := Set(List(AsList(s), pos));
      if not pl in seen then
        AddSet(seen, pl);
        Add(allsubs, pl);
        if Size(s) > 1 and IsAbelian(s) then
          ig := IndependentGeneratorsOfAbelianGroup(s);
          Add(subs, rec(elts := pl,
                        gens := List(ig, pos),
                        d := List(ig, Order),
                        exps := List(pl, i -> IndependentGeneratorExponents(s, els[i])),
                        cent := Set(List(AsList(Centralizer(G, s)), pos))));
        fi;
      fi;
    od;
  od;
  return rec(n := Size(G), conj := conj, subs := subs, allsubs := allsubs);
end;
