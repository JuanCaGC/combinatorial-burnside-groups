# scaling.jl -- timing probe:  julia --project=. scaling.jl <case> <n1> [n2 ...]
include(joinpath(@__DIR__, "BurnsideC.jl"))
using .BurnsideC, Oscar, Printf
cases = Dict(
  "S7" => () -> symmetric_group(7), "S8" => () -> symmetric_group(8),
  "S9" => () -> symmetric_group(9), "S10" => () -> symmetric_group(10),
  "A7" => () -> alternating_group(7), "A8" => () -> alternating_group(8),
  "C2^4" => () -> GAP.evalstr("ElementaryAbelianGroup(IsPermGroup, 16)"),
  "C2^5" => () -> GAP.evalstr("ElementaryAbelianGroup(IsPermGroup, 32)"),
  "C3^3" => () -> GAP.evalstr("ElementaryAbelianGroup(IsPermGroup, 27)"),
  "He7" => () -> GAP.evalstr("Image(IsomorphismPermGroup(ExtraspecialGroup(343,\"+\")))"),
  "D13" => () -> dihedral_group(PermGroup, 26), "D31" => () -> dihedral_group(PermGroup, 62),
  "PSL29" => () -> GAP.evalstr("PSL(2,9)"), "PSL28" => () -> GAP.evalstr("PSL(2,8)"),
  "He11" => () -> GAP.evalstr("Image(IsomorphismPermGroup(ExtraspecialGroup(1331,\"+\")))"),
  "D101" => () -> dihedral_group(PermGroup, 202),
  "M11" => () -> GAP.evalstr("MathieuGroup(11)"),
)
name = ARGS[1]
G = cases[name]()
st = bc_structure(G; name=name)
@printf("%-6s |G|=%d  GAP enumeration: %.1fs, %d classes [H,Y]\n", name, st.order, st.gap_seconds, npairs(st)); flush(stdout)
for n in parse.(Int, ARGS[2:end])
    r = bc(st, n)
    @printf("   n=%d  %.1fs   BC_%d = %s\n", n, r.seconds, n, r.total); flush(stdout)
end
