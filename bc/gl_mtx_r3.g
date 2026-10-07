BCClosure := function(gs, rs, reverse)
    local id, rid, steps, rsteps, dict, queue, head, g, rg, h, rh, known, i, contradictions, edges;
    id := One(gs[1]);
    rid := One(rs[1]);
    steps := Concatenation(gs, List(gs, Inverse));
    rsteps := Concatenation(rs, List(rs, Inverse));
    dict := NewDictionary(id, true);
    AddDictionary(dict, id, rid);
    queue := [id];
    head := 1;
    contradictions := 0;
    edges := 0;
    while head <= Length(queue) do
        g := queue[head];
        head := head + 1;
        rg := LookupDictionary(dict, g);
        for i in [1..Length(steps)] do
            h := g * steps[i];
            if reverse then rh := rsteps[i] * rg;
            else rh := rg * rsteps[i]; fi;
            known := LookupDictionary(dict, h);
            if known = fail then
                AddDictionary(dict, h, rh);
                Add(queue, h);
            elif known <> rh then
                contradictions := contradictions + 1;
            fi;
            edges := edges + 1;
        od;
    od;
    return rec(dict := dict, size := Length(queue), contradictions := contradictions, edges := edges);
end;;

BCBrauerValue := function(a, ord, p)
    local degree, field, root, id, k, multiplicity, total, dims;
    if ord = 1 then return [Length(a), [Length(a)]]; fi;
    degree := OrderMod(p, ord);
    field := GF(p^degree);
    root := Z(p^degree)^((p^degree-1)/ord);
    id := IdentityMat(Length(a), field);
    total := 0;
    dims := [];
    for k in [0..ord-1] do
        multiplicity := Length(a) - RankMat(a - root^k * id);
        Add(dims, multiplicity);
        total := total + multiplicity * E(ord)^k;
    od;
    if Sum(dims) <> Length(a) then Error("eigenspaces do not exhaust module"); fi;
    return [total, dims];
end;;

BCAnalyse := function(gs, rs, p, r)
    local g, hom, anti, mats, genuine, m, irr, absirr, factors, dual, equivalent,
          syl, sg, fixed, id, cls, c, ord, value, expected, comparisons, start, output, direct, pair, steps, x, y, rr, hr, ar, hm, am, symmetry, fixes, explains;
    start := Runtime();
    output := OutputTextFile(Concatenation("gl_mtx_r",String(r),"_gap_raw.txt"),false);
    SetPrintFormattingStatus(output,false);
    g := Group(gs);
    hom := BCClosure(gs, rs, false);
    anti := BCClosure(gs, rs, true);
    PrintTo(output,"GAP_VERSION ", GAPInfo.Version, "\n");
    PrintTo(output,"CONVENTION hom_closure=",hom.size," hom_contradictions=",hom.contradictions," hom_edges=",hom.edges,"\n");
    PrintTo(output,"CONVENTION anti_closure=",anti.size," anti_contradictions=",anti.contradictions," anti_edges=",anti.edges,"\n");
    if hom.size <> Size(g) or anti.size <> Size(g) then Error("incomplete closure"); fi;
    if IsBound(BCdirect) then
        direct := NewDictionary(One(gs[1]),true);
        hm := 0;
        am := 0;
        for pair in BCdirect do
            AddDictionary(direct,pair[1],pair[2]);
            if LookupDictionary(hom.dict,pair[1]) <> pair[2] then hm := hm+1; fi;
            if LookupDictionary(anti.dict,pair[1]) <> pair[2] then am := am+1; fi;
        od;
        steps := Concatenation(gs,List(gs,Inverse));
        hr := 0;
        ar := 0;
        for pair in BCdirect do
            x := pair[1];
            rr := pair[2];
            for y in steps do
                if LookupDictionary(direct,x*y) <> rr*LookupDictionary(direct,y) then hr := hr+1; fi;
                if LookupDictionary(direct,x*y) <> LookupDictionary(direct,y)*rr then ar := ar+1; fi;
            od;
        od;
        PrintTo(output,"DIRECT_ACTION hom_assignment_mismatches=",hm," anti_assignment_mismatches=",am," hom_product_mismatches=",hr," anti_product_mismatches=",ar," edges=",Length(BCdirect)*Length(steps),"\n");
        if am <> 0 or ar <> 0 then Error("direct action does not match anti convention"); fi;
        symmetry := gs[3];
        fixes := ForAll(gs,x -> symmetry*TransposedMat(x)*symmetry=x);
        explains := ForAll(BCdirect,pair -> LookupDictionary(hom.dict,pair[1])=LookupDictionary(anti.dict,symmetry*TransposedMat(pair[1])*symmetry));
        PrintTo(output,"BFS_AMBIGUITY map_S_transpose_g_S_fixes_generators=",fixes," explains_both_assignments=",explains,"\n");
        if not fixes or not explains then Error("BFS ambiguity explanation failed"); fi;
    fi;
    if anti.contradictions = 0 then
        mats := List(rs, TransposedMat);
        PrintTo(output,"SELECTED anti_homomorphism. GAP receives transposes of row matrices\n");
    elif hom.contradictions = 0 then
        mats := rs;
        PrintTo(output,"SELECTED homomorphism. GAP receives row matrices\n");
    else Error("neither convention is consistent"); fi;
    genuine := BCClosure(gs, mats, false);
    if genuine.contradictions <> 0 then Error("transformed homomorphism is inconsistent"); fi;
    PrintTo(output,"GENUINE_HOM closure=",genuine.size," contradictions=",genuine.contradictions," edges=",genuine.edges," image_order=",Size(Group(mats)),"\n");
    m := GModuleByMats(mats, GF(p));
    irr := MTX.IsIrreducible(m);
    absirr := MTX.IsAbsolutelyIrreducible(m);
    factors := MTX.CompositionFactors(m);
    dual := MTX.DualModule(m);
    equivalent := MTX.IsEquivalent(m, dual);
    PrintTo(output,"MTX dimension=",MTX.Dimension(m)," irreducible=",irr," absolutely_irreducible=",absirr," factor_dimensions=",List(factors,MTX.Dimension)," self_dual=",equivalent,"\n");
    syl := SylowSubgroup(g,p);
    sg := GeneratorsOfGroup(syl);
    id := One(mats[1]);
    fixed := Length(id)-RankMat(Concatenation(List(sg, x -> TransposedMat(LookupDictionary(genuine.dict,x)-id))));
    PrintTo(output,"SYLOW_FIXED subgroup_order=",Size(syl)," dimension=",fixed," Steinberg_expected=1 match=",fixed=1,"\n");
    comparisons := true;
    cls := ConjugacyClasses(g);
    for c in cls do
        ord := Order(Representative(c));
        if ord mod p <> 0 then
            value := BCBrauerValue(LookupDictionary(genuine.dict,Representative(c)),ord,p);
            PrintTo(output,"BRAUER order=",ord," class_size=",Size(c)," value=",value[1]," eigen_multiplicities=",value[2]);
            if p=2 and r=3 then
                if ord=1 then expected:=8;
                elif ord=3 then expected:=-1;
                elif ord=7 then expected:=1;
                else Error("unexpected odd order"); fi;
                PrintTo(output," Steinberg_expected=",expected," match=",value[1]=expected);
                comparisons := comparisons and value[1]=expected;
            fi;
            PrintTo(output,"\n");
        fi;
    od;
    if p=2 and r=3 and not comparisons then Error("Steinberg character mismatch"); fi;
    PrintTo(output,"MTX_ANALYSIS_CPU_SECONDS ",(Runtime()-start)/1000,"\n");
    CloseStream(output);
end;;
