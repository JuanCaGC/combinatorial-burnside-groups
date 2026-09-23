# Combinatorial Burnside groups — Julia/OSCAR implementation

A Julia/OSCAR (GAP + Nemo) implementation of the combinatorial Burnside groups
$\mathcal{BC}_n(G)$ of Tschinkel–Yang–Zhang, *Combinatorial Burnside groups*,
[arXiv:2112.12801](https://arxiv.org/abs/2112.12801).

Every value of $\mathcal{BC}_n(G)$ published in that paper that we could locate — 86
checks, spanning its Sections 4 and 6.2–6.5 — is reproduced exactly, via two independent
implementations (one following Theorem 5.2's decomposition, one built directly from the
definition) that agree with each other and with the paper.

## Status

- **86/86** checks against published values pass (`bc/validate.jl all`).
- Cross-checked by an independent, definition-level implementation for 31 `(group, n)`
  pairs (no shared code path with the main implementation).
- An independently-checkable certificate for the linear-algebra step (Smith normal form)
  is available: given only the certificate's matrices, anyone can verify a claimed result
  by hand, without trusting this code or the Nemo/FLINT library it calls.
- A few results beyond the paper (not independently verified against any published
  source): a value of $\mathcal{BC}_2(\mathrm{Sym}_9)$, and a proved rank formula for
  $\mathcal{BC}_1(\mathrm{AGL}(1,p))$.

See [`bc/REPORT.md`](bc/REPORT.md) for the full validation report and
[`bc/validation_output.txt`](bc/validation_output.txt) for the raw transcript.

## Requirements

- [Julia](https://julialang.org/) 1.12+
- [OSCAR.jl](https://www.oscar-system.org/) 1.8+ (brings in GAP and Nemo/FLINT)

## Quick start

```bash
cd bc
julia --project=. validate.jl            # every published value, up to Sym_6 (~15s)
julia --project=. validate.jl full       # + Sym_7, Sym_8
julia --project=. validate.jl crosscheck # Theorem 5.2 implementation vs. the direct definition
julia --project=. validate.jl demo       # per-class breakdown of BC_2(C2 x Sym_3), the paper's geometric example
```

```julia
include("BurnsideC.jl")
using .BurnsideC, Oscar

G  = alternating_group(6)
st = bc_structure(G; name = "A6")   # group-theoretic part (GAP), computed once
bc(st, 2)                            # BC_2(A6) = ...
```

## Layout

| path | what it is |
|---|---|
| `bc/BurnsideC.jl` | the module: character arithmetic, $\mathcal{B}_n(H)/(C)$, the Theorem 5.2 route (`bc`), the direct-definition route (`bc_direct`), the Smith-normal-form certificate (`certify_snf`) |
| `bc/bc_structure.g` | GAP: enumerates conjugacy classes $[H,Y]$ and the stabilizer action on $H$ |
| `bc/bc_structure_tom.g`, `bc/tomlib.jl` | an alternative $[H,Y]$ enumeration for large $\mathrm{Sym}_n$, reading GAP's precomputed Table of Marks library instead of enumerating subgroups from scratch |
| `bc/validate.jl` | reproduces every published value; `crosscheck`, `demo`, `full` modes |
| `bc/validate_tomlib.jl` | cross-checks `bc_structure_tom.g` against `bc_structure.g` |
| `bc/verify_certificates.jl` | independently verifies the Smith-normal-form certificate (does not call the routine it is certifying) |
| `bc/scaling.jl`, `bc/scaling_log.txt` | timing probes for larger groups |
| `bc/REPORT.md` | validation report: method, results, correctness notes, performance |
| `bc/validation_output.txt` | full transcript of a `validate.jl all` run |

## Known limitations

- GAP's general subgroup enumeration is impractical for $\mathrm{Sym}_n$, $n\gtrsim9$
  (`bc_structure_tom.g` fixes the subgroup-*enumeration* step using GAP's Table of Marks
  library, but the full per-subgroup computation for $\mathrm{Sym}_9$ still takes on the
  order of a minute, and does not finish within a few minutes for $\mathrm{Sym}_{10},
  \mathrm{Sym}_{11}$ — see `bc/REPORT.md` for the detailed timing breakdown).
- The number of generators of $\mathcal{B}_n(H)$ grows as $\binom{|H|+n-1}{n}$ before
  relations are imposed; this becomes impractical past roughly $10^5$.
- The restriction maps $\mathrm{res}^G_{G'}$, the ring structure on
  $\mathcal{BC}_*(G)$, and the map $\mathrm{Burn}_n(G)\to\mathcal{BC}_n(G)$ from the
  paper's Section 6.5 are not implemented.

## Development notes

Some implementation work in this repository (the Smith-normal-form certificate and the
Table-of-Marks-based enumerator) was carried out with the assistance of AI coding agents
(Claude Code, OpenAI Codex), under review and independent re-verification at each step —
every value reported in `bc/REPORT.md` was re-checked directly, not taken on the agents'
word. An earlier attempt at a direct combinatorial classification of abelian subgroups of
$\mathrm{Sym}_n$ turned out to be mathematically incomplete (see `bc/REPORT.md`, "Enumerating
abelian subgroups of large $S_n$") and was abandoned in favor of the Table-of-Marks route.

## License

No license is currently specified; all rights reserved by default. Add one (e.g. MIT or
BSD-3-Clause) if you want others to be able to reuse this code.

## Reference

Yuri Tschinkel, Kaiqi Yang, Zhijia Zhang. *Combinatorial Burnside groups*.
[arXiv:2112.12801](https://arxiv.org/abs/2112.12801).
