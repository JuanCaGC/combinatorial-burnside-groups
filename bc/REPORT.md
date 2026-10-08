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

## $\mathcal{BC}_n(\mathbb F_p^r)$ as a $\mathrm{GL}_r(\mathbb F_p)$-module (Problem 6.1)

For $G=\mathbb F_p^r$ elementary abelian, internal conjugation is trivial, so the
class-based machinery of Theorem 5.2 carries no symmetry and formula (6.1),
$\mathcal{BC}_n(G)=\bigoplus_{H'\subseteq G}\bigoplus_{H''\subseteq H'}B_n(H'')$, is the
right description on its own. The symmetry that does act is $\mathrm{Aut}(G)=\mathrm{GL}_r(\mathbb
F_p)$, by automorphisms rather than conjugation — directly relevant to the paper's open
Problem 6.1. This section reports a first, explicitly-scoped computational exploration
of that action, done in two passes: a derivation done by hand before any code was written
(`gl_module_notes.md`, not committed), and a computation dispatched separately and then
independently re-verified (below). It is a beginning, not a resolution of Problem 6.1.

**What was established analytically first.** $\mathrm{Aut}(G)$ preserves each of the
defining relations (O), (V), (B2) of $B_n(H)$ for $H=G$, and permutes the $[H,Y]$-classes of
Theorem 5.2, so it acts on all of $\mathcal{BC}_n(G)$, not just summand-by-summand. For a
fixed subspace dimension $m$, $\mathrm{GL}_r(\mathbb F_p)$ acts transitively on the
$m$-dimensional subspaces $H''\subseteq G$, with stabilizer a parabolic subgroup $P_m$ whose
unipotent radical acts trivially on $H''$ itself (a direct block-matrix check). This means the
graded piece of formula (6.1) at dimension $m$ is an induced module
$\mathrm{Ind}_{P_m}^{\mathrm{GL}_r(\mathbb F_p)}$ of a module inflated from $\mathrm{GL}_m(\mathbb
F_p)$ — a real structural reduction, though dimension-counting alone cannot test it and no
attempt was made to verify it beyond the $m=r$ (full space) case below.

**Raw data (new, computed, not independently verified against any external source
except where noted).** $\mathcal{BC}_n(\mathbb F_p^r)$ for $p\in\{2,3,5\}$, $r\in\{1,2,3\}$,
$n\in\{1,2,3\}$, via the existing `bc(bc_structure(G),n)` route (26 of 27 grid points; $(p,r,n)=(5,3,3)$
skipped as it would need $\binom{125+2}{3}=333{,}375$ generator candidates, beyond what this
codebase's generator-elimination approach handles — see Performance above). Four points were
independently spot-checked here by direct recomputation and matched exactly:
$\mathcal{BC}_2(\mathbb F_3^2)=\mathbb Z^{15}$, $\mathcal{BC}_3(\mathbb F_3^2)=\mathbb Z^3$,
$\mathcal{BC}_2(\mathbb F_5^2)=(\mathbb Z/5)^2\times\mathbb Z^{70}$,
$\mathcal{BC}_3(\mathbb F_3^3)=\mathbb Z^{144}$. The full table, the $\{\pm1\}$- and
full-$\mathbb F_p^\times$-quotient comparisons for $r=1$ (which agree with the existing $D_p$
and $S_3$ data already in this report), and the dimension-arithmetic scan against
$\mathrm{Sym}^k$, $\Lambda^k$ and the Steinberg dimension $p^{m(m-1)/2}$ (window $k=0,\dots,6$)
are in `gl_data_output.txt`, `gl_cyclic_output.txt`, `gl_dimensions_output.txt`. The dimension
scan found no coherent recognition pattern: matches occur only in low rank ($\le 7$) and are
attributable to $\mathrm{Sym}^k$ in dimension $m=2$ matching *any* positive integer for some
$k$, not to a real correspondence; it was also noted, correctly, that a free-rank comparison
alone cannot rule out a match for a torsion group, since tensoring with $\mathbb F_p$ adds a
dimension for each $p$-primary cyclic factor, so this scan is a weak negative result at best,
not a search over all of formula (6.1)'s pieces.

**The one positive structural finding.** For $p=2,r=2,n=2$: $\mathcal{BC}_2(\mathbb
F_2^2)=(\mathbb Z/2)^2$ is entirely the top piece $H=Y=G$, i.e. $B_2(\mathbb F_2^2)$ itself
(after its own defining quotient). The explicit action of $\mathrm{GL}_2(\mathbb F_2)\cong S_3$
on this 2-dimensional $\mathbb F_2$-space was computed by tracking the existing
generator-elimination/Smith-normal-form pipeline through an automorphism (not just its effect
on the final invariant factors), producing genuine $3\times3$ and $24\times24$ intermediate
data reduced to $2\times2$ and $7\times7$ final action matrices for $p=2$ and $p=3$
respectively. For $p=2$, an explicit invertible intertwiner $W=\begin{pmatrix}1&1\\1&0\end{pmatrix}$
over $\mathbb F_2$ satisfies $R_gW=W(g^{-T})^T$ for all three generators of
$\mathrm{GL}_2(\mathbb F_2)$, i.e. $B_2(\mathbb F_2^2)$ is isomorphic, as a
$\mathrm{GL}_2(\mathbb F_2)$-module, to the contragredient of the natural module. This was
re-derived independently here from first principles (the character-permutation induced by the
generating matrices $T=\begin{pmatrix}1&1\\0&1\end{pmatrix}$ and
$S=\begin{pmatrix}0&1\\1&0\end{pmatrix}$, computed using the same $M^{-T}$ convention the
existing code already requires), and the reported action matrices for $T$ and $S$ were checked
by hand to satisfy the correct $S_3$ relations ($T^2=S^2=I$, $(TS)^3=I$). For $p=3$, rank
$7$, the analogous matrices were computed and checked (Smith-normal-form certificate,
group-relation products); at the time this was reported as "not identified with a named
representation." A follow-up pass here (`gl_classify_p3.jl`) closed this: feeding only the
three reported $7\times7$ matrices and the abstract generators $T,D,S$ into a fresh
computation, the full order-$48$ group $\mathrm{GL}_2(\mathbb F_3)$ was rebuilt by closure
under the generators, tracking the corresponding matrix product at every one of the 48
elements — with **zero contradictions**, which is itself strong independent confirmation
that the reported matrices form a genuine representation (consistent with, but stronger
than, the "$144/144$" composition checks already reported). Comparing the resulting
character against the ordinary character table of $\mathrm{GL}_2(\mathbb F_3)$ (computed
directly, not looked up) shows the $7$-dimensional module splits as exactly **two
irreducible constituents, each with multiplicity one**: a degree-$3$ and a degree-$4$
irreducible. The observed full degree spectrum of $\mathrm{GL}_2(\mathbb F_3)$ — $1,1,2,2,2,3,3,4$
— matches the standard classification of $\mathrm{GL}_2(\mathbb F_q)$'s ordinary irreducibles
exactly ($q-1$ linear, $q-1$ twisted-Steinberg of dimension $q$, one principal series of
dimension $q+1$, and $(q-1)(q-2)/2$ cuspidal pairs collapsing to $(q^2-1)/2-(q-1)$ terms of
dimension $q-1$; for $q=3$: $2,2,1,3$ representations of degrees $1,3,4,2$ respectively). The
degree-$4$ constituent acts on the center $\{\pm I\}$ by the scalar $-1$, matching the unique
mixed-character principal series $\mathrm{Ind}_B^G(\mathbf 1,\chi)$ for $\chi$ the nontrivial
character of $\mathbb F_3^\times$; the degree-$3$ constituent acts trivially on the center,
consistent with an (untwisted-on-the-center) Steinberg-type constituent — the two candidate
degree-$3$ irreducibles differ only on the order-$8$ and non-central order-$2$ classes, and
the module picks out one of them specifically (full character values in
`gl_classify_p3_output.txt`). This is a genuine, checkable identification, not a dimension
coincidence: it uses the actual character values of the actual representation, not just its
dimension.

**A composition-order correction found during this follow-up.** The original report states
in prose that "row matrices compose in application order ($h$ after $g$ gives $R_gR_h$)."
Rebuilding the group both ways shows this is backwards for the matrices as given: composing
as $R_g R_h$ produces $40$ contradictions among the $48$ group elements, while composing as
$R_hR_g$ (i.e. $g\mapsto R_g$ is an anti-homomorphism for the generators' own group law)
produces zero. This does not affect the classification above or the correctness of the
matrices themselves — every character value obtained is a rational integer, hence real, and
for a real character $\chi(g)=\chi(g^{-1})$ always, so the anti-homomorphism's character
equals that of the corresponding genuine representation. It is a correction to one sentence
of prose, not to the computation.

**A correction to the exploration's own working assumptions, found and fixed during the
computation.** The originally proposed generators $T$ (a transvection) and a diagonal matrix
$D$ do not generate $\mathrm{GL}_2(\mathbb F_p)$ — they share an invariant line, giving
$|\langle T,D\rangle|=2$ at $p=2$ and $6$ at $p=3$, against $|\mathrm{GL}_2(\mathbb
F_2)|=6$ and $|\mathrm{GL}_2(\mathbb F_3)|=48$. Adding the swap $S$ repairs this. Verified
independently here in a fresh GAP session for both primes.

**On tooling.** No GAP package is literally named `meataxe`; but GAP's built-in `MTX`
functionality (composition factors, Brauer characters, decomposition matrices) is present and
was exercised successfully — confirmed independently here by running
`MTX.CompositionFactors` on the natural $\mathrm{GL}_2(\mathbb F_2)$-module and obtaining a
single irreducible factor of dimension 2, matching what was reported. This resolves the
concern raised in the planning notes (`gl_module_notes.md` §5) that module-recognition
machinery might not be available in this environment: it is available, under GAP's own name
for it rather than the package name assumed going in.

**A third case, $p=5$.** Extending the same computation to $p=5$ (still $r=2,n=2$) is a direct
reuse of the certified pipeline (`gl_action.jl`'s `run_action`, parametrized by $p$ already):
$\mathrm{GL}_2(\mathbb F_5)$ has order $480$, the construction finished in under $5$ seconds,
and every certificate check passed ($1440/1440$ composition-product checks, full and residual
Smith-normal-form certificates, all as for $p=2,3$). Unlike $p=2,3$, the module here has
torsion: $\mathcal{BC}_2(\mathbb F_5^2)=(\mathbb Z/5)^2\times\mathbb Z^{46}$. A structural check
(does the action matrix mix the torsion and free coordinates) shows $(\mathbb Z/5)^2$ is an
invariant **submodule** (its coordinates never receive contributions from the free ones), but
the extension does not split (the free coordinates do pick up torsion contributions under the
action), so $\mathbb Z^{46}$ is only a well-defined **quotient** module, not a submodule
sitting inside $\mathcal{BC}_2(\mathbb F_5^2)$. Each piece was classified separately, since the
composition factors are well-defined even when the extension class between them is not
determined by this computation.

*The torsion piece, mod $5$.* Reduced mod $5$, the submodule's action was checked against
every one of the $480$ group elements (not just the three generators), with zero
inconsistencies. It does **not** match the natural module or its dual: two of the three
generators act as the identity. Testing directly against the hypothesis that the action
factors through the quadratic-residue character of the determinant (trivial when
$\det(g)$ is a nonzero square mod $5$, a fixed order-$2$ involution otherwise) confirmed it
exactly, checked over the full group. This is a genuinely different kind of answer from the
$p=2,3$ cases: not an irreducible or faithful piece, but a `1`-dimensional-in-effect action
(image of order $2$) riding on a $2$-dimensional space.

*The free quotient, $\mathbb Z^{46}$.* Its ordinary character was computed the same way as
the $p=3$ case (full $480$-element closure, character values as traces, GAP's own character
table of the same matrix group) and decomposes as **two distinct twisted-Steinberg
representations** (multiplicity $1$ each, dimension $5$) **plus five distinct principal
series representations** (one with multiplicity $2$, four with multiplicity $1$, dimension
$6$ each): $2\times5+1\times2\times6+4\times1\times6=10+12+24=46$, matching exactly, with
$\langle\chi,\chi\rangle=10$ (sum of the multiplicities squared) confirming the count. The
general degree classification of $\mathrm{GL}_2(\mathbb F_q)$'s ordinary irreducibles used
for $p=3$ generalizes cleanly to $q=5$: $4$ linear, $4$ twisted-Steinberg (degree $5$), $6$
principal series (degree $6$), $10$ cuspidal (degree $4$), sum of squares
$4+100+216+160=480$, matching $|\mathrm{GL}_2(\mathbb F_5)|$ exactly. None of the ten
cuspidal representations, and none of the four linear ones, appear in this particular
module.

*Two real bugs found and fixed while computing this*, in the spirit of the rest of this
report: GAP's `Z(5)^2` does not mean "the field element $2$" (it means the primitive
generator `Z(5)` raised to the second power, which is $4$ if `Z(5)`$=2$), silently producing a
smaller subgroup of order $240$ instead of $480$ until caught by exactly the same
full-closure consistency check used for $p=3$'s composition-order correction. Separately,
$\mathrm{GL}_2(\mathbb F_5)$'s ordinary character table is not all-rational (unlike
$\mathrm{GL}_2(\mathbb F_3)$'s, which was rational by luck, not by a general pattern), so the
multiplicity computation needed an explicit reduction step to a plain rational integer before
the result could leave GAP. Both are documented in `gl_classify_p5.jl`.

**The top piece for $p=2$ and the Steinberg module ($r=n=2,3,4$).** For $p=2$ the top piece
$\mathcal B_n(\mathbb F_2^n)$ is $(\mathbb Z/2)^{2^{n(n-1)/2}}$ for $n=2,3,4$, i.e. of dimension
$2,8,64$, which is the dimension of the Steinberg module of $\mathrm{GL}_n(\mathbb F_2)$
(for $n=1$ the value is $\mathbb Z$, so the pattern starts at $n=2$). A dimension match alone
is weak evidence, so the module structure was tested directly. For $n=3$, $\mathrm{GL}_3(\mathbb F_2)$
(order $168$) acts on $(\mathbb Z/2)^8$, with the action matrices obtained by generalizing the
certified pipeline to $r=3$ (`gl_action_r3.jl`, same certificate checks as for $r=2$, composition
checked on all $168$ elements). GAP's MeatAxe (`MTX`) shows the module is irreducible and
absolutely irreducible of dimension $8$, self-dual, and the image group has order $168$. The Brauer
character equals $8,-1,1$ on elements of order $1,3,7$, the Steinberg values, and the fixed space
of a Sylow $2$-subgroup has dimension $1$. Since the $2$-modular irreducibles of $\mathrm{GL}_3(\mathbb F_2)$
have dimensions $1,3,3,8$, an irreducible of dimension $8$ is the Steinberg module.

*Independent route.* `gl_steinberg_check.jl` repeats the test without the elimination and
Smith-normal-form machinery. Because $\mathcal B_n(\mathbb F_2^n)$ is an elementary abelian
$2$-group, it equals $\mathbb F_2^N/(\text{relations mod }2)$ with $N$ the number of generating
tuples. $\mathrm{GL}_n(\mathbb F_2)$ permutes the tuples, the relation subspace is checked to be
invariant, and the quotient module goes to MeatAxe. For $n=3$ ($N=28$) this reproduces the result
above. For $n=4$ ($N=840$, relation rank $776$, quotient dimension $64$, group of order $20160$)
the module is again irreducible and absolutely irreducible of dimension $64$, and on every
odd-order conjugacy class the absolute value of the Brauer character equals the $2$-part of the
centralizer order, as it does for the Steinberg character on $2$-regular elements. The signs were
not compared separately, and the identification for $n=4$ rests on irreducibility plus these
absolute values.

*What did not work.* The first attempt at $r=4$ with the full certified pipeline did not finish
(a $5040\times5040$ Smith transform exceeded a $240$s limit), see `gl_r3_codex_report.md`. The
elimination and the residual Smith form themselves ran in seconds and gave $(\mathbb Z/2)^{64}$.
The $\mathbb F_2$-linear-algebra route above avoids that bottleneck. The case $n=5$ ($376{,}992$
candidate tuples) was not attempted.

*Status.* The statement $\mathcal B_n(\mathbb F_2^n)\cong\mathrm{St}$ is verified for $n=2,3,4$ and
is a conjecture for general $n$. For odd $p$ the top piece is not a Steinberg module (it is free
of larger rank, e.g. $\mathbb Z^7$ for $p=3$), although twisted Steinberg representations occur
among its constituents for $p=3,5$. No relation between the two behaviours has been established.

**The top piece for larger $p$ ($r=n=2$, $p$ up to $23$).** The abelian group of the top piece
$B_2(\mathbb F_p^2)$ was computed with the untracked quotient routine for $p=3,\dots,23$:

| $p$ | torsion | free rank |
|---|---|---|
| 3 | none | 7 |
| 5 | $(\mathbb Z/5)^2$ | 46 |
| 7 | $(\mathbb Z/2)^3\times(\mathbb Z/7)^3$ | 159 |
| 11 | $(\mathbb Z/5)^5\times(\mathbb Z/11)^5$ | 855 |
| 13 | $(\mathbb Z/7)^6\times(\mathbb Z/13)^6$ | 1602 |
| 17 | $(\mathbb Z/4)^8\times(\mathbb Z/3)^8\times(\mathbb Z/17)^8$ | 4424 |
| 19 | $(\mathbb Z/3)^9\times(\mathbb Z/5)^9\times(\mathbb Z/19)^9$ | 6759 |
| 23 | $(\mathbb Z/2)^{11}\times(\mathbb Z/11)^{11}\times(\mathbb Z/23)^{11}$ | 14047 |

For $p\ge5$ the torsion is
$(\mathbb Z/p)^{(p-1)/2}\times\big(\mathbb Z/\tfrac{p^2-1}{24}\big)^{(p-1)/2}$. This was read off from
$p=5,7,11,13$ and then correctly predicted $p=17,19,23$, which were computed afterwards. It is an
empirical pattern on seven primes and has no proof. The case $p=3$ has no torsion (here
$p^2-1$ is not divisible by $24$). The integer $(p^2-1)/12$ also appears in the dihedral
formula of Paper §6.2, but no relation between the two is claimed.

*$p=7$ in detail* (certified action as for $p=2,3,5$, $|\mathrm{GL}_2(\mathbb F_7)|=2016$, all
$6048$ composition checks passed, `gl_action_p7.jl`, `gl_classify_p7.jl`, report
`gl_p7_codex_report.md`). The module is $(\mathbb Z/14)^3\times\mathbb Z^{159}$. The torsion is an
invariant submodule. Checked over all $2016$ elements, the action on it depends only on $\det g$.
The $7$-primary part is $\mathbf 1\oplus\det^2\oplus\det^4$, and the $2$-primary part is the regular
representation of $\mathbb Z/3$ over $\mathbb F_2$ (a trivial factor plus a $2$-dimensional
irreducible), both through the quotient of order $3$ of $\mathbb F_7^\times$. The free quotient
$\mathbb Z^{159}$ decomposes as $3$ cuspidal constituents (degree $6$), $3$ twisted-Steinberg
(degree $7$) and $12$ principal series (degree $8$, three with multiplicity $2$ and nine with
multiplicity $1$), with $\langle\chi,\chi\rangle=27$ and
$3\cdot6+3\cdot7+(3\cdot2+9)\cdot8=159$.

*Convention.* For $p=7$ the action is again an anti-homomorphism: comparing the directly computed
action of each of the $2016$ elements with the two BFS assignments gives $1891$ mismatches for
$R_{gh}=R_gR_h$ and $0$ for $R_{gh}=R_hR_g$.

*Non-splitting, and a correction to an earlier justification.* The extension of the free quotient by
the torsion does not split for $p=7$ at either prime, and, now established properly, not for $p=5$.
A section of the free quotient is $\mathrm{GL}_2$-equivariant exactly when a linear system over
$\mathbb F_\ell$ has a solution. For $p=7$ it has $1431$ equations and $477$ unknowns, with
coefficient rank $477$ and augmented rank $478$, at $\ell=2$ and at $\ell=7$. For $p=5$ it has
$276$ equations, $92$ unknowns, rank $92$ and augmented rank $93$. The earlier statement for $p=5$
rested only on the free-rows/torsion-columns block being nonzero in the chosen coordinates. That
shows the chosen lifts are not invariant but not that no invariant lifts exist, so it was not a
proof. The linear-system computation is.

*Torsion and the free quotient for $p=5,7,11,13$* (an independent computation,
`gl_verify.jl`, which takes the character from its definition as the trace of one representative
per conjugacy class and tests the torsion block on every element of $\mathrm{GL}_2(\mathbb F_p)$).
For $p=5,7,11,13$ the torsion block depends only on $\det g$ (checked on all $480$, $2016$,
$13200$, $26208$ elements), and its $p$-primary part is $\bigoplus_{j=0}^{(p-3)/2}\det^{2j}$, the
even powers of $\det$, each once. The free quotient decomposes as follows (twisted-Steinberg
constituents are $\mathrm{St}\otimes(\chi\circ\det)$, labelled by the parity of $\chi$):

| $p$ | rank | cuspidal | twisted Steinberg | principal series | $\langle\chi,\chi\rangle$ |
|---|---|---|---|---|---|
| 3 | 7 | 0 | 1, odd $\chi$, mult. 1 | 1 | 2 |
| 5 | 46 | 0 | 2, odd $\chi$, mult. 1 | 5 distinct (4 once, 1 twice) | 10 |
| 7 | 159 | 3, mult. 1 | 3, odd $\chi$, mult. 1 | 12 distinct (9 once, 3 twice) | 27 |
| 11 | 855 | 15, mult. 1 | 10, even $\chi$ mult. 1, odd $\chi$ mult. 2 | 35 distinct (25 once, 10 twice) | 105 |
| 13 | 1602 | 36, mult. 1 | 6, odd $\chi$, mult. 1 | 57 distinct (42 once, 9 twice, 6 three times) | 174 |
| 17 | 4424 | 64 (48 once, 16 twice) | 16, even $\chi$ mult. 1, odd $\chi$ mult. 2 | 108 distinct (80 once, 12 twice, 16 three times) | 424 |

In each row the dimension and $\langle\chi,\chi\rangle=\sum m_i^2$ were checked. No linear
characters occur. For $p=3,5,7$ the number of distinct twisted-Steinberg constituents is
$(p-1)/2$, each with multiplicity $1$, and this was extrapolated to $p=11$ before computing it.
**The extrapolation failed**: $p=11$ has all $10$ of them, with the even-$\chi$ ones once and the
odd-$\chi$ ones twice. At $p=13$ the pattern $(p-1)/2$ distinct, each once, returns, and at
$p=17$ the behaviour of $p=11$ appears again (all $16$, even $\chi$ once, odd $\chi$ twice). So the
twisted-Steinberg constituents follow one of two patterns, "odd $\chi$ once" for $p=3,5,7,13$ and
"even $\chi$ once, odd $\chi$ twice" for $p=11,17$.

*An observation, not a result.* The primes $2,3,5,7,13$ are exactly those for which the modular
curve $X_0(p)$ has genus $0$, and $p=11,17$ both have genus $1$. The prediction that $p=17$ would
deviate was made from this coincidence before $p=17$ was computed, and it held. This is one
successful test on top of the fit to $3,5,7,11,13$, so it is weak evidence. A competing description
that fits the same six primes is "$p\equiv2\pmod 3$ and $p>5$". The two differ at $p=19$ (genus $1$,
but $19\equiv1\pmod3$), which was not computed: with the present implementation $p=17$ already needs
about $11.6$ GB and $8$ minutes, and $p=19$ would need roughly $28$ GB. The genus of $X_1(p)$ also
appears in the paper's dihedral formula (Paper §6.2), but it does not distinguish $p=13$ from
$p=11$, so it is not the relevant quantity here.

*What was and was not certified for larger $p$.* The $p=11,13$ rows come from the same tracked
elimination and Smith-normal-form pipeline as the certified cases, with the quotient-map identity
$L\,Q=I$ asserted, but without the full certificate battery and without the composition checks over
the whole group. The non-splitting test was run only for $p=5,7$.

**Scope.** This is Priority 1/1b/3 data plus three fully worked, independently-checked
examples ($p=2$, $p=3$, and now $p=5$ with $r=n=2$), plus the Steinberg test for $p=2$ at
$r=n=3,4$, and not a general answer to Problem 6.1. Not attempted: $r=3$ actions for odd $p$,
$m<r$ induced pieces, or ring multiplication. What the $p=5$ case adds is a
second data point for the free-quotient pattern (two very different decompositions so far,
no visible pattern across primes yet) and a first example of a case where the module is not a
direct sum, which the $p=2,3$ cases did not raise at all. See `gl_module_notes.md` for the
parabolic-induction argument, `gl_module_codex_report.md` for the original computational log,
`gl_classify_p3.jl`/`gl_classify_p3_output.txt` for the $p=3$ classification, and
`gl_action_p5.jl`/`gl_classify_p5.jl` with their outputs for the $p=5$ case (raw tables,
GAP output, Smith-normal-form certificates, character values), and `gl_action_r3.jl`,
`gl_mtx_r3.*`, `gl_steinberg_check.jl` with their outputs for the Steinberg test.

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
* The $\mathrm{GL}_r(\mathbb F_p)$-module structure of $\mathcal{BC}_n(\mathbb F_p^r)$
  (Problem 6.1) is worked out for three cases with $r=n=2$ ($p=2,3,5$) and for $p=2$ at
  $r=n=3,4$ (Steinberg module, see above). $r=3$ actions for odd $p$,
  induced pieces with $m<r$, and the ring structure are open. The classification found for
  these three cases (contragredient natural module at $p=2$, a Steinberg-type plus
  principal-series decomposition at $p=3$, a reducible-but-not-split extension at $p=5$ whose
  two pieces decompose differently again) shows no visible pattern across primes yet, and is
  not connected to any general statement about the induced-module structure argued for in
  `gl_module_notes.md`.
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
