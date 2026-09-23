# Combinatorial Burnside groups $\mathcal{BC}_n(G)$ — validation report

Paper: Tschinkel–Yang–Zhang, *Combinatorial Burnside groups*, [arXiv:2112.12801](https://arxiv.org/abs/2112.12801).
Stack: Julia 1.12.4, OSCAR 1.8.2 (GAP 4 via GAP.jl, Nemo/FLINT for Smith normal form).

## Summary

Every value of $\mathcal{BC}_n(G)$ published in the paper that could be located there — 52
comparisons, spanning Sections 4 and 6.2–6.5 — is reproduced exactly. A second
implementation, built directly from the definition rather than Theorem 5.2's
decomposition (a genuinely different route for constructing the relation matrix, though
both ultimately reduce to the same cokernel/Smith-normal-form routine), agrees with the
first on every one of 31 further cross-check cases; another 5 checks confirm a redundant
relation from the paper changes nothing (88 checks in total). A separately verifiable
certificate is available for the linear-algebra step, so a specific claimed relation
matrix's cokernel can be checked without trusting this code or the Smith-normal-form
library it calls. See `README.md` for the full repository layout and quick-start commands.

## Method

For a finite group $G$ and $n\ge1$, Theorem 5.2 of the paper (with Lemma 5.1) gives
$$\mathcal{BC}_n(G) \cong \bigoplus_{[H,Y]} \mathcal{B}_n(H)/(C_{(H,Y)}),$$
summed over $G$-conjugacy classes of pairs $(H,Y)$ with $H\subseteq G$ abelian nontrivial
and $H\subseteq Y\subseteq Z_G(H)$, where $(C_{(H,Y)})$ is the relation $\beta=\beta^g$ for
$g\in N_G(H)\cap N_G(Y)$.

1. **GAP**: `ConjugacyClassesSubgroups` enumerates nontrivial abelian $H$ up to conjugacy;
   `IntermediateSubgroups(Z_G(H), H)` enumerates candidate $Y$; `Orbits` under $N_G(H)$
   groups these into classes $[H,Y]$; the stabilizer $N_G(H)\cap N_G(Y)$ acts on
   $H=\langle g_1\rangle\times\cdots\times\langle g_k\rangle$, recorded as integer matrices.
2. **Julia**: a generator of $\mathcal{B}_n(H)$ is an unordered $n$-tuple of characters of
   $H$ (zeros allowed, as padding) that generate $H^\vee$. Relations (as in the proof of
   Lemma 5.1): (B) $\beta=\beta_1+\beta_2$ for distinct nonzero $b_i\neq b_j$;
   $(b,b,\dots)=(0,b,\dots)$ for a repeated nonzero $b$; (V) $b_i+b_j=0$ with
   $b_i,b_j\neq0 \Rightarrow \beta=0$ (this also applies when $b_i=b_j$ has order 2, but
   never to padding zeros); (C) $\beta=\beta^g$ for $g$ in the stabilizer.
3. The relations form an integer matrix; its cokernel is computed by eliminating
   coefficient-$\pm1$ relations first, then a Smith normal form (Nemo/FLINT) on the
   (typically much smaller) remainder. Results are converted to the primary-decomposition
   notation used in the paper.
4. Results are summed over all classes $[H,Y]$, and cached by the isomorphism type of $H$
   together with the image of the stabilizer in $\mathrm{Aut}(H)$.

## Independent verification

A second implementation builds $\mathcal{BC}_n(G)$ directly from the definition — symbols
$(H,Y,\beta)$ over *all* abelian $H$ and *all* $Y$, not up to conjugacy — and imposes (O),
(C), (V), (B2) including the $\Theta_2$ term ($\bar H=\ker(b_1-b_2)$,
$\bar\beta=\beta|_{\bar H}$, present unless some $b_k\in\langle b_1-b_2\rangle$). This does
not use Theorem 5.2 at all, and is only practical for small groups. It agrees with the
Theorem-5.2-based implementation in all 31 `(group, n)` cases tried: $S_3, S_4, D_4, D_5,
C_2\times S_3, A_5, S_5, S_6, D_4\times C_3, C_6\times C_6, S_3\times S_3$, for $n$ up to 4
where feasible. Separately, five further tests confirm that adding the paper's relation
(4.3) (vanishing on any nonempty sub-sum of characters summing to zero) never changes a
result — consistent with (4.3) being redundant given (V) and (B2).

## Validation results

Every value below was compared programmatically (structural `AbGroup` equality, not string
matching, so e.g. $\mathbb Z/10$ and $\mathbb Z/2\times\mathbb Z/5$ count as equal) against
the value printed in the paper.

| target | computed | paper's value | |
|---|---|---|---|
| $\mathcal{BC}_2(S_3)$ | $\mathbb Z/2$ | $\mathbb Z/2$ | matches |
| $\mathcal{BC}_2(S_4)$ | $(\mathbb Z/2)^3$ | same | matches (classes $(C_3,C_3),(K_4,K_4),(C_4,C_4)$, each $\mathbb Z/2$, as in §6.3) |
| $\mathcal{BC}_2(S_5)$ | $(\mathbb Z/2)^6\times\mathbb Z/4$ | same | matches |
| $\mathcal{BC}_2(S_6)$ | $(\mathbb Z/2)^{31}\times(\mathbb Z/4)^3\times\mathbb Z/8$ | same | matches |
| $\mathcal{BC}_3(S_6)$ | $(\mathbb Z/2)^5\times\mathbb Z/4$ | same | matches |
| $\mathcal{BC}_2(S_7), \mathcal{BC}_3(S_7)$ | $(\mathbb Z/2)^{57}\times(\mathbb Z/4)^{12}\times(\mathbb Z/8)^2\times\mathbb Z/3$ ; $(\mathbb Z/2)^{16}\times\mathbb Z/4$ | same | matches |
| $\mathcal{BC}_2(S_8), \mathcal{BC}_3(S_8)$ | $(\mathbb Z/2)^{290}\times(\mathbb Z/4)^{30}\times(\mathbb Z/8)^6\times\mathbb Z/16\times(\mathbb Z/3)^2\times\mathbb Z$ ; $(\mathbb Z/2)^{122}\times(\mathbb Z/4)^4\times\mathbb Z/8\times\mathbb Z$ | same | matches |
| $\mathcal{BC}_2(A_5)$ | $(\mathbb Z/2)^3$, from $\mathcal{B}_2([(C_3,C_3)])=\mathbb Z/2$ and $\mathcal{B}_2([(C_5,C_5)])=(\mathbb Z/2)^2$ | same | matches |
| $\mathcal{BC}_n(A_5)$, $n=3,\dots,9$ | $0$ | $0$ | matches; the bound $n\ge\ell+a-1=9$ deduced from the proof of Prop. 4.1 ($\ell,a$ = max element order, max abelian-subgroup order) makes this cover **all** $n\ge3$, not just the range tested |
| $\mathcal{BC}_2(C_2\times S_3)$ | $(\mathbb Z/2)^5\times\mathbb Z/4$ | same | matches |
| — its decomposition | $\mathcal{B}_2([H_1,H_1])=\mathbb Z/2$, $\mathcal{B}_2([H_2,H_2])=(\mathbb Z/2)^2$, $\mathcal{B}_2([H_1,H_3])=\mathbb Z/2$, $\mathcal{B}_2([H_3,H_3])=\mathbb Z/2\times\mathbb Z/4$; remaining 8 classes are 0 | same (§6.5) | matches |
| $\mathcal{BC}_3(C_2\times S_3)$ | $0$ | $0$ | matches |
| $\mathcal{BC}_2(D_p)$, $p=5,\dots,23,31,101$ (9 primes) | matches formula for every $p$, e.g. $p=5$: $(\mathbb Z/2)^2$; $p=101$: $(\mathbb Z/2)^{50}\times\mathbb Z/25\times\mathbb Z/17\times\mathbb Z^{376}$ | $\mathbb Z^{(p-5)(p-7)/24}\times(\mathbb Z/2)^{(p-3)/2}\times\mathbb Z/\frac{p^2-1}{12}$ | matches (formula stated as experimental in the paper) |
| $\mathcal{BC}_2(C_3)$ | $\mathbb Z$ | $\mathbb Z$ (§4) | matches |
| $\mathcal{BC}_2(D_4)$ | $(\mathbb Z/2)^3$ | same | matches |
| $\mathcal{BC}_2,\mathcal{BC}_3(\mathfrak{He}_3)$ | $\mathbb Z^{26}$ ; $\mathbb Z^4$ | same | matches |
| $\mathcal{BC}_2,\mathcal{BC}_3(\mathfrak{He}_5)$ | $\mathbb Z^{124}$ ; $(\mathbb Z/2)^{36}\times\mathbb Z^{36}$ | same | matches |
| class counts for $\mathfrak{He}_p$ | `3p+5` classes with `\|H\|=p`, `p+1` with `\|H\|=p^2`, for `p=3,5` | §6.2 formula | matches |
| $\mathrm{ASL}_2(\mathbb F_3)$: $\mathcal{BC}_2,\dots,\mathcal{BC}_5$ | $(\mathbb Z/2)^7\times\mathbb Z^{13}$ ; $\mathbb Z/2\times\mathbb Z$ ; $0$ ; $0$ | same | matches (paper gives only the total groups, no class breakdown) |
| $\mathrm{PSL}_2(\mathbb F_7)$: $\mathcal{BC}_2,\mathcal{BC}_3,\mathcal{BC}_4$ | $(\mathbb Z/2)^3\times\mathbb Z$ ; $\mathbb Z/2$ ; $0$ | same | matches, including the paper's own 3-class breakdown $(C_3,C_3),(C_7,C_7),(C_4,C_4)$ |
| $A_6$: $\mathcal{BC}_2,\mathcal{BC}_3,\mathcal{BC}_4$ | $(\mathbb Z/2)^7\times\mathbb Z/4\times\mathbb Z$ ; $\mathbb Z/2\times\mathbb Z$ ; $0$ | same | matches (an independently constructed $\mathrm{PSL}_2(\mathbb F_9)\cong A_6$ gives the same) |

Every value from the paper that we located was reproduced exactly; no discrepancies
remain (52 comparisons against a value actually printed in the paper; see "A note on the
headline count" below for the further 36 internal cross-checks). The paper's own table
also has $\mathcal{BC}_2(S_8)$ with a free summand $\mathbb Z$, which is reproduced.

### A note on the headline count

Counting every `[ OK ]` line in `validation_output.txt` gives 88, not all of them
comparisons against the paper: 52 are direct comparisons against a value printed
in~[TYZ] (45 total-group values, 3 summand-decomposition checks, 2 Heisenberg
class-count checks — the rows above); the remaining 36 are internal cross-checks that
do not involve the paper at all (31 comparisons between our two implementations, §"Independent
verification"; 5 checks that relation (4.3) is redundant, §"Independent verification").

## A correctness note from development

During development, the two independent implementations initially disagreed on
$\mathcal{BC}_1(C_2\times S_3)$ ($\mathbb Z^{10}$ vs $\mathbb Z^{11}$). The cause was an
incorrect shortcut in the Theorem-5.2-based implementation: "$\mathcal{B}_n(H)=0$ if the
number of primary factors of $H$ exceeds $n$" — false for $H=\mathbb Z/6\cong\mathbb
Z/2\times\mathbb Z/3$, which needs only one generator. The condition is now the correct
one, the largest $p$-rank of $H$. This did not change any value in the table above, but
would have affected groups containing an abelian subgroup like $V_4\times C_3$ (e.g.\
$S_7$). Having a second, structurally independent implementation is what surfaced this.

## Interpretation choices

* Relation (B) as printed in §3 of the paper ("$\beta=\beta_1+\beta_2$ for all $\beta$") does
  not quite match the identities the proof of Lemma 5.1 lists. Applied literally to two
  zero entries, it forces $\beta=2\beta$, i.e.\ $\beta=0$ for every tuple with a repeated
  zero. Applied to two *equal nonzero* entries $b_1=b_2=b$, both $\beta_1,\beta_2$ reduce
  to $(0,b,\dots)$, so $\beta=2(0,b,\dots)$ — but the proof of Lemma 5.1 lists
  $(b,b,\dots)=(0,b,\dots)$ with coefficient 1, not 2. We follow the convention implied by
  Lemma 5.1's identities: (B) applies only to distinct nonzero entries; a repeated nonzero
  entry is a *separate* rule, $(b,b,\dots)=(0,b,\dots)$; (V) handles $b+(-b)=0$. This is
  our interpretation of an internally inconsistent definition, not something the paper
  states explicitly as a single rule; see the note's Question 2.
* (V) is imposed whenever two positions sum to zero, including a repeated character of
  order 2 (but never a pair of padding zeros) — this is what forces every summand with
  $H\cong\mathbb Z/2$ to vanish for $n\ge2$.
* The stabilizer $N_G(H)\cap N_G(Y)$ acts on characters via $b\mapsto b\circ\mathrm{conj}_g$,
  i.e.\ $b^g(h)=b(g^{-1}hg)$. Using $b^g(h):=b(ghg^{-1})$ instead — the opposite choice of
  which element of $\{g,g^{-1}\}$ conjugation invokes — yields an isomorphic quotient,
  since $g\mapsto g^{-1}$ permutes the stabilizer; this is unrelated to negating character
  values, which is a different operation.

## An independently-checkable certificate

For a claimed relation matrix $A$, `certify_snf` in `BurnsideC.jl` builds the original
(unreduced) matrix and returns unimodular $U,V$ with $UAV=D$ diagonal, via Nemo's
`snf_with_transform`. Given only $A,U,V,D$, one can check $UAV=D$ and
$\det U,\det V=\pm1$ by hand or in any other system, without trusting this code or the
Smith-normal-form routine being certified — this certifies $D$ is the correct Smith
normal form of the given $A$, not that $A$ itself correctly encodes the intended
presentation (that is what the independent implementation, above, checks instead).
`verify_certificates.jl` checks this independently — using a from-scratch integer
determinant and matrix product (fraction-free Gaussian elimination), not the library
routine — for two combined presentations, the block-diagonal union of all $[H,Y]$-blocks
of $\mathcal{BC}_2(S_3)$ (2 blocks) and of $\mathcal{BC}_2(S_4)$ (11 blocks) respectively
(13 blocks covered by these two certificates), and against six further synthetic
presentations (including empty, rectangular, and non-unimodular-looking cases).

## Enumerating abelian subgroups of large $S_n$

`ConjugacyClassesSubgroups` (Step 1 above) is GAP's general-purpose subgroup-lattice
algorithm; it takes about 51s for $S_9$ and does not finish within 10 minutes for
$S_{10}$. An attempt to bypass this with a from-scratch combinatorial classification
(partition $n$ into orbits, one abelian group acting regularly per orbit) turned out to be
**mathematically incomplete**: in $S_4$, $\langle(1,2)(3,4)\rangle$ (order 2) and
$\langle(1,2),(3,4)\rangle$ (order 4) have identical orbit data but are not conjugate — a
subgroup need only *embed* in the product of its orbit images, as a possibly proper
subdirect product (Goursat's lemma), which can happen even across orbits of
non-isomorphic type whenever they share a nontrivial common quotient.

`bc_structure_tom.g` instead reads the classes of abelian $H$ directly out of GAP's
precomputed Table of Marks library (`tomlib`, which has $S_4,\dots,S_{12}$ available —
no reclassification needed, though the comparison below is still what establishes
correctness, not the data's precomputed status by itself). This reduces $H$-enumeration to under
$0.1$s even for $S_{11}$, and was cross-checked against `ConjugacyClassesSubgroups`
exactly (identical classes, identical $\mathcal{BC}_2$ values) for $S_4,\dots,S_8$.
Somewhat surprisingly, the *total* time for $S_9$ barely improved (51–140s, machine
dependent): the remaining cost is the per-$H$ work (in particular enumerating $Y$ with
$H\subseteq Y\subseteq Z_G(H)$), not the $H$-enumeration this change targeted. For $S_{10}$
and $S_{11}$, $H$-enumeration is fast but the full computation did not finish within a few
minutes, so no $\mathcal{BC}_2$ value is available for either.

## Results beyond the paper

Not independently verified against any published source.

* $\mathcal{BC}_2(S_9) = (\mathbb Z/2)^{529}\times(\mathbb Z/4)^{80}\times(\mathbb
  Z/8)^{17}\times(\mathbb Z/16)^2\times(\mathbb Z/3)^{11}\times\mathbb Z^{11}$, obtained by
  two independent subgroup-enumeration routes (above) with identical results.
* For $\mathrm{AGL}(1,p)=\mathbb Z/p\rtimes\mathbb Z/(p-1)$ (not treated in the paper), no
  pattern was found for $\mathcal{BC}_2$ or $\mathcal{BC}_3$, but writing $m=p-1$,
  $$\operatorname{rank}\mathcal{BC}_1(\mathrm{AGL}(1,p)) = 1+\sum_{d\mid m,\,d>1}\varphi(d)\tau(m/d) = 1+\sigma(m)-\tau(m)$$
  matches the computed rank exactly for the ten primes $p=5,\dots,37$ tested. The formula
  follows from the fact that every nontrivial abelian subgroup of $\mathrm{AGL}(1,p)$ is
  either the translation subgroup $C_p$ or is contained in a point stabilizer $C_m$.

## Not done / not verified

* The map $\mathrm{Burn}_2(G)\to\mathcal{BC}_2(G)$ and the specific class distinguishing
  $X\!\downarrow\!G$ from $\mathbb P^2\!\downarrow\!G$ in §6.5 are not computed; only the
  group $\mathcal{BC}_2(C_2\times S_3)$ that class lives in, and its full decomposition, are
  verified.
* The symbol $(C_3, C_2\times C_3, (1,2))$ printed in §6.5's displayed difference vanishes
  by (V) ($1+2=0$ on $C_3$); this is not a problem with the paper's example, since the
  difference is only claimed to be nonzero as a whole, and it reduces to the single
  surviving nonzero term $(C_3,C_3,(1,1))$, consistent with the paper's "nontrivial
  2-torsion class".
* The restriction maps $\mathrm{res}^G_{G'}$ and the ring structure on
  $\mathcal{BC}_*(G)$ (§4 of the paper) are not implemented.
* The definition-level cross-check only covers $|G|\lesssim700$ and small $n$ — much
  slower than the Theorem-5.2-based route.

## Performance

Single-threaded, Apple-silicon Mac; excludes Julia/OSCAR startup (~10s).

| case | subgroup enumeration | linear algebra |
|---|---|---|
| $S_6$ (70 classes) | 1.1s | <0.1s |
| $S_7$ | 0.6s | <0.1s ($n=2,3$) |
| $S_8$ (587 classes) | 5s | 0.5s ($n=2$), 2.4s ($n=5$) |
| $S_9$ (964 classes): old method | 51s | <1s ($n=2,3$) |
| $S_9$: `tomlib`-based $H$-enumeration only | 0.007s | — full pipeline still 51–140s, see above |
| $S_{10}$, $S_{11}$: $H$-enumeration only | 0.02s, 0.04s | full pipeline did not finish in a few minutes |
| $(\mathbb Z/2)^5$ (5395 classes) | 3s | seconds for $n\le5$ |
| $\mathfrak{He}_7$, $n=3$ (20{,}825 generators) | 0.2s | 7s |
| $\mathfrak{He}_{11}$, $n=3$ ($\sim3\times10^5$ generators) | 0.3s | did not finish in 8 min |

Two distinct bottlenecks: (a) for $S_9$ and up, the per-subgroup group-theoretic work
(likely `IntermediateSubgroups`, not yet profiled to a single call); (b) the size of
$\mathcal{B}_n(H)$, $\binom{|H|+n-1}{n}$ generators before relations, impractical past
roughly $10^5$. $n$ itself is rarely the limit — Conjecture 4.2 of the paper predicts
vanishing once $n$ exceeds roughly $\log_2$ of the largest abelian subgroup order.
