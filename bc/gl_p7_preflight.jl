include("BurnsideC.jl")
using .BurnsideC, Oscar
p=7
primitive=first(a for a in 1:p-1 if length(Set(powermod(a,k,p) for k in 0:p-2))==p-1)
order=Int(GAP.evalstr("Size(Group([[1,1],[0,1]]*Z(7)^0, [[$primitive,0],[0,1]]*Z(7)^0, [[0,1],[1,0]]*Z(7)^0))"))
@assert primitive==3 && order==2016
println("PREFLIGHT primitive_root=$primitive generator_group_order=$order expected=2016")
flush(stdout)
for p in parse.(Int,ARGS)
    println("QUOTIENT_START p=$p")
    flush(stdout)
    t=time()
    group,info=BurnsideC.bn_quotient([p,p],2,Vector{Int}[])
    println("QUOTIENT p=$p group=$group torsion=$(group.pp) free_rank=$(group.free) residual=$info seconds=$(time()-t)")
    flush(stdout)
end
