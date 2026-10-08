# Abelian group of the top piece B_2(F_p^2) for p = 3,...,23, via the untracked quotient routine.
# Reproduces the torsion / free-rank table in REPORT.md.
include("BurnsideC.jl")
using .BurnsideC
const B = BurnsideC
for p in (3,5,7,11,13,17,19,23)
    t = @elapsed g = first(B.bn_quotient([p,p], 2, Vector{Int}[]))
    println("p=$p  top piece = ", g, "   [", round(t,digits=2), "s]")
    flush(stdout)
end
