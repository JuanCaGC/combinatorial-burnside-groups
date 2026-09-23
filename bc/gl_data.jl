include("BurnsideC.jl")
using .BurnsideC, Oscar, Printf
const B = BurnsideC
p, r = parse.(Int, ARGS)
println("START p=$p r=$r"); flush(stdout)
G = GAP.evalstr("ElementaryAbelianGroup($(p^r))")
t = @elapsed st = bc_structure(G; name="F$(p)^$r")
println("STRUCT p=$p r=$r pairs=$(npairs(st)) wall=$t gap=$(st.gap_seconds)"); flush(stdout)
for n in 1:3
    if (p,r,n) == (5,3,3)
        println("SKIP p=5 r=3 n=3 multisets=333375 scale_limit=100000")
        continue
    end
    println("BEGIN n=$n"); flush(stdout)
    result = bc(st, n)
    top = only(s.value for s in result.summands if length(s.d)==r && s.Ysize==p^r)
    @printf("DATA\t%d\t%d\t%d\t%s\t%d\t%.6f\t%.6f\t%s\t%d\n",p,r,n,string(result.total),result.npairs,t,result.seconds,string(top),top.free)
    flush(stdout)
end
