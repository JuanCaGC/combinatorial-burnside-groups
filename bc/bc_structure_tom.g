# Additive TomLib alternative; bc_structure.g remains unchanged.
# Read bc_structure_tom.g, then call BCStructureTom(n).
# No subgroup-enumeration fallback is used for unavailable tables.
BCStructureTom := function(n)
  local tom, G, orders, i, res, H, gens, d, C, N, Ys, inter, orbs, orb, Y, S, mats, g, M, pairs, desc;
  if not IsPosInt(n) then Error("BCStructureTom: n must be a positive integer"); fi;
  if LoadPackage("tomlib") = fail then
    Error("BCStructureTom: GAP package tomlib is unavailable");
  fi;
  tom := TableOfMarks(Concatenation("S", String(n)));
  if tom = fail then
    Error("BCStructureTom: no TomLib table for S", n);
  fi;
  G := UnderlyingGroup(tom);
  orders := OrdersTom(tom);
  res := [];
  for i in [1..Length(orders)] do
    if orders[i] > 1 then
      H := RepresentativeTom(tom, i);
      if IsAbelian(H) then
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
    fi;
  od;
  return res;
end;
