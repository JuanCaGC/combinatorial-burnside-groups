# Combinatorial Burnside groups BC_n(G) in Julia/OSCAR — validation report

Paper: Tschinkel–Yang–Zhang, *Combinatorial Burnside groups*, arXiv:2112.12801 (`paper.pdf`).
Stack: Julia 1.12.4, OSCAR 1.8.2 (GAP 4 via GAP.jl, Nemo/FLINT for Smith normal form).

## Files

| file | purpose |
|---|---|
| `BurnsideC.jl` | the implementation (module `BurnsideC`) |
| `bc_structure.g` | ~60 lines of GAP: classes of `[H,Y]`, action of `N_G(H)∩N_G(Y)` on `H` |
| `validate.jl` | every number from the paper, side by side; also `crosscheck`, `demo`, `full`, `all` |
| `scaling.jl`, `scaling_log.txt` | timing probes |
| `validation_output.txt` | full transcript of `validate.jl all` (86 checks in total, 0 failures) |

```
julia --project=. validate.jl            # quick tier: all published values up to S6   (~16 s incl. startup)
julia --project=. validate.jl demo       # C2×S3 per-[H,Y] table (paper §6.5)
julia --project=. validate.jl crosscheck # Theorem 5.2 code vs. the definition (C),(V),(B2)
julia --project=. validate.jl full       # + S7, S8
```
API: `st = bc_structure(G)` (GAP part, once per group), then `bc(st, n)` for any `n`; or `bc(G, n)`.
`G` may be any OSCAR permutation/matrix group or a raw GAP group.

## How it computes

`BC_n(G) = ⊕_{[H,Y]} B_n(H)/(C_(H,Y))` (Thm 5.2 / Lemma 5.1).

1. GAP: `ConjugacyClassesSubgroups` → nontrivial abelian `H`; `IntermediateSubgroups(Z_G(H), H)` → `Y`;
   `Orbits(N_G(H), Y's)` → classes `[H,Y]`; stabiliser `N_G(H)∩N_G(Y)` acts on
   `H = ⟨g_1⟩×…×⟨g_k⟩` by integer matrices.
2. Julia: generators of `B_n(H)` are multisets of `n` characters of `H` (zeros allowed = padding) that generate `H^∨`.
   Relations (Lemma 5.1): (B) `β=β₁+β₂` for `b_i≠b_j` nonzero; `(b,b,…)=(0,b,…)`; (V) `b_i+b_j=0 ⇒ β=0`
   (also for repeated 2-torsion `b`); (C) `β=β^g`.
3. Cokernel: sparse elimination of ±1 pivots, then Smith normal form over ℤ (Nemo). Results are stored in the
   paper's primary-decomposition notation (`(Z/2)^6 × Z/4`), and invariant factors are available.
4. Results per `[H,Y]` are cached by `(H, image of stabiliser in Aut(H), n)`.

## Independent check of the implementation

`bc_direct(G, n)` does **not** use Theorem 5.2. It builds SC_n(G) on all triples `(H,Y,β)` (all abelian `H`,
all `Y`, not up to conjugacy) and imposes (O), (C), (V) and (B2) **including the Θ₂ term** (`H̄=ker(b₁−b₂)`,
`β̄=β|_H̄`, present iff no `b_k ∈ ⟨b₁−b₂⟩`). It agrees with the Theorem-5.2 code in all 31 (group, n) cases
tried (S₃, S₄, D₄, D₅, C₂×S₃, A₅, S₅, S₆, D₄×C₃, C₆×C₆, S₃×S₃; n = 1…4 where feasible). Separately, 5 further tests confirm that
adding the "any sub-sum vanishes" relation (paper (4.3)) changes nothing.

## Validation targets

All values below are produced by the code and compared programmatically (`AbGroup` equality) to the paper's string.

| target | computed | paper | |
|---|---|---|---|
| BC₂(S₃) | Z/2 | Z/2 | ✅ |
| BC₂(S₄) | (Z/2)³ | (Z/2)³ | ✅ (classes (C₃,C₃),(K₄,K₄),(C₄,C₄), each Z/2, as in §6.3) |
| BC₂(S₅) | (Z/2)⁶ × Z/4 | same | ✅ |
| BC₂(S₆) | (Z/2)³¹ × (Z/4)³ × Z/8 | same | ✅ |
| BC₃(S₆) | (Z/2)⁵ × Z/4 | same | ✅ |
| BC₂(S₇), BC₃(S₇) | (Z/2)⁵⁷×(Z/4)¹²×(Z/8)²×Z/3 ; (Z/2)¹⁶×Z/4 | same | ✅ |
| BC₂(S₈), BC₃(S₈) | (Z/2)²⁹⁰×(Z/4)³⁰×(Z/8)⁶×Z/16×(Z/3)²×Z ; (Z/2)¹²²×(Z/4)⁴×Z/8×Z | same | ✅ |
| BC₂(A₅) | (Z/2)³, from [(C₃,C₃)]=Z/2 and [(C₅,C₅)]=(Z/2)² | same | ✅ |
| BC_n(A₅), n=3,…,9 | 0 | 0 | ✅ and, by the explicit bound n ≥ ℓ+a−1 = 9 deduced from the proof of Prop. 4.1 (see guia/02 §4.4), this covers **all** n ≥ 3 |
| **BC₂(C₂×S₃)** | **(Z/2)⁵ × Z/4** | same | ✅ |
| its decomposition | [(H₁,H₁)]=Z/2, [(H₂,H₂)]=(Z/2)², [(H₁,H₃)]=Z/2, [(H₃,H₃)]=Z/2×Z/4; the other 8 classes are 0 | same (§6.5) | ✅ |
| BC₃(C₂×S₃) | 0 | 0 | ✅ |
| BC₂(D_p), p = 5 | (Z/2)² | formula gives Z⁰ × (Z/2)¹ × Z/2 = (Z/2)² | ✅ |
| BC₂(D_p), p = 7, 11, 13, 17, 19, 23, 31, 101 | match the formula, e.g. D₁₁: Z × (Z/2)⁵ × Z/5; D₁₃: Z² × (Z/2)⁶ × Z/7 | Z^((p−5)(p−7)/24) × (Z/2)^((p−3)/2) × Z/((p²−1)/12) | ✅ (formula is "experimental" in the paper) |
| BC₂(C₃) | Z | Z (§4) | ✅ |
| BC₂(D₄) | (Z/2)³ | (Z/2)³ | ✅ |
| BC₂, BC₃(He₃) | Z²⁶ ; Z⁴ | same | ✅ |
| BC₂, BC₃(He₅) | Z¹²⁴ ; (Z/2)³⁶ × Z³⁶ | same | ✅ |
| #[H,Y] classes for He_p | (3p+5) with \|H\|=p, (p+1) with \|H\|=p² (p=3,5) | §6.2 | ✅ |
| ASL(2,3): BC₂, BC₃, BC₄, BC₅ | (Z/2)⁷×Z¹³ ; Z/2×Z ; 0 ; 0 | same | ✅ |
| PSL(2,7): BC₂, BC₃, BC₄ | (Z/2)³×Z ; Z/2 ; 0 | same | ✅ |
| A₆: BC₂, BC₃, BC₄ | (Z/2)⁷×Z/4×Z ; Z/2×Z ; 0 | same | ✅ (PSL(2,9) built independently gives the same) |

Everything the paper states that I could find was reproduced exactly; no mismatches remain.
The paper's own table also has BC₂(S₈) with a free summand `Z`, which is reproduced.

## Bug found and fixed during development (worth knowing)

The definition-level cross-check disagreed on BC₁(C₂×S₃) (Z¹⁰ vs Z¹¹). Cause: my shortcut "B_n(H)=0 if
#primary factors of H > n" is wrong for e.g. C₆ (= C₂×C₃, one generator suffices). It is now the largest p-rank.
It did not change any published value tested at that point, but it would have affected groups with `V₄×C₃`-type
abelian subgroups (e.g. S₇). Also, first draft treated (V) and (B) as exclusive when `b_i+b_j=0`; both hold
(that fix produced S₃ and S₄ right).

## Interpretation choices (please mention when presenting)

* §3 literally says "(B): β=β₁+β₂ for all β" with zero entries allowed; applied to `b₁=b₂=0` that forces `β=2β`.
  I therefore implement B_n(H) as in the **proof of Lemma 5.1**: zero-padded tuples, (B) only for distinct nonzero
  entries, `(b,b,…)=(0,b,…)`, and (V). Blowing up with a zero entry only reproduces (V).
* (V) is imposed for two entries `b_i=−b_j` at different positions, so a repeated 2-torsion character gives 0
  (this is what kills every `H=C₂` contribution).
* The action of `N_G(H)∩N_G(Y)` on characters uses `b↦b∘conj_g`; the opposite convention gives the same group.

## Not done / not verified

* The geometric class `[X↷G]−[P²↷G]` (paper §6.5, via `Burn₂(G)→BC₂(G)` and the map Ψ) is **not** computed; I checked the
  group `BC₂(C₂×S₃)` and its `[H,Y]`-decomposition, i.e. the target in which the class lives, not that class's image.
  (The paper's notation `(C₃,C₂×C₃,(1,2))` there is ambiguous to me, since (1,2) sums to 0 on C₃.)
* `BC_n(A₅)=0` for all n≥3: computed for n=3…9, and n ≥ ℓ+a−1 = 9 vanishes by the argument of Prop. 4.1 (which relies on the paper's relation (4.3), taken from [8]; we confirmed numerically that (4.3) adds nothing new in the tested cases).
* Values not in the paper (e.g. BC₄(S₈)=(Z/2)²³, BC₅(S₈)=0, A₈, M₁₁, PSL(2,8), He₇) are outputs only; they passed only the
  internal consistency tests, not a comparison to literature. BC₄(S₈) ≠ 0 with BC₅(S₈)=0 is consistent with Conjecture 4.2.
* The definition-level check only covers |G| ≲ 720 and small n (it is much slower than Theorem 5.2).

## How far can it go (Apple-silicon Mac, single thread; times exclude ~10 s Julia/OSCAR startup)

| case | GAP class enumeration | linear algebra |
|---|---|---|
| S₆ (70 classes) | 1.1 s | <0.1 s |
| S₇ | 0.6 s | <0.1 s (n=2,3) |
| S₈ (587 classes [H,Y]) | 5 s (15 s when the machine was loaded) | 0.5 s (n=2), 2.4 s (n=5) |
| S₉ (964 classes) | 51 s | <1 s (n=2,3) |
| S₁₀ | >10 min (aborted) | — |
| (Z/2)⁵ (5395 classes) | 3 s | seconds for n≤5 |
| He₇, n=3 (\|H^∨\|=49, 20,825 generators) | 0.2 s | 7 s |
| He₁₁, n=3 (\|H^∨\|=121, ~3·10⁵ generators) | 0.3 s | did not finish in 8 min |

So the bottleneck is (a) GAP's `ConjugacyClassesSubgroups` for large groups (S₁₀ and up would need an
abelian-subgroups-only enumeration) and (b) the size of `B_n(H)`, which has C(|H|+n−1, n) generators;
it becomes impractical roughly once that exceeds ~10⁵. n itself is rarely the limit (Conjecture 4.2 predicts vanishing beyond n ≈ log₂ of the largest abelian subgroup order).
