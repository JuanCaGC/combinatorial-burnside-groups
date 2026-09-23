# Optional adapter; the existing BurnsideC module and old path are unchanged.
# Usage: include("tomlib.jl"); st = bc_structure_tom(9); bc(st, 2)
include(joinpath(@__DIR__, "BurnsideC.jl"))
using .BurnsideC, Oscar

function bc_structure_tom(n::Integer)
    load_gap!()
    GAP.Globals.Read(GAP.GapObj(joinpath(@__DIR__, "bc_structure_tom.g")))
    t = @elapsed raw = GAP.gap_to_julia(GAP.Globals.BCStructureTom(n); recursive=true)
    hcl = BurnsideC.HClass[]
    for h in raw
        push!(hcl, BurnsideC.HClass(h[:Hdesc], Int.(h[:d]), String.(h[:Hgens]), Int(h[:classsize]),
                                  Int(h[:Csize]), Int(h[:Nsize]), h[:pairs]))
    end
    tom = GAP.Globals.TableOfMarks(GAP.GapObj("S$n"))
    return BurnsideC.BCStruct("S$n", Int(GAP.Globals.Size(GAP.Globals.UnderlyingGroup(tom))), hcl, t)
end
