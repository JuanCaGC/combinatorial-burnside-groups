"""Assemble the report from saved actual output; does not rerun computations."""
from pathlib import Path
root=Path(__file__).resolve().parent
read=lambda name:(root/name).read_text()
raw=read('gl_data_output.txt')
rows=[line.split('\t')[1:] for line in raw.splitlines() if line.startswith('DATA\t')]
report='''# GL-module exploration for elementary abelian groups

Date: 2026-09-23. Working directory throughout: `/Users/juancagc/Groups/task-gl-module`.
Julia 1.12.4, OSCAR 1.8.2, GAP 4.16.1; installed project/manifest used unchanged.

## Scope and evidence labels

The required sources were read in the requested order before writing code: all of
`gl_module_notes.md`, `guia/04_el_codigo.md` §9, `bc_structure.g`, and `BurnsideC.jl`
(including `bn_quotient`). Scale and comparison data came from `REPORT.md`, `CODEX_LOG.md`,
and the guide. No existing project file was edited. All scripts and output below are additive.
The previously confirmed computation of BC₂(F₂²) was accepted, not independently
re-derived or checked with `bc_direct`; its requested grid entry is included normally.
Priority 2's subsequent B₂(F₂²) presentation/action checks concern the newly constructed
module matrices, not a repetition of the BC decomposition verification.

* **NEW COMPUTATION:** 26 of the 27 requested BC values completed through the existing
  `bc(bc_structure(G), n)` API, with the structure reused for each group. One case was
  deliberately skipped on the documented scale estimate. These totals have no new
  independent ground-truth verification, except where already known in the supplied sources.
* **VERIFIED:** cyclic n=2 comparisons match the supplied tables. The two new GL₂ actions
  have independently checked integer certificates, presentations and action identities.
  In characteristic 2 an explicit invertible intertwiner identifies the resulting
  two-dimensional module with the contragredient natural module.
* **INCONCLUSIVE:** dimension coincidences do not identify representations. The rank-seven
  integral GL₂(F₃) module has explicit matrices, but was not classified. Ring multiplication,
  r=3 actions, and m<r actions were not attempted.

## Priority 1 — raw BC data

`gl_data.jl` calls GAP's `ElementaryAbelianGroup(p^r)`, then the existing `bc_structure`
and `bc`. The table gives the printed **AbGroup** value, the number of nontrivial-H
classes [H,Y], and timings in seconds. `structure_s` includes Julia conversion and first-call
compilation; it is measured once per (p,r) and repeated in each row for convenience.
`bc_s` is the existing `BCResult.seconds`. Each fresh process's first n=1 call includes
compilation (~0.4s). Neither column includes OSCAR startup; complete process times
(including startup, ~13s here) are preserved below. Add the two columns for a cold
structure-plus-one-degree time; do not add the repeated structure time across degrees.
No cache was shared between degrees or processes; the existing within-degree cache was used.

`top_B` is the value of the unique H=Y=G summand, extracted from the same result,
not the free rank of the whole BC group. When n<r it is zero by the existing
minimum-generator shortcut. This is the input to Priority 3.

| p | r | n | BC_n(F_p^r) | [H,Y] | structure_s | bc_s | top_B | top free rank |
|---|---|---|---|---|---|---|---|---|
'''
for row in rows: report+='| '+' | '.join(row)+' |\n'
report+='''
**SKIPPED, not zero:** (p,r,n)=(5,3,3). The existing routine would first enumerate
C(125+3−1,3)=333,375 multisets for H=G. Even the unordered generating triples alone
number (125−1)(125−5)(125−25)/6=248,000. `REPORT.md` calls roughly 10^5 generators
impractical and records a ~3×10^5-generator He₁₁ case failing to finish in eight minutes.
This case was therefore not started. Its class count is 311 from the completed structure
calculation, but no BC₃ value or top-piece rank is claimed.

`gl_run_data.py` imposes a 180-second timeout on each entire group process, including
startup and all its degrees; this is stricter than a separate few-minute allowance for each
computation. None of the successful processes approached the limit.

Actual saved stdout (`gl_data_output.txt`):

```text
'''+raw+'```\n'
report+='''
## Priority 1b — full multiplicative-group coinvariants

`gl_cyclic.jl` uses `CharCtx`, `char_perm` and `perm_closure` directly, and passes the
**full closure** to the existing `bn_quotient`. Primitive roots are 1,2,2 for p=2,3,5.
The script verifies the root orders, closure sizes p−1, and inclusion of the minus-one
closure. Empty permutations give the unquotiented group. The printed lists below include
identity and all powers, not just the generator or an order-two subgroup.

Actual output (columns: p, n, unquotiented, {±1} quotient, full quotient, elapsed seconds
for the three calculations together):

```text
'''+read('gl_cyclic_output.txt')+'''```

**Verified against supplied tables:** all six n=2 comparisons, unquotiented and ±1 for
p=2,3,5, passed structural `AbGroup` equality assertions against the guide §2.
For p=5 the ±1 value also matches the dihedral [C₅,C₅] summand in `REPORT.md`.
For p=3 it is the C₃ summand in S₃; p=2 has trivial automorphism group.
These are previously tabulated computational/hand-derived comparisons, not new claims
of a published ground truth for every cyclic degree.

**Why the new results are consistent:** if A⊆C are automorphism groups then the relation
subgroup generated by x−a(x) is contained in that generated by x−c(x). Thus the identity
on the original presentation induces a **surjection** B_A → B_C. The computed closures
verify the needed inclusion concretely. For p=2 and p=3 the two closures are equal,
so their coinvariants must agree, and do. For p=5,n=2 the chain is
Z² → (Z/2)² → Z/2: the finite order drops from 4 to 2 and exponent remains 2, a valid
further quotient. No torsion is required to divide the torsion of the *unquotiented*
group: quotienting a free group can create torsion. For n=1,p=5 the free ranks fall
4 → 2 → 1, consistent with identifying the four nonzero characters first in two ±1
orbits and then in one multiplicative orbit. The n=3 groups are already zero and remain
zero. The new full p=5 quotient is a computation plus these consistency checks; it was
not compared against an external published value.

## Priority 3 — dimensions before action engineering

`gl_dimensions.py` reads the top-piece free ranks from Priority 1 and evaluates
Sym^k dimension C(m+k−1,k), exterior-power dimension C(m,k), and Steinberg dimension
p^{m(m−1)/2}. The search window is **k=0,…,6**, stated explicitly to avoid implying
an unbounded search. Natural and dual candidates have the same dimensions.
Zero exterior powers for k>m are printed but deliberately excluded as informative matches.

Actual arithmetic output:

```text
'''+read('gl_dimensions_output.txt')+'''```

All positive matches in that window are:

* (p,m,n)=(2,1,1) and (3,1,2), free rank 1: all listed symmetric powers,
  exterior powers k=0,1, and the GL₁ Steinberg dimension 1.
* (3,2,2), free rank 7: Sym⁶ dimension 7.
* (3,2,3), free rank 3: Sym² dimension 3 and the GL₂(F₃) Steinberg dimension 3.

There are **no other positive matches in this window**. There is no coherent recognition
pattern here. In dimension m=2, Sym^k has dimension k+1, so any positive integer rank
can be made to match by choosing k: specifically ranks 46 and 22 would match k=45 and
21 outside the window. Likewise rank 66 at (3,3,3) equals Sym¹⁰ dimension C(12,10),
also outside the window. These arithmetic coincidences are not evidence of isomorphism.

The distinction between free rank and characteristic-p dimension matters: free rank is
the dimension after tensoring with Q, whereas tensoring with F_p adds one dimension for
each p-primary cyclic torsion factor. For example the rank-zero groups B₂(F₂²)=(Z/2)²
and B₃(F₂³)=(Z/2)^8 are not zero F₂-modules; their F₂ dimensions are 2 and 8.
The requested rank-only scan therefore does not exclude a characteristic-p candidate
for a torsion group. No representation match is asserted on dimension evidence alone.

## Priority 2 — explicit GL₂ actions, completed for p=2 and p=3, n=2

This work began only after Priorities 1, 1b and 3 completed. No r=3 or m<r action
was attempted.

### Correcting the proposed generating set

The standard matrices used are T=[[1,1],[0,1]], D=diag(a,1), and S=[[0,1],[1,0]],
where a=1 for p=2 and a=2 for p=3. GAP checked the actual generated-group orders:
<T,D> has order 2 rather than 6 at p=2, and order 6 rather than 48 at p=3.
The standard T and diagonal D preserve a common line; they do **not** generate GL₂.
At p=2 every invertible diagonal matrix is identity. Adding S repairs the set, as
GAP verifies by orders 6=|GL₂(F₂)| and 48=|GL₂(F₃)|. This correction concerns the
specific proposed standard choice, not a universal assertion about every possible
transvection/diagonal pair over every field.

### Coordinates, elimination, and certificate

Group elements g act on **column** vectors of G. A character coefficient column transforms
by g^{-T}, as required by β↦β∘g^{-1}. We feed exactly that integer matrix modulo p
into `char_perm`. Generator tuples are the exact ordered enumeration
`[ms for ms in multisets(p^2,2) if generates_all(ctx,ms)]` used in `bn_quotient`.
The presentation itself is returned by its existing `return_presentation=true` option.

`gl_tracked_elimination.jl` is an additive instrumented copy of the existing unit-pivot
loop: row ordering, pivot selection, and updates are unchanged. At a unit pivot c with
coefficient ε it records x_c=−ε∑_{k≠c} row[k]x_k. Reverse substitution yields E, expressing
all original generators in surviving-generator coordinates; J selects the survivors.
The residual matrix M retains zero columns to record free generators explicitly
(the original routine accounts for these by its free-rank count).

The same residual Smith step is used, with `snf_with_transform` instead of `snf` to retain
U,V satisfying UMV=D. No residual rows survive at p=3, so V=I and the Smith step is
vacuous, just as the original routine returns a free group immediately in that case.
For row-coordinate permutation P, the surviving action is JPE, and the Smith-coordinate
action is **V^{-1}JPEV**. Unit diagonal factors are removed; entries in a target torsion
coordinate are reduced modulo its invariant factor. The reported matrices use **rows
as images of basis generators**. For the usual column-vector matrices of a left
representation, transpose each reported matrix. Row matrices compose in application
order (h after g gives R_g R_h).

No canonical pivot selection across automorphic presentations is needed: every action
is transported through the **same fixed** quotient map. What was absent from the original
API was the elimination substitution trace and Smith change of basis, not existence of
an equivariant quotient. They are now retained in this scoped additive script.

The checks establish actual quotient maps, not only matching invariant factors:
JE=I; the rows of AEV lie in the diagonal relation lattice of D; rows of MJV₀ and
(I−EJ)V₀ lie in the diagonal relation lattice of the full original Smith form D₀.
Together these show that projection E and lift J induce inverse maps on the two
presented groups. Full and residual transforms are checked for unimodularity and
UAV=D. Every generator preserves the relation lattice. All 6×3 and 48×3 composition
identities are checked. All these data are preserved in `gl_action_certificates.txt`.

### Actual matrices and output

For p=2 the final basis is the tuple pair
u=((1,0),(0,1)), v=((0,1),(1,1)), with 2u=2v=0.
The resulting row matrices are T↦[[0,1],[1,0]], D↦I, S↦[[1,0],[1,1]].
The invertible matrix W=[[1,1],[1,0]] over F₂ satisfies
R_g W = W (g^{-T})^T for all three generators. **This is a verified module
identification with the contragredient natural GL₂(F₂) module**, stronger than a
dimension match. No separate Steinberg identification is claimed.

For p=3 the final free basis is given by tuple indices [1,3,7,8,10,18,19] in the
printed enumeration, equivalently:
((1,0),(0,1)), ((1,0),(2,1)), ((2,0),(0,1)), ((2,0),(1,1)),
((2,0),(0,2)), ((1,1),(0,2)), ((1,1),(1,2)).
The exact integer 7×7 matrices, all tuple permutations, and projection/lift matrices
are pasted below. The integral module has not been recognized as a named representation;
in particular rank 7 alone does not identify its mod-3 reduction with Sym⁶.

```text
'''+read('gl_action_output.txt')+'''```

### Independent verification

`gl_verify_action.py` uses only Python integers, list multiplication, and a fraction-free
integer determinant; it does not call Julia, GAP, OSCAR, a Smith routine, or a numerical
library. It independently enumerates unordered bases of F_p² (3 and 24 respectively),
and reconstructs the n=2 blow-up relation rows from character subtraction. In this case
independence excludes zeros, duplicate characters, and opposite pairs, so there are no
additional duplicate/vanishing rows to check. It verifies the saved full and residual
Smith certificates, determinant ±1, diagonality/divisibility, quotient maps, action
matrices and all group composition identities. This certifies these two presentations
and their transported actions; it does not independently certify every Priority 1 total.

Actual verifier stdout:

```text
'''+read('gl_verify_action_output.txt')+'''```

## Installation check — defining-characteristic tools really available

`gl_packages.jl` queried both package availability and bound functions, then ran actual
smoke tests. Exact output, including the installed package-name inventory:

```text
'''+read('gl_packages_output.txt')+'''```

Thus a package literally named `meataxe`, `meataxe64`, or `cmeataxe` is **not available**
under those names, but it would be incorrect to conclude that MeatAxe functionality is
absent: GAP's **built-in MTX** is loaded and successfully computes the two-dimensional
irreducible composition factor of the natural GL₂(F₂) module. Its record includes
composition factors, module isomorphisms and composition-series operations. `ctbllib`,
`atlasrep`, `repsn`, and `recog` are available; availability alone is not a claim of
universal recognition capability. A Brauer-value calculation returns −1 for the
order-three matrix over F₂, and the library S₃ characteristic-2 decomposition matrix
returns [[1,0],[1,0],[0,1]]. This demonstrates concrete functioning examples, not an
algorithm guaranteed to derive unknown decomposition matrices for arbitrary groups.

The installed OSCAR sources also contain wrappers in `src/Groups/group_characters.jl`
for `DecompositionMatrix` and `BrauerCharacterValue`; the live GAP tests above are the
stronger evidence of availability. Further recognition of the p=3 lattice/reduction
could use this existing tooling. Missing package availability is **not** an obstacle
found in this task.

## Reproduction, limits, and files

Run from the stated task directory, in this order:

```sh
python3 gl_run_data.py
python3 gl_run_aux.py
python3 gl_run_action.py
python3 gl_verify_action.py > gl_verify_action_output.txt
python3 gl_make_report.py
```

The runners use the installed Julia 1.12.4 binary explicitly and `--project=.`;
`gl_run_aux.py` runs cyclic quotients, the dimension scan, then the package probe.
Each Julia process has a 180-second wall limit. The bootstrap redirects only runtime
bookkeeping into `gl_scratch/` and `gl_local_depot/logs/`, and disables scratch usage
tracking. An initial launcher attempt failed with “Could not create lockfile”; using
the binary directly avoided Juliaup's write. OSCAR then initially failed on scratch
`mktemp` and `manifest_usage.toml.pid` outside the writable directory. The final
`gl_bootstrap.jl` uses Scratch's process-local directory override and a process-local
`Pkg.logdir()` override. Package resolution, installed package files, source code,
Project.toml and Manifest.toml are untouched. `--compiled-modules=existing` prevents
new precompilation writes. These startup failures occurred before mathematical
computation and are not included in successful case timings. No approval was needed.

New source files:
`gl_bootstrap.jl`, `gl_data.jl`, `gl_run_data.py`, `gl_cyclic.jl`, `gl_dimensions.py`,
`gl_packages.jl`, `gl_run_aux.py`, `gl_tracked_elimination.jl`, `gl_action.jl`,
`gl_run_action.py`, `gl_verify_action.py`, `gl_make_report.py`.
New saved outputs:
`gl_data_output.txt`, `gl_cyclic_output.txt`, `gl_dimensions_output.txt`,
`gl_packages_output.txt`, `gl_action_output.txt`, `gl_action_certificates.txt`,
`gl_verify_action_output.txt`, and this `CODEX_REPORT.md`.
Runtime scratch/cache directories are disposable and regenerated by the bootstrap.

The intentional outstanding computation is BC₃(F₅³), skipped for scale. The outstanding
mathematics is identification of the p=3 module, larger-rank/fixed-dimension induced
pieces and ring multiplication. None is presented as solved. Within the requested small
Priority 2 cases, there is no unresolved elimination/SNF obstacle: both actions and
their quotient maps were constructed and independently checked.
'''
(root/'CODEX_REPORT.md').write_text(report)
