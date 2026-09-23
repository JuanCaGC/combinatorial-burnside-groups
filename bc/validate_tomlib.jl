include(joinpath(@__DIR__, "tomlib.jl"))
using Printf
function histogram(st)
    counts = Dict{Tuple,Int}()
    for h in st.hclasses
        d = Tuple(sort(h.d))
        counts[d] = get(counts, d, 0) + 1
    end
    join(["$(collect(d)) => $(counts[d])" for d in sort(collect(keys(counts)))], "; ")
end
function exact_classes(old, new, n)
    G = gapobj(symmetric_group(n))
    groups(st) = [GAP.evalstr("Group([" * join(h.Hgens, ",") * "])") for h in st.hclasses]
    a, b = groups(old), groups(new)
    matches = [findall(j -> sort(old.hclasses[i].d) == sort(new.hclasses[j].d) &&
                         GAP.Globals.IsConjugate(G, a[i], b[j]), eachindex(b)) for i in eachindex(a)]
    @assert all(length(m) == 1 for m in matches) "Conjugacy mismatch: $matches"
    @assert sort(only.(matches)) == collect(eachindex(b))
    true
end
if isempty(ARGS) || ARGS[1] == "small"
    old, new = Dict(), Dict()
    println("STEP 1: S4-S8 H-class comparison")
    for n in 4:8
        old[n] = bc_structure(symmetric_group(n); name="S$n")
        new[n] = bc_structure_tom(n)
        a, b = histogram(old[n]), histogram(new[n])
        println("S$n old H=$(length(old[n].hclasses)) new H=$(length(new[n].hclasses))")
        println("  old d multiplicities: ", a)
        println("  new d multiplicities: ", b)
        @assert a == b "STOP: d multiplicity mismatch S$n"
        @assert exact_classes(old[n], new[n], n)
        @printf("  exact conjugacy bijection: PASS; pairs old=%d new=%d; structure seconds old=%.6f new=%.6f\n", npairs(old[n]), npairs(new[n]), old[n].gap_seconds, new[n].gap_seconds)
        flush(stdout)
    end
    println("STEP 2: old AND TomLib structures through unchanged bc(st,2)")
    expected = ["(Z/2)^3", "(Z/2)^6 × Z/4", "(Z/2)^31 × (Z/4)^3 × Z/8",
                "(Z/2)^57 × (Z/4)^12 × (Z/8)^2 × Z/3",
                "(Z/2)^290 × (Z/4)^30 × (Z/8)^6 × Z/16 × (Z/3)^2 × Z"]
    for n in 4:8
        a, b = bc(old[n], 2), bc(new[n], 2)
        println("S$n expected: ", expected[n-3])
        println("  old: ", format_ab(a.total))
        println("  TomLib: ", format_ab(b.total))
        @assert a.total == b.total == ab(expected[n-3])
        @printf("  PASS; bc seconds old=%.6f new=%.6f\n", a.seconds, b.seconds)
        flush(stdout)
    end
else
    n = parse(Int, ARGS[1])
    load_gap!()
    @assert GAP.Globals.LoadPackage(GAP.GapObj("tomlib")) == true
    t = @elapsed tom = GAP.Globals.TableOfMarks(GAP.GapObj("S$n"))
    @assert tom != GAP.Globals.fail
    GAP.evalstr("BCTomEnum := function(t) local o; o:=OrdersTom(t); return Filtered(List(Filtered([1..Length(o)],i->o[i]>1),i->RepresentativeTom(t,i)),IsAbelian); end;")
    te = @elapsed hs = GAP.Globals.BCTomEnum(tom)
    @printf("S%d NEW/UNVERIFIED: table load=%.6fs H-enumeration/filter=%.6fs H-classes=%d\n", n, t, te, length(hs))
    flush(stdout)
    st = bc_structure_tom(n)
    @printf("S%d full structure=%.6fs H-classes=%d pairs=%d\n", n, st.gap_seconds, length(st.hclasses), npairs(st))
    flush(stdout)
    r = bc(st, 2)
    println("S$n NEW/UNVERIFIED BC_2 = ", format_ab(r.total))
    @printf("S%d bc(st,2)=%.6fs\n", n, r.seconds)
    flush(stdout)
end
