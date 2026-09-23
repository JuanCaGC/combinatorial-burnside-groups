"""
BurnsideC -- combinatorial Burnside groups BC_n(G) of Tschinkel-Yang-Zhang
(arXiv:2112.12801), computed with OSCAR/GAP.

Two independent implementations are provided:

  * `bc(G, n)`         Theorem 5.2:  BC_n(G) = (+)_{[H,Y]} B_n(H)/(C_(H,Y)).
                       Scales to S_7, S_8, ...
  * `bc_direct(G, n)`  Definition-level: generators (H,Y,beta) of SC_n(G) and
                       relations (C), (V), (B2) *including the Theta_2 term*,
                       with no use of Theorem 5.2.  Small groups only; it exists
                       to validate the first implementation (and the theorem).

Conventions (Lemma 5.1 of the paper).  For an abelian H with H^ = Hom(H,C^x)
written additively, a generator of B_n(H) is a multiset of n characters in H^
(zeros allowed = padding) that generate H^.  Relations:
  (B)  b_i != b_j, both nonzero:   beta = beta_1 + beta_2,
         beta_1 = (.., b_i-b_j, ..)   beta_2 = (.., b_j-b_i, ..)
  (B=) b_i == b_j != 0:            beta = beta with one copy of b_i replaced by 0
  (V)  b_i + b_j = 0, both nonzero (i != j as positions):   beta = 0
  (C)  beta = beta^g for g in N_G(H) n N_G(Y)   (acting through Aut(H))
Zero entries are never blown up: doing so with b_j = 0 only reproduces (V), and
with b_i = b_j = 0 would (wrongly) force beta = 2*beta.
"""
module BurnsideC

using Oscar
using Printf

export bc, bc_structure, bc_direct, AbGroup, ab, format_ab, load_gap!, gapobj, npairs

const GAPFILE = joinpath(@__DIR__, "bc_structure.g")
const _gap_loaded = Ref(false)

function load_gap!()
    if !_gap_loaded[]
        GAP.evalstr("Read(\"$(GAPFILE)\");")
        _gap_loaded[] = true
    end
    return nothing
end

# ---------------------------------------------------------------------------
# Finitely generated abelian groups, in the paper's (primary) notation
# ---------------------------------------------------------------------------

"""Z^free x prod (Z/q)^mult   with q running over prime powers."""
struct AbGroup
    free::Int
    pp::Dict{Int,Int}          # prime power q => multiplicity
end

AbGroup() = AbGroup(0, Dict{Int,Int}())

function prime_power_factors(n::Integer)
    out = Int[]
    m = Int(n)
    p = 2
    while p * p <= m
        if m % p == 0
            q = 1
            while m % p == 0
                m ÷= p; q *= p
            end
            push!(out, q)
        end
        p += 1
    end
    m > 1 && push!(out, m)
    return out
end

"""Build from a free rank and a list of invariant factors (each >1)."""
function AbGroup(free::Int, invariants::AbstractVector{<:Integer})
    pp = Dict{Int,Int}()
    for t in invariants, q in prime_power_factors(t)
        pp[q] = get(pp, q, 0) + 1
    end
    return AbGroup(free, pp)
end

function Base.:+(a::AbGroup, b::AbGroup)
    pp = copy(a.pp)
    for (q, m) in b.pp
        pp[q] = get(pp, q, 0) + m
    end
    return AbGroup(a.free + b.free, pp)
end

Base.:(==)(a::AbGroup, b::AbGroup) = a.free == b.free && a.pp == b.pp
Base.hash(a::AbGroup, h::UInt) = hash((a.free, a.pp), h)
Base.iszero(a::AbGroup) = a.free == 0 && isempty(a.pp)

function prime_of(q::Int)
    p = 2
    while q % p != 0
        p += 1
    end
    return p
end

"""Invariant-factor form  d_1 | d_2 | ... | d_k  (torsion part only)."""
function invariant_factors(a::AbGroup)
    byprime = Dict{Int,Vector{Int}}()
    for (q, m) in a.pp
        append!(get!(byprime, prime_of(q), Int[]), fill(q, m))
    end
    for v in values(byprime)
        sort!(v; rev=true)
    end
    k = isempty(byprime) ? 0 : maximum(length, values(byprime))
    inv = [prod((length(v) >= i ? v[i] : 1) for v in values(byprime); init=1) for i in 1:k]
    return sort(inv)
end

function format_ab(a::AbGroup; sep=" × ")
    iszero(a) && return "0"
    parts = String[]
    for q in sort(collect(keys(a.pp)); by=q -> (prime_of(q), q))
        m = a.pp[q]
        s = m == 1 ? "Z/$q" : "(Z/$q)^$m"
        push!(parts, s)
    end
    if a.free == 1
        push!(parts, "Z")
    elseif a.free > 1
        push!(parts, "Z^$(a.free)")
    end
    return join(parts, sep)
end

Base.show(io::IO, a::AbGroup) = print(io, format_ab(a))

"""Parse the paper's notation, e.g. ab("(Z/2)^6 x Z/4"), ab("Z^13 x (Z/2)^7"), ab("0")."""
function ab(s::AbstractString)
    s = strip(s)
    (s == "0" || s == "") && return AbGroup()
    free = 0
    pp = Dict{Int,Int}()
    for tok in split(s, r"\s*[x×]\s*")
        tok = strip(tok)
        if (m = match(r"^Z(?:\^(\d+))?$", tok)) !== nothing
            free += m.captures[1] === nothing ? 1 : parse(Int, m.captures[1])
        elseif (m = match(r"^\(?Z/(\d+)\)?(?:\^(\d+))?$", tok)) !== nothing
            n = parse(Int, m.captures[1])
            mult = m.captures[2] === nothing ? 1 : parse(Int, m.captures[2])
            for q in prime_power_factors(n)
                pp[q] = get(pp, q, 0) + mult
            end
        else
            error("cannot parse abelian-group token '$tok'")
        end
    end
    return AbGroup(free, pp)
end

# ---------------------------------------------------------------------------
# Cokernel of an integer relation matrix: sparse unit-pivot elimination + SNF
# ---------------------------------------------------------------------------

const Row = Dict{Int,Int}

"""
Z^ncols / <rows>.  Repeatedly uses a relation with a coefficient +-1 to
eliminate a generator (this does not change the quotient), then finishes the
small remaining matrix with Smith normal form over Z (Nemo/FLINT).
Returns (AbGroup, remaining_dense_size).
"""
function cokernel_group(rows::Vector{Row}, ncols::Int)
    colrows = Dict{Int,Set{Int}}()
    for (r, row) in enumerate(rows), c in keys(row)
        push!(get!(colrows, c, Set{Int}()), r)
    end
    alive = trues(length(rows))
    neliminated = 0
    changed = true
    while changed
        changed = false
        for r in sortperm(length.(rows))
            alive[r] || continue
            row = rows[r]
            if isempty(row)
                alive[r] = false
                continue
            end
            best = 0; bestcnt = typemax(Int)
            for (c, v) in row
                if abs(v) == 1
                    cnt = length(colrows[c])
                    if cnt < bestcnt
                        best = c; bestcnt = cnt
                    end
                end
            end
            best == 0 && continue
            c = best; ε = row[c]
            for r2 in collect(colrows[c])
                r2 == r && continue
                row2 = rows[r2]
                f = row2[c] * ε
                for (k, v) in row
                    nv = get(row2, k, 0) - f * v
                    if nv == 0
                        delete!(row2, k)
                        delete!(colrows[k], r2)
                    else
                        if !haskey(row2, k)
                            push!(colrows[k], r2)
                        end
                        row2[k] = nv
                    end
                end
            end
            for k in keys(row)
                delete!(colrows[k], r)
            end
            alive[r] = false
            neliminated += 1
            changed = true
        end
    end
    liverows = [rows[r] for r in eachindex(rows) if alive[r] && !isempty(rows[r])]
    cols = sort!(unique!(reduce(vcat, (collect(keys(r)) for r in liverows); init=Int[])))
    ncols_left = ncols - neliminated            # generators not yet eliminated
    if isempty(liverows)
        return AbGroup(ncols_left, Int[]), (0, 0)
    end
    cidx = Dict(c => i for (i, c) in enumerate(cols))
    M = zero_matrix(ZZ, length(liverows), length(cols))
    for (i, row) in enumerate(liverows), (c, v) in row
        M[i, cidx[c]] = ZZ(v)
    end
    S = snf(M)
    diag = [S[i, i] for i in 1:min(size(S)...)]
    nz = [Int(d) for d in diag if !iszero(d)]
    tors = [abs(d) for d in nz if abs(d) > 1]
    return AbGroup(ncols_left - length(nz), tors), size(M)
end

# ---------------------------------------------------------------------------
# Characters of an abelian group H = Z/d_1 x ... x Z/d_k
# ---------------------------------------------------------------------------

"""
Characters of H (H^ ~ H) in additive notation, indexed 1..|H| in mixed radix;
index 1 is the zero character.  A character c = (c_1..c_k) is the homomorphism
g_i |-> c_i/d_i in Q/Z on the chosen independent generators g_i.
"""
struct CharCtx
    d::Vector{Int}
    m::Int
    D::Int                          # lcm(d)
    chars::Vector{Vector{Int}}
    stride::Vector{Int}
    add::Matrix{Int32}
    neg::Vector{Int32}
end

const _ctx_cache = Dict{Vector{Int},CharCtx}()

encode(ctx::CharCtx, c::AbstractVector{<:Integer}) =
    1 + sum(mod(c[i], ctx.d[i]) * ctx.stride[i] for i in eachindex(ctx.d))

function CharCtx(d::Vector{Int})
    get!(_ctx_cache, d) do
        k = length(d)
        stride = ones(Int, k)
        for i in 2:k
            stride[i] = stride[i-1] * d[i-1]
        end
        m = prod(d)
        chars = [[(idx ÷ stride[i]) % d[i] for i in 1:k] for idx in 0:m-1]
        ctx0 = CharCtx(d, m, lcm(d...), chars, stride, zeros(Int32, m, m), zeros(Int32, m))
        for a in 1:m, b in 1:m
            ctx0.add[a, b] = encode(ctx0, chars[a] .+ chars[b])
        end
        for a in 1:m
            ctx0.neg[a] = encode(ctx0, .-chars[a])
        end
        ctx0
    end
end

"""Minimal number of generators of prod Z/d_i: the largest p-rank."""
function min_generators(d::Vector{Int})
    ps = Set(p for q in d for p in prime_power_factors(q) .|> prime_of)
    return maximum((count(q -> q % p == 0, d) for p in ps); init=0)
end

"""Subgroup of H^ generated by the given character indices contains everything?"""
function generates_all(ctx::CharCtx, ents)
    seen = falses(ctx.m)
    seen[1] = true
    stack = Int[1]
    count = 1
    gens = unique(e for e in ents if e != 1)
    while !isempty(stack)
        x = pop!(stack)
        for g in gens
            y = Int(ctx.add[x, g])
            if !seen[y]
                seen[y] = true; count += 1; push!(stack, y)
            end
        end
    end
    return count == ctx.m
end

"""Permutation of character indices induced by an automorphism matrix
M (g_j^g = prod_i g_i^M[j][i]):  (b^g)(g_j) = b(g_j^g)."""
function char_perm(ctx::CharCtx, M::Matrix{Int})
    k = length(ctx.d)
    D = ctx.D
    perm = zeros(Int, ctx.m)
    for a in 1:ctx.m
        c = ctx.chars[a]
        cnew = zeros(Int, k)
        for j in 1:k
            s = 0
            for i in 1:k
                s += M[j, i] * c[i] * (D ÷ ctx.d[i])
            end
            s = mod(s, D)
            q = D ÷ ctx.d[j]
            s % q == 0 || error("matrix does not preserve the group structure")
            cnew[j] = s ÷ q
        end
        perm[a] = encode(ctx, cnew)
    end
    sort(perm) == 1:ctx.m || error("action matrix is not an automorphism")
    return perm
end

"""Closure of a set of permutations (as a sorted Vector of Vector); capped."""
function perm_closure(gens::Vector{Vector{Int}}; cap=200_000)
    isempty(gens) && return Vector{Vector{Int}}()
    n = length(gens[1])
    id = collect(1:n)
    seen = Set{Vector{Int}}([id])
    frontier = [id]
    while !isempty(frontier)
        x = pop!(frontier)
        for g in gens
            y = g[x]                              # y = g o x
            if !(y in seen)
                push!(seen, y); push!(frontier, y)
                length(seen) > cap && return nothing
            end
        end
    end
    return sort!(collect(seen))
end

# ---------------------------------------------------------------------------
# B_n(H) / (C): presentation and cokernel
# ---------------------------------------------------------------------------

function multisets(m::Int, n::Int)
    out = Vector{Vector{Int}}()
    cur = zeros(Int, n)
    function rec(pos, lo)
        if pos > n
            push!(out, copy(cur)); return
        end
        for x in lo:m
            cur[pos] = x
            rec(pos + 1, x)
        end
    end
    rec(1, 1)
    return out
end

"""
B_n(H)/(C): H = prod Z/d_i, `perms` = permutations of H^ induced by the group
of N_G(H) n N_G(Y).  Returns (AbGroup, info).  If `extra_vanishing`, also impose
the (redundant, by [KT, Prop 4.7]) vanishing for every sub-multiset summing to 0.
"""
function bn_quotient(d::Vector{Int}, n::Int, perms::Vector{Vector{Int}};
                     extra_vanishing::Bool=false)
    ctx = CharCtx(d)
    m = ctx.m
    gens = [ms for ms in multisets(m, n) if generates_all(ctx, ms)]
    col = Dict{Vector{Int},Int}(g => i for (i, g) in enumerate(gens))
    rows = Row[]
    function addrow!(terms::Pair{Vector{Int},Int}...)
        row = Row()
        for (key, coef) in terms
            c = col[sort(key)]
            v = get(row, c, 0) + coef
            v == 0 ? delete!(row, c) : (row[c] = v)
        end
        isempty(row) || push!(rows, row)
    end
    for β in gens
        for i in 1:n-1, j in i+1:n
            a, b = β[i], β[j]
            (a == 1 && b == 1) && continue
            if a == b                                   # duplicate nonzero: (b,b,..) = (0,b,..)
                β0 = copy(β); β0[j] = 1
                addrow!(β => 1, β0 => -1)
                if ctx.neg[a] == a                       # 2b = 0: (V) applies to (b,b,..)
                    addrow!(β => 1)
                end
            elseif a != 1 && b != 1
                # (V) and (B) are independent relations; both hold when b_i + b_j = 0
                ctx.add[a, b] == 1 && addrow!(β => 1)    # (V): b_i + b_j = 0
                β1 = copy(β); β1[i] = ctx.add[a, ctx.neg[b]]      # (B)
                β2 = copy(β); β2[j] = ctx.add[b, ctx.neg[a]]
                addrow!(β => 1, β1 => -1, β2 => -1)
            end
        end
        if extra_vanishing
            nz = [x for x in β if x != 1]
            for mask in 1:(1<<length(nz))-1
                s = 1
                for t in eachindex(nz)
                    (mask >> (t - 1)) & 1 == 1 && (s = Int(ctx.add[s, nz[t]]))
                end
                s == 1 && addrow!(β => 1)
            end
        end
        for p in perms                                   # (C_(H,Y))
            βg = [p[x] for x in β]
            sort(βg) != β && addrow!(β => 1, βg => -1)
        end
    end
    G, sz = cokernel_group(rows, length(gens))
    return G, (ngens=length(gens), nrels=length(rows), dense=sz)
end

# ---------------------------------------------------------------------------
# Theorem 5.2 implementation
# ---------------------------------------------------------------------------

struct Summand
    Hdesc::String
    d::Vector{Int}
    Hgens::Vector{String}
    Ydesc::String
    Ysize::Int
    orbitsize::Int
    stabsize::Int
    autsize::Int                 # size of the image of N_G(H) n N_G(Y) in Aut(H)
    value::AbGroup               # B_n([H,Y])
end

struct HClass
    Hdesc::String
    d::Vector{Int}
    Hgens::Vector{String}
    classsize::Int
    Csize::Int
    Nsize::Int
    pairs::Vector{Dict{Symbol,Any}}
end

struct BCStruct
    name::String
    order::Int
    hclasses::Vector{HClass}
    gap_seconds::Float64
end

npairs(st::BCStruct) = sum(length(h.pairs) for h in st.hclasses)

"""The underlying GAP group of an OSCAR group (or a raw GAP group, passed through)."""
gapobj(G::GAP.GapObj) = G
gapobj(G) = G.X

"""Group-theoretic part (GAP): classes [H,Y] and the Aut(H)-action of their stabilisers."""
function bc_structure(G; name::AbstractString="G")
    load_gap!()
    t = @elapsed raw = GAP.gap_to_julia(GAP.Globals.BCStructure(gapobj(G)); recursive=true)
    hcl = HClass[]
    for h in raw
        push!(hcl, HClass(h[:Hdesc], Int.(h[:d]), String.(h[:Hgens]), Int(h[:classsize]),
                          Int(h[:Csize]), Int(h[:Nsize]), h[:pairs]))
    end
    return BCStruct(String(name), Int(GAP.Globals.Size(gapobj(G))), hcl, t)
end

_intmat(x) = Matrix{Int}(reduce(hcat, [Int.(r) for r in x])')

struct BCResult
    name::String
    n::Int
    total::AbGroup
    summands::Vector{Summand}
    seconds::Float64
    npairs::Int
end

function Base.show(io::IO, r::BCResult)
    print(io, "BC_$(r.n)($(r.name)) = ", r.total)
end

"""BC_n(G) via Theorem 5.2 from a precomputed `bc_structure`."""
function bc(st::BCStruct, n::Int; extra_vanishing::Bool=false, cache=Dict{Any,AbGroup}())
    t0 = time()
    total = AbGroup()
    summands = Summand[]
    for h in st.hclasses
        ctx = CharCtx(h.d)
        # B_n(H) = 0 when n < (minimal number of generators of H^): nothing to enumerate
        for p in h.pairs
            perms = [char_perm(ctx, _intmat(M)) for M in p[:mats]]
            cl = perm_closure(perms)
            key = (h.d, n, cl === nothing ? sort(perms) : cl, extra_vanishing)
            val = get!(cache, key) do
                min_generators(h.d) > n ? AbGroup() : first(bn_quotient(h.d, n, cl === nothing ? perms : cl; extra_vanishing))
            end
            total += val
            push!(summands, Summand(h.Hdesc, h.d, h.Hgens, String(p[:Ydesc]), Int(p[:Ysize]),
                                    Int(p[:orbitsize]), Int(p[:stabsize]),
                                    cl === nothing ? -1 : length(cl) + (isempty(cl) ? 1 : 0), val))
        end
    end
    return BCResult(st.name, n, total, summands, time() - t0, npairs(st))
end

bc(G, n::Int; name::AbstractString="G", kwargs...) = bc(bc_structure(G; name), n; kwargs...)

# ---------------------------------------------------------------------------
# Definition-level implementation: relations (C), (V), (B2) on SC_n(G)
# ---------------------------------------------------------------------------

struct DSub
    elts::Vector{Int}
    gens::Vector{Int}
    d::Vector{Int}
    exps::Vector{Vector{Int}}
    cent::BitSet
    eltset::BitSet
end

"""
BC_n(G) straight from the definition (generators (H,Y,beta), relations (O),(C),(V),(B2)
with the Theta_2 term).  Intended for |G| up to a few hundred.
"""
function bc_direct(G, n::Int)
    load_gap!()
    raw = GAP.gap_to_julia(GAP.Globals.BCDirectData(gapobj(G)); recursive=true)
    subs = [DSub(Int.(s[:elts]), Int.(s[:gens]), Int.(s[:d]),
                 [Int.(e) for e in s[:exps]], BitSet(Int.(s[:cent])), BitSet(Int.(s[:elts])))
            for s in raw[:subs]]
    allsubs = [Int.(s) for s in raw[:allsubs]]
    conj = [Int.(c) for c in raw[:conj]]
    cinv = [invperm(c) for c in conj]
    subidx = Dict(s.elts => i for (i, s) in enumerate(subs))
    allidx = Dict(s => i for (i, s) in enumerate(allsubs))
    allbits = [BitSet(s) for s in allsubs]

    # generators: (i, yidx, sorted tuple of nonzero char indices in H_i^)
    col = Dict{Tuple{Int,Int,Vector{Int}},Int}()
    ys_of = Vector{Vector{Int}}(undef, length(subs))
    for (i, s) in enumerate(subs)
        ctx = CharCtx(s.d)
        ys = [y for y in eachindex(allsubs) if s.eltset ⊆ allbits[y] && allbits[y] ⊆ s.cent]
        ys_of[i] = ys
        for r in 1:n, β in multisets(ctx.m - 1, r)
            β = β .+ 1                                   # nonzero characters only
            generates_all(ctx, β) || continue
            for y in ys
                col[(i, y, β)] = length(col) + 1
            end
        end
    end

    eltpos(s::DSub, p) = searchsortedfirst(s.elts, p)
    # value of character c (of s) on group element at position p of s, as numerator mod D
    function charval(s::DSub, ctx::CharCtx, c::Vector{Int}, p::Int)
        e = s.exps[eltpos(s, p)]
        return mod(sum(c[i] * e[i] * (ctx.D ÷ s.d[i]) for i in eachindex(e)), ctx.D)
    end
    # transport character c of H_i along a position map f (g'_j -> f(g'_j) in H_i) to target H_k
    function transport(i, k, c, f::Vector{Int})
        s, t = subs[i], subs[k]
        cs, ct = CharCtx(s.d), CharCtx(t.d)
        cnew = Int[]
        for gj in t.gens
            v = charval(s, cs, c, f[gj])
            q = cs.D ÷ (order_of_gen(t, gj))
            v % q == 0 || error("transport: value not in expected subgroup")
            push!(cnew, v ÷ q)
        end
        return cnew
    end
    order_of_gen(t::DSub, gj) = t.d[findfirst(==(gj), t.gens)]

    rows = Row[]
    function addrow!(terms...)
        row = Row()
        for (key, coef) in terms
            c = col[key]
            v = get(row, c, 0) + coef
            v == 0 ? delete!(row, c) : (row[c] = v)
        end
        isempty(row) || push!(rows, row)
    end
    skey(i, y, β) = (i, y, sort(β))

    for ((i, y, β), _) in col
        s = subs[i]; ctx = CharCtx(s.d)
        r = length(β)
        # (V)
        vanishes = any(ctx.add[β[a], β[b]] == 1 for a in 1:r-1 for b in a+1:r)
        vanishes && addrow!(((i, y, β), 1))
        # (B2)
        for a in 1:r-1, b in a+1:r
            ba, bb = β[a], β[b]
            if ba == bb
                β0 = β[[t for t in 1:r if t != b]]
                addrow!(((i, y, β), 1), (skey(i, y, β0), -1))
            else
                β1 = copy(β); β1[a] = ctx.add[ba, ctx.neg[bb]]
                β2 = copy(β); β2[b] = ctx.add[bb, ctx.neg[ba]]
                terms = Any[((i, y, β), 1), (skey(i, y, β1), -1), (skey(i, y, β2), -1)]
                δ = ctx.add[ba, ctx.neg[bb]]             # b1 - b2 ; generates <b1-b2>
                sub = Set{Int}([1]); x = 1
                while true
                    x = Int(ctx.add[x, δ]); x == 1 && break; push!(sub, x)
                end
                if !any(β[t] in sub for t in 1:r)        # Theta_2 present
                    dc = ctx.chars[δ]
                    Hbar = [p for p in s.elts if charval(s, ctx, dc, p) == 0]
                    k = subidx[Hbar]
                    t = subs[k]; ct = CharCtx(t.d)
                    id = collect(1:maximum(s.elts))      # restriction: positions map to themselves
                    βbar = [encode(ct, transport(i, k, ctx.chars[bx], id)) for bx in β]
                    push!(terms, (skey(k, y, βbar), -1))
                end
                addrow!(terms...)
            end
        end
        # (C): generate by the generators of G
        for (ai, cv) in enumerate(conj)
            Hp = sort([cv[p] for p in s.elts]); k = subidx[Hp]
            Yp = allidx[sort([cv[p] for p in allsubs[y]])]
            # beta^a on H' = aHa^-1:  (beta^a)(x) = beta(a^-1 x a) -> position map cinv[a]
            βa = [encode(CharCtx(subs[k].d), transport(i, k, ctx.chars[bx], cinv[ai])) for bx in β]
            addrow!(((i, y, β), 1), (skey(k, Yp, βa), -1))
        end
    end
    G0, sz = cokernel_group(rows, length(col))
    return G0, (ngens=length(col), nrels=length(rows), dense=sz)
end

end # module
