include("BurnsideC.jl")
using .BurnsideC, Oscar
const B=BurnsideC
include("gl_tracked_elimination.jl")
matrows(A)=[[Int(A[i,j]) for j in 1:ncols(A)] for i in 1:nrows(A)]
gapmat(A)="["*join(("["*join(row,",")*"]" for row in matrows(A)),",")*"]"
function in_diagonal_lattice(X,D)
    for j in 1:ncols(X)
        d=j<=nrows(D) ? D[j,j] : ZZ(0)
        for i in 1:nrows(X)
            (iszero(d) ? iszero(X[i,j]) : iszero(mod(X[i,j],d))) || return false
        end
    end
    return true
end
function run_action(p, cert)
    # Column-vector group matrices A act on character columns by A^(-transpose).
    Atrans=[1 1;0 1]; Adiag=[p==2 ? 1 : 2 0;0 1]; Aswap=[0 1;1 0]
    mats=[Atrans,Adiag,Aswap]; labels=["T","D","S"]
    gexpr(A)=gapmat(matrix(ZZ,A))*"*One(GF($p))"
    td=GAP.evalstr("Size(Group([$(gexpr(Atrans)),$(gexpr(Adiag))]))")
    allorder=GAP.evalstr("Size(Group([$(join(gexpr.(mats),","))]))")
    fullorder=GAP.evalstr("Size(GL(2,$p))")
    println("GENERATORS p=$p |<T,D>|=$td |<T,D,S>|=$allorder |GL|=$fullorder")
    @assert allorder==fullorder
    ctx=B.CharCtx([p,p]); n=2
    gens=[ms for ms in B.multisets(ctx.m,n) if B.generates_all(ctx,ms)]
    rows,N=B.bn_quotient([p,p],n,Vector{Int}[];return_presentation=true)
    @assert N==length(gens)
    col=Dict(g=>i for (i,g) in enumerate(gens))
    A,U0,V0,D0=B.certify_snf(rows,N)
    @assert U0*A*V0==D0 && abs(det(U0))==1 && abs(det(V0))==1
    E,J,M,survivors,trace=tracked_elimination(deepcopy(rows),N)
    q=length(survivors)
    if nrows(M)==0
        D=M; U=identity_matrix(ZZ,0); V=identity_matrix(ZZ,q)
    else
        D,U,V=snf_with_transform(M)
    end
    @assert U*M*V==D && abs(det(U))==1 && abs(det(V))==1
    @assert J*E==identity_matrix(ZZ,q)
    @assert in_diagonal_lattice(A*E*V,D)
    @assert in_diagonal_lattice(M*J*V0,D0)
    @assert in_diagonal_lattice((identity_matrix(ZZ,N)-E*J)*V0,D0)
    diagonal=[j<=nrows(D) ? Int(D[j,j]) : 0 for j in 1:q]
    keep=findall(d->abs(d)!=1,diagonal)
    moduli=diagonal[keep]
    group=AbGroup(count(==(0),moduli),abs.(filter(d->abs(d)>1,moduli)))
    @assert group==first(B.bn_quotient([p,p],2,Vector{Int}[]))
    Vinv=inv(V)
    # Row i of Q expresses old tuple i in final coordinates; row j of L is
    # an integral tuple combination lifting final generator j.
    Q=(E*V)[:,keep]; L=(Vinv*J)[keep,:]
    @assert L*Q==identity_matrix(ZZ,length(keep))
    println("ACTION_CASE p=$p n=2 B=$group ngens=$N nrels=$(length(rows)) pivots=$(length(trace)) residual=$(size(M)) moduli=$moduli")
    println("CHARACTERS=",ctx.chars)
    println("TUPLES=",gens)
    println("PIVOTS=",[(c,e,sort(collect(row))) for (c,e,row) in trace])
    println("SURVIVORS=",survivors," residual=",matrows(M)," V=",matrows(V))
    println("FINAL_PROJECTION_Q=",matrows(Q))
    println("FINAL_LIFTS_L=",matrows(L))
    actions=Any[]; charmatrices=Matrix{Int}[]
    for (label,a) in zip(labels,mats)
        # Invert over GF(p), then transpose: exactly the left action in notes §2.
        af=matrix(GF(p),a)
        cm=[Int(lift(ZZ,transpose(inv(af))[i,j])) for i in 1:2,j in 1:2]
        push!(charmatrices,cm)
        perm=B.char_perm(ctx,cm)
        tupleperm=[col[sort(perm[g])] for g in gens]
        P=zero_matrix(ZZ,N,N)
        for i in 1:N; P[i,tupleperm[i]]=1; end
        K=Vinv*J*P*E*V
        # Prove every original relation maps into the same relation lattice.
        @assert in_diagonal_lattice(A*P*E*V,D)
        R=K[keep,keep]
        for j in eachindex(moduli)
            moduli[j]==0 && continue
            for i in eachindex(moduli); R[i,j]=mod(R[i,j],abs(moduli[j])); end
        end
        @assert in_diagonal_lattice(P*E*V-E*V*K,D)
        push!(actions,R)
        println("GEN $label group_matrix=$a character_matrix=$cm tuple_permutation=$tupleperm final_row_matrix=",matrows(R))
    end
    # Independently enumerate the complete GL2 matrix group on character columns,
    # and verify action composition for every element and generating matrix.
    closure=B.perm_closure([B.char_perm(ctx,c) for c in charmatrices])
    @assert length(closure)==Int(fullorder)
    function action(perm)
        P=zero_matrix(ZZ,N,N)
        for i in 1:N; P[i,col[sort(perm[gens[i]])]]=1; end
        L*P*Q
    end
    congruent(X,Y)=all(iszero(moduli[j]) ? X[i,j]==Y[i,j] : mod(X[i,j]-Y[i,j],abs(moduli[j]))==0 for i in 1:nrows(X),j in 1:ncols(X))
    ng=0
    for g in closure, h in [B.char_perm(ctx,c) for c in charmatrices]
        # h[g] means h after g; row matrices multiply in application order.
        @assert congruent(action(g)*action(h),action(h[g]))
        ng+=1
    end
    println("CHECKS p=$p full_SNF_certificate=true residual_SNF_certificate=true quotient_maps_inverse=true relation_lattice_preserved=true action_products=$ng/$ng")
    if p==2
        # Intertwiner with the row action of the contragredient natural module.
        found=nothing
        for bits in 0:15
            W=matrix(ZZ,2,2,[(bits>>k)&1 for k in 0:3])
            isodd(Int(det(W))) || continue
            if all(all(iszero(mod((R*W-W*matrix(ZZ,transpose(cm)))[i,j],2)) for i in 1:2,j in 1:2) for (R,cm) in zip(actions,charmatrices))
                found=W; break
            end
        end
        @assert found!==nothing
        println("VERIFIED_F2_CONTRAGREDIENT_NATURAL_INTERTWINER W=",matrows(found)," satisfies R_g W = W (g^-T)^T mod 2")
    end
    println(cert,"p=$p")
    for (label,x) in [("A",A),("U_full",U0),("V_full",V0),("D_full",D0),("E",E),("J",J),("M",M),("U",U),("V",V),("D",D)]
        println(cert,label,"=",matrows(x))
    end
end
open("gl_action_certificates.txt","w") do cert
    for p in [2,3]
        elapsed=@elapsed run_action(p,cert)
        println("ACTION_SECONDS p=$p time=$elapsed");flush(stdout)
    end
end
