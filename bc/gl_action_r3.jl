include("BurnsideC.jl")
using .BurnsideC, Oscar
const B = BurnsideC
include("gl_tracked_elimination.jl")
matrows(A) = [[Int(A[i,j]) for j in 1:ncols(A)] for i in 1:nrows(A)]
gapmat(A) = "[" * join(("[" * join(row,",") * "]" for row in matrows(A)),",") * "]"
function in_diagonal_lattice(X,D)
    all((j > nrows(D) || iszero(D[j,j])) ? iszero(X[i,j]) : iszero(mod(X[i,j],D[j,j])) for i in 1:nrows(X), j in 1:ncols(X))
end
function check_snf(A,U,V,D)
    @assert U*A*V == D && abs(det(U)) == 1 && abs(det(V)) == 1
    @assert all(i == j || iszero(D[i,j]) for i in 1:nrows(D), j in 1:ncols(D))
    ds = [abs(D[j,j]) for j in 1:min(nrows(D),ncols(D))]
    @assert all(iszero(ds[j]) ? iszero(ds[j+1]) : iszero(mod(ds[j+1],ds[j])) for j in 1:length(ds)-1)
end
function group_generators(p,r)
    r >= 2 || error("rank must be at least two")
    T = Matrix{Int}(I,r,r)
    T[1,2] = 1
    C = zeros(Int,r,r)
    for j in 1:r
        C[mod1(j+1,r),j] = 1
    end
    S = Matrix{Int}(I,r,r)
    S[1,1] = S[2,2] = 0
    S[1,2] = S[2,1] = 1
    mats = [T,C,S]
    labels = ["T","C","S"]
    if p != 2
        a = Int(GAP.evalstr("Int(Z($p))"))
        D = Matrix{Int}(I,r,r)
        D[1,1] = a
        push!(mats,D)
        push!(labels,"D")
    end
    mats,labels
end
using LinearAlgebra: I
function run_action(p,r,cert)
    n = r
    tstart = time()
    mats,labels = group_generators(p,r)
    gexpr(a) = gapmat(matrix(ZZ,a)) * "*One(GF($p))"
    order = Int(GAP.evalstr("Size(Group([$(join(gexpr.(mats),","))]))"))
    fullorder = Int(GAP.evalstr("Size(GL($r,$p))"))
    println("GENERATORS p=$p r=$r labels=$labels generated_order=$order GL_order=$fullorder")
    @assert order == fullorder
    d = fill(p,r)
    ctx = B.CharCtx(d)
    candidates = B.multisets(ctx.m,n)
    gens = filter(ms -> B.generates_all(ctx,ms),candidates)
    rows,N = B.bn_quotient(d,n,Vector{Int}[]; return_presentation=true)
    @assert N == length(gens)
    println("PRESENTATION characters=$(ctx.m) candidates=$(length(candidates)) generating_tuples=$N relations=$(length(rows)) seconds=$(time()-tstart)")
    flush(stdout)
    col = Dict(g=>i for (i,g) in enumerate(gens))
    t = time()
    A,U0,V0,D0 = B.certify_snf(rows,N)
    check_snf(A,U0,V0,D0)
    println("FULL_SNF seconds=$(time()-t) certificate=true")
    flush(stdout)
    t = time()
    E,J,M,survivors,trace = tracked_elimination(deepcopy(rows),N)
    q = length(survivors)
    if nrows(M) == 0
        D = M
        U = identity_matrix(ZZ,0)
        V = identity_matrix(ZZ,q)
    else
        D,U,V = snf_with_transform(M)
    end
    check_snf(M,U,V,D)
    @assert J*E == identity_matrix(ZZ,q)
    @assert in_diagonal_lattice(A*E*V,D)
    @assert in_diagonal_lattice(M*J*V0,D0)
    @assert in_diagonal_lattice((identity_matrix(ZZ,N)-E*J)*V0,D0)
    diagonal = [j <= nrows(D) ? Int(D[j,j]) : 0 for j in 1:q]
    keep = findall(x -> abs(x) != 1,diagonal)
    moduli = diagonal[keep]
    group = AbGroup(count(==(0),moduli),abs.(filter(x -> abs(x)>1,moduli)))
    @assert group == first(B.bn_quotient(d,n,Vector{Int}[]))
    Vinv = inv(V)
    EV = E*V
    Q = EV[:,keep]
    L = (Vinv*J)[keep,:]
    @assert L*Q == identity_matrix(ZZ,length(keep))
    println("ELIMINATION_AND_QUOTIENT seconds=$(time()-t)")
    println("ACTION_CASE p=$p r=$r n=$n B=$group ngens=$N nrels=$(length(rows)) pivots=$(length(trace)) residual=$(size(M)) moduli=$moduli")
    println("FINAL_PROJECTION_Q=",matrows(Q))
    println("FINAL_LIFTS_L=",matrows(L))
    actions = Any[]
    charperms = Vector{Int}[]
    for (label,a) in zip(labels,mats)
        af = matrix(GF(p),a)
        cm = [Int(lift(ZZ,transpose(inv(af))[i,j])) for i in 1:r,j in 1:r]
        perm = B.char_perm(ctx,cm)
        push!(charperms,perm)
        tp = [col[sort(perm[g])] for g in gens]
        # Row indexing by tp is exactly left multiplication by the tuple matrix P.
        PEV = EV[tp,:]
        K = Vinv*J*PEV
        @assert in_diagonal_lattice(A*PEV,D)
        @assert in_diagonal_lattice(PEV-EV*K,D)
        R = K[keep,keep]
        for j in eachindex(moduli),i in eachindex(moduli)
            iszero(moduli[j]) || (R[i,j] = mod(R[i,j],abs(moduli[j])))
        end
        push!(actions,R)
        println("GEN $label group_matrix=",matrows(matrix(ZZ,a))," character_matrix=",matrows(matrix(ZZ,cm))," tuple_permutation=$tp final_row_matrix=",matrows(R))
    end
    t = time()
    closure = B.perm_closure(charperms)
    @assert length(closure) == fullorder
    use_field = r >= 4 && all(x -> abs(x)==p,moduli)
    LF = use_field ? matrix(GF(p),L) : nothing
    QF = use_field ? matrix(GF(p),Q) : nothing
    function action(perm)
        tp = [col[sort(perm[g])] for g in gens]
        use_field ? LF*QF[tp,:] : L*Q[tp,:]
    end
    congruent(X,Y) = use_field ? X == Y : all(iszero(moduli[j]) ? X[i,j] == Y[i,j] : iszero(mod(X[i,j]-Y[i,j],abs(moduli[j]))) for i in 1:nrows(X),j in 1:ncols(X))
    println("CLOSURE_START elements=$(length(closure)) field_arithmetic=$use_field")
    flush(stdout)
    cached = Dict(Tuple(g)=>action(g) for g in closure)
    checks = 0
    for g in closure,h in charperms
        @assert congruent(cached[Tuple(g)]*cached[Tuple(h)],cached[Tuple(h[g])])
        checks += 1
    end
    println("CHECKS full_SNF_certificate=true residual_SNF_certificate=true quotient_maps_inverse=true relation_lattice_preserved=true closure=$(length(closure)) action_products=$checks/$checks seconds=$(time()-t)")
    for (label,x) in [("A",A),("U_full",U0),("V_full",V0),("D_full",D0),("E",E),("J",J),("M",M),("U",U),("V",V),("D",D),("Q",Q),("L",L)]
        println(cert,label,"=",matrows(x))
    end
    println(cert,"TUPLES=",gens)
    println(cert,"CHARACTERS=",ctx.chars)
    println(cert,"PIVOTS=",[(c,e,sort(collect(row))) for (c,e,row) in trace])
    open("gl_action_r$(r)_data.g","w") do io
        println(io,"BCp := $p;; BCr := $r;;")
        println(io,"BCmats := [",join(gexpr.(mats),","),"];;")
        println(io,"BCrows := [",join([gapmat(R)*"*One(GF($p))" for R in actions],","),"];;")
        println(io,"BCmoduli := ",repr(moduli),";;")
        if r == 3
            println(io,"BCdirect := [")
            for (idx,perm) in enumerate(closure)
                cm = matrix(GF(p),r,r,[ctx.chars[perm[1+p^(j-1)]][i] for i in 1:r for j in 1:r])
                gm = transpose(inv(cm))
                gi = matrix(ZZ,r,r,[lift(ZZ,gm[i,j]) for i in 1:r for j in 1:r])
                println(io,"[",gapmat(gi),"*One(GF($p)),",gapmat(cached[Tuple(perm)]),"*One(GF($p))]",idx==length(closure) ? "" : ",")
            end
            println(io,"];;")
        end
    end
    println("ACTION_SECONDS p=$p r=$r time=$(time()-tstart)")
    flush(stdout)
end
if abspath(PROGRAM_FILE) == abspath(joinpath(@__DIR__,"gl_bootstrap.jl")) && get(ENV,"GL_ACTION_LIBRARY","0") != "1"
    r = isempty(ARGS) ? 3 : parse(Int,ARGS[1])
    open("gl_action_r$(r)_certificates.txt","w") do cert
        run_action(2,r,cert)
    end
end
