include("BurnsideC.jl")
using .BurnsideC, Oscar, Printf
const B=BurnsideC
for p in [2,3,5]
    a = first(a for a in 1:p-1 if length(Set(powermod(a,k,p) for k in 0:p-2))==p-1)
    ctx=B.CharCtx([p])
    generator=B.char_perm(ctx,reshape([a],1,1))
    full=B.perm_closure([generator])
    neg=B.perm_closure([B.char_perm(ctx,reshape([-1],1,1))])
    @assert length(full)==p-1 && all(x in full for x in neg)
    println("ACTION p=$p primitive_root=$a generator=$generator full=$full neg=$neg")
    for n in 1:3
        t=@elapsed begin
            un=first(B.bn_quotient([p],n,Vector{Int}[]))
            pm=first(B.bn_quotient([p],n,neg))
            fu=first(B.bn_quotient([p],n,full))
        end
        if n==2
            @assert un==Dict(2=>ab("0"),3=>ab("Z"),5=>ab("Z^2"))[p]
            @assert pm==Dict(2=>ab("0"),3=>ab("Z/2"),5=>ab("(Z/2)^2"))[p]
        end
        @printf("CYCLIC\t%d\t%d\t%s\t%s\t%s\t%.6f\n",p,n,string(un),string(pm),string(fu),t)
    end
end
println("CHECK: all six n=2 guide comparisons passed; minus-one closure contained in full closure")
