# $\mathrm{Aut}(G)=GL_r(\mathbb F_p)$ acting on $\mathcal{BC}_n(G)$, $G=\mathbb F_p^r$

Working notes toward Problem 6.1 of Tschinkel–Yang–Zhang ("Determine the ring structure of
$\mathcal{BC}_*(G)$, where $G=\mathbb F_p^r$"). Everything below labeled **[proved]** is a
derivation I did myself, checked against the actual definitions in the paper and against
this repo's code; **[standard fact]** is textbook representation theory cited without
re-proof; **[to verify]**/**[open]** mark what still needs a computational check or is a
genuinely open question. Nothing here has been reviewed by anyone else yet — that's what
Codex's pass is for.

## 1. Setup: why the conjugation relation is vacuous for abelian $G$

**[P, paper §6.1]** For $G$ abelian, Theorem 5.2 collapses to
$$\mathcal{BC}_n(G) = \bigoplus_{H'\subseteq G}\bigoplus_{H''\subseteq H'} \mathcal{B}_n(H'').$$
Reason **[proved, elementary]**: for $G$ abelian, conjugation by any $g\in G$ is the
identity map, so relation (C) is vacuous, and $Z_G(H)=G$ for every $H\le G$, so $Y$ ranges
over *all* subgroups with $H\subseteq Y\subseteq G$ — no quotient by any stabilizer. This
is exactly what `bc_structure.g`'s general machinery already computes when fed an abelian
`G`: every conjugacy class of subgroups is a singleton (conjugation trivial), and
`Orbits(N_G(H), Ys, OnPoints)` is the identity partition since $N_G(H)=G$ acts trivially.
**No new code is needed for the isomorphism-type computation** — `bc(bc_structure(G), n)`
already implements (6.1) correctly for any abelian `G`; this is confirmed below in §4.

## 2. $\mathrm{Aut}(G)=GL_r(\mathbb F_p)$ acts on $\mathcal{BC}_n(G)$

**[proved]** For $\varphi\in\mathrm{Aut}(G)$, define $\varphi_*$ on symbols by
$(H,Y,\beta)\mapsto(\varphi(H),\varphi(Y),\beta\circ\varphi^{-1})$. Check this descends to
$\mathcal{BC}_n(G)$, i.e. respects (O),(C),(V),(B2) (there is no separate check needed for
(C): it's vacuous as above, and $\varphi_*$ trivially respects the vacuous relation):

- **(O)**: $\varphi_*$ acts entrywise on $\beta$, so it commutes with permuting entries.
- **(V)**: $\varphi(H)=1 \iff H=1$ (automorphisms are injective); and
  $(\beta\circ\varphi^{-1})_i+(\beta\circ\varphi^{-1})_j = (\beta_i+\beta_j)\circ\varphi^{-1}$,
  which is $0$ iff $\beta_i+\beta_j=0$ (again, injectivity of $\varphi^{-1}$ on characters).
- **(B2)**: $H\subseteq Y\subseteq Z_G(H)=G$ becomes $\varphi(H)\subseteq\varphi(Y)\subseteq G$
  (using $\varphi(G)=G$); the blow-up construction ($\beta_1,\beta_2,\bar H=\ker(b_1-b_2)$,
  $\bar\beta$) is defined purely from the character group of $H$, and
  $\ker(b_1-b_2)\circ\varphi = \varphi^{-1}(\ker(b_1-b_2))$, so $\varphi_*$ commutes with
  forming $\bar H,\bar\beta$ too.

So $\mathrm{Aut}(G)$ acts on $\mathcal{SC}_n(G)$ preserving every relation, hence acts on
$\mathcal{BC}_n(G)$ itself — not just on each summand $\mathcal{B}_n(H'')$ individually, but
by *permuting the summands* according to how it permutes subgroups $H''\subseteq G$, in
addition to acting within each summand via the contragredient action on characters. This
confirms the plan's hypothesis. For $G=\mathbb F_p^r$, $\mathrm{Aut}(G)=GL_r(\mathbb F_p)$.

## 3. The graded piece of dimension $m$ is an induced module

Fix $0<m\le r$ and look at $M_m := \bigoplus_{H''\le G,\,\dim H''=m} \mathcal{B}_n(H'')$,
one graded piece of the sum in §1 (for a fixed choice of $H'$, or summed over $H'\supseteq
H''$ too — the argument below is the same either way, since $GL_r(\mathbb F_p)$ also
permutes the $H'$'s transitively within each dimension, by the same argument).

**[standard fact]** $GL_r(\mathbb F_p)$ acts transitively on the Grassmannian of
$m$-dimensional subspaces of $\mathbb F_p^r$.

**[proved, direct matrix computation]** Fix $H_0''=\langle e_1,\dots,e_m\rangle$. Writing
block matrices w.r.t. $\mathbb F_p^r=\langle e_1,\dots,e_m\rangle\oplus\langle
e_{m+1},\dots,e_r\rangle$, the stabilizer $P_m:=\mathrm{Stab}_{GL_r(\mathbb F_p)}(H_0'')$
(as a *set*, i.e. those $g$ with $g(H_0'')=H_0''$) is exactly
$$P_m = \left\{\begin{pmatrix}A&B\\0&D\end{pmatrix} : A\in GL_m(\mathbb F_p),\ D\in
GL_{r-m}(\mathbb F_p),\ B\text{ arbitrary}\right\}$$
(this is a maximal parabolic subgroup). Such a matrix sends $(x,0)\mapsto(Ax,0)$ for
$x\in\mathbb F_p^m$ — i.e. **its action on $H_0''$ itself depends only on the block $A$**;
the unipotent radical $U_m=\{B \text{ arbitrary}, A=I,D=I\}$ acts as the identity on
$H_0''$. So the action of $P_m$ on $\mathcal B_n(H_0'')$ factors through the surjection
$P_m\twoheadrightarrow GL_m(\mathbb F_p)$, $\begin{pmatrix}A&B\\0&D\end{pmatrix}\mapsto A$:
$\mathcal B_n(H_0'')$, as a $P_m$-module, is the **inflation** of the $GL_m(\mathbb
F_p)$-module structure that $\mathcal B_n(H_0'')\cong\mathcal B_n(\mathbb F_p^m)$ carries
from its *own* automorphism action (§2 applied recursively, with $r$ replaced by $m$).

**[standard fact, orbit/Mackey formula]** If a group $\Gamma$ acts transitively on a set
$X$ with point stabilizer $P$ at $x_0\in X$, and a compatible system of $P$-modules
$M_{x_0}$ is given at $x_0$ (extended to all $x\in X$ via the $\Gamma$-action), then
$\bigoplus_{x\in X}M_x \cong \mathrm{Ind}_P^\Gamma(M_{x_0})$ as $\Gamma$-modules.

**Conclusion [proved, modulo the two standard facts]:**
$$M_m \;\cong\; \mathrm{Ind}_{P_m}^{GL_r(\mathbb F_p)}\bigl(\mathrm{Infl}_{P_m}^{P_m}
\,\mathcal B_n(\mathbb F_p^m)\bigr),$$
i.e. **understanding $\mathcal{BC}_n(\mathbb F_p^r)$ as a $GL_r(\mathbb F_p)$-module reduces
recursively to understanding $\mathcal B_n(\mathbb F_p^m)$ as a $GL_m(\mathbb F_p)$-module,
for each $m\le r$, plus parabolic induction** — a real structural reduction, obtained before
computing a single matrix.

### A caveat found while writing this up

Dimension-counting alone does **not** test the induced-module claim: $\dim
\mathrm{Ind}_P^\Gamma(M) = [\Gamma:P]\cdot\dim M$ always holds by general nonsense (a free
basis of $\mathbb F[\Gamma]$ over $\mathbb F[P]$ has $[\Gamma:P]$ elements), and
$[\Gamma:P_m]$ is exactly the number of $m$-dimensional subspaces of $\mathbb F_p^r$ — so
"rank of $M_m$ equals (number of subspaces) $\times$ rank $\mathcal B_n(\mathbb F_p^m)$" is
just a restatement of (6.1) (§1), not new evidence for the module structure. A real test
needs either explicit matrices (which generator of $GL_r(\mathbb F_p)$ does what) or at
least the *isomorphism type* of $\mathcal B_n(\mathbb F_p^m)$ as an abstract $GL_m(\mathbb
F_p)$-representation (e.g. compared against known ones by character/Brauer character,
§5) — not just its dimension.

## 4. Computational plan, in priority order

**Priority 1 — free with existing code, no new engineering.**
Run `bc(bc_structure(G), n)` for $G=\mathbb F_p^r$, $r=1,2,3$, $p=2,3,5$, $n=1,2,3$ (as far
as scale allows, per `REPORT.md`'s documented limits). This is exactly formula (6.1); it
is a sanity check that nothing about the general machinery breaks on abelian input, and it
gives the raw isomorphism-type data (rank, torsion) needed as an input everywhere below.

**Priority 1b — $r=1$, cheap, reuses existing infrastructure.**
$\mathrm{Aut}(\mathbb F_p)=\mathbb F_p^\times$, cyclic of order $p-1$. `bn_quotient`
already accepts an arbitrary list of automorphism-permutations to quotient by (this is how
the $\{\pm1\}$ quotient for $\mathfrak D_p$ is computed). Feed it the *full* closure of
multiplication by a generator of $\mathbb F_p^\times$, not just $\{\pm1\}$, to get
$\mathcal B_n(\mathbb F_p)/\mathbb F_p^\times$. Compare against the already-tabulated
unquotiented $\mathcal B_n(\mathbb F_p)$ and the already-tabulated $\{\pm1\}$-quotient
(`REPORT.md`'s dihedral data) as consistency checks. **Caveat**: since $\mathbb
F_p^\times$ is cyclic, every one of its modules splits into $1$-dimensional eigenspaces —
there is no interesting "shape" to recognize here (no analogue of $\mathrm{Sym}^k$ vs
$\Lambda^k$ for a $1$-dimensional natural module). This case is a correctness check on the
general machinery and on §2's claim, not a real test of the hypothesis; the genuinely
interesting case starts at $m=2$.

**Priority 2 — real new work, but scoped to one small case first.**
For $r=m=2$ (the "top piece", $H''=$ all of $\mathbb F_p^2$): attempt to build the action
of a small generating set of $GL_2(\mathbb F_p)$ (e.g. a transvection and a diagonal
matrix, which generate $GL_2(\mathbb F_p)$) on the *generators before quotienting* of
$\mathcal B_n(\mathbb F_p^2)$, and track it through the same elimination/SNF pipeline that
already computes the quotient, to get matrices for the induced action on the surviving
free/torsion generators. Do **one** $(p,n)$ pair well (smallest first: $p=2,n=2$ or
$p=3,n=2$) before attempting to generalize. If this genuinely doesn't fit in the time
available, stop and report exactly what's missing (§6) rather than force something
fragile — same standard as the rest of this repo.

**Priority 3 — cheap dimension-only comparison, try this before Priority 2's matrices.**
Before attempting explicit matrices, compare $\mathrm{rank}\,\mathcal B_n(\mathbb F_p^m)$
(already available from Priority 1, no new code) against the *dimensions* of the classical
candidates, which are closed-form and need no representation-theory software:
$\dim\mathrm{Sym}^k(\mathbb F_p^m)=\binom{m+k-1}{k}$,
$\dim\Lambda^k(\mathbb F_p^m)=\binom{m}{k}$, $\dim\mathrm{St}(GL_m(\mathbb
F_p))=p^{m(m-1)/2}$ (Steinberg module), for the natural module and its dual. This is
cheap arithmetic and could give a real (if partial) signal — or rule things out — before
committing to the harder matrix computation of Priority 2.

## 5. If a match (or non-match) is found

To go beyond dimension-counting toward actually *recognizing* the module (not just its
dimension), the standard tool is the module's composition factors / Brauer character in
the defining characteristic $p$ — this is exactly what MeatAxe-type algorithms compute. It
is not yet known whether this is available in this OSCAR/GAP installation; **check first**
(`TestPackageAvailability` for a MeatAxe-related GAP package, or whether
`AbstractAlgebra`/`Oscar` has an equivalent) **before** assuming it needs to be built from
scratch, and before assuming it doesn't exist.

## 6. What "genuinely inconclusive" looks like here, and why that's still worth reporting

Problem 6.1 is explicitly posed as open in the paper. A plausible, honest outcome of this
exploration is: the theoretical reduction of §3 (proved), the abstract-group data of
Priority 1 (numbers, not modules), and a clear statement of exactly which piece of
representation-theoretic machinery (decomposition matrices / Brauer characters /
MeatAxe-equivalent tooling in defining characteristic) would be needed to go from "we know
the dimension" to "we know the module" — without that last step landing today. That is a
legitimate, useful thing to hand to the paper's author: not a solved problem, but a precise
account of how far the reduction goes and exactly what's missing to finish it.
