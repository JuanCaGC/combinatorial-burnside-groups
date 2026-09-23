# Additive instrumented copy of BurnsideC.cokernel_group unit-pivot loop.
# Pivot selection and row updates are unchanged. Only trace recording is added.
# Final residual matrix retains zero columns to keep free-generator coordinates.
const Row = BurnsideC.Row
function tracked_elimination(rows::Vector{Row}, ncols::Int)
    colrows = Dict{Int,Set{Int}}()
    for (r, row) in enumerate(rows), c in keys(row)
        push!(get!(colrows, c, Set{Int}()), r)
    end
    alive = trues(length(rows))
    trace = Tuple{Int,Int,Row}[]
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
            push!(trace, (c, ε, copy(row)))
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
    eliminated = Set(c for (c, _, _) in trace)
    survivors = [c for c in 1:ncols if !(c in eliminated)]
    q = length(survivors)
    E = zero_matrix(ZZ, ncols, q)
    J = zero_matrix(ZZ, q, ncols)
    for (j,c) in enumerate(survivors)
        E[c,j] = 1; J[j,c] = 1
    end
    for (c, epsilon, row) in reverse(trace), j in 1:q
        E[c,j] = -epsilon * sum((ZZ(v)*E[k,j] for (k,v) in row if k != c); init=ZZ(0))
    end
    M = zero_matrix(ZZ,length(liverows),q)
    for (i,row) in enumerate(liverows), (j,c) in enumerate(survivors)
        M[i,j] = get(row,c,0)
    end
    return E,J,M,survivors,trace
end
