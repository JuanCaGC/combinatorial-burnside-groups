The rank-three computation identifies B_3(F_2^3) with the 8-dimensional Steinberg module over F_2, using the uniqueness of the 8-dimensional irreducible stated in the task. The computed module is irreducible, absolutely irreducible and isomorphic to its dual. Its only composition factor has dimension 8. The independent Brauer values are 8 at the identity, -1 on the order-3 class and 1 on each of the two order-7 classes. Its Sylow-2 fixed space has dimension 1.

All work was performed in `/Users/juancagc/Groups/task-gl-r3`. The existing action, elimination and Burnside files were read and reused without edits. No git command was run. The launch wrapper uses Julia 1.12.4 with `--project=.`, `--startup-file=no`, `--compiled-modules=existing` and the existing `gl_bootstrap.jl`. It also redirects temporary files and Julia history into this directory. The bootstrap redirects Scratch and Pkg bookkeeping here.

The new implementation accepts prime p and rank r at least 2, with n=r. The default run is p=2 and r=3. It uses I+E_12, a cyclic permutation and the swap of coordinates 1 and 2. For odd p it also adds a primitive scalar on the first coordinate. Only p=2 was exercised in this task. GAP confirmed that the requested rank-three generators already generate all 168 elements, so no adjustment was needed.

The certificate checks are the following.

- Compute the full original integer Smith form with transforms. Verify U A V = D, both unimodular determinants, diagonality and divisibility, including the placement of zero entries.
- Independently run the existing tracked unit-pivot elimination and certify its residual Smith form with the same checks.
- Verify J E = I. Verify that original relations project into the residual relation lattice, residual relations lift into the original lattice, and I-EJ has image in the original relation lattice. These establish mutually inverse quotient maps. Also check the final coordinate identity L Q = I exactly over the integers.
- Compare the resulting abelian group with the original `bn_quotient` computation. All eight final moduli are 2.
- Feed exactly the inverse transpose of each column-vector group matrix into `B.char_perm`. For every generator verify preservation of the original relation lattice and compatibility of the projected tuple action with the final coordinate action.
- Enumerate the full character-permutation closure and verify composition on all 168 elements against all three generators, giving 504 checks.
- Independently rebuild GAP's matrix group by a genuine FIFO BFS, with generators followed by their inverses. Check 1008 edges under each multiplication convention. Repeat the homomorphism check after transposing the row matrices before calling MeatAxe.

There is an important refinement to the convention warning. Both BFS contradiction counts are zero for these particular generators. That does not mean the actual row action is a homomorphism. Directly compute the tuple action for every group element, then compare that assignment with both BFS assignments and test both product identities on all 1008 edges. The actual row action is an anti-homomorphism. The forward BFS assignment differs from it on 140 elements and the forward product identity fails on 970 edges. The reverse assignment and reverse product identity have zero mismatches.

The ambiguity has a concrete explanation. With S the chosen transposition, the map g ↦ S g^T S reverses products and fixes all three generators, including the chosen 3-cycle. GAP verifies that composing the actual anti-homomorphism with this map gives the forward BFS assignment on every element. Thus relations among these generators alone do not distinguish the two assignments. The matrices sent to `GModuleByMats` are transposes of the directly computed row matrices, giving the genuine homomorphism g ↦ R_g^T.

The MeatAxe calls are `MTX.IsIrreducible`, `MTX.IsAbsolutelyIrreducible`, `MTX.CompositionFactors`, `MTX.DualModule` and `MTX.IsEquivalent`. The independent fixed-space computation constructs the Sylow subgroup of the original 3 by 3 matrix group and computes the common nullity of its transported generator matrices minus the identity. The Brauer computation does not use the MeatAxe classification or a character table. For every odd-order class representative it finds all eigenvalue multiplicities over a splitting finite field by matrix ranks, then sums their lifts to complex roots of unity using exact GAP cyclotomic arithmetic. The multiplicities must sum to the module dimension. The rational values here are insensitive to the choice of primitive root. Comparison values 8, -1 and 1 are the Steinberg values supplied in the task. Brauer characters are evaluated only on 2-regular elements. The vanishing statement on 2-singular elements concerns the ordinary Steinberg character, and was not used as a Brauer-character test.

Raw rank-three action output follows. Full original and residual certificate matrices, projection maps and lifts are also saved in `gl_action_r3_certificates.txt`.

```text
2026/10/07 11:45:12.0294: [11853982]:  WARNING:       mongoc: Falling back to malloc for counters.

GENERATORS p=2 r=3 labels=["T", "C", "S"] generated_order=168 GL_order=168
PRESENTATION characters=8 candidates=120 generating_tuples=28 relations=84 seconds=0.029586076736450195
FULL_SNF seconds=0.0055658817291259766 certificate=true
ELIMINATION_AND_QUOTIENT seconds=0.09464883804321289
ACTION_CASE p=2 r=3 n=3 B=(Z/2)^8 ngens=28 nrels=84 pivots=20 residual=(58, 8) moduli=[2, 2, 2, 2, 2, 2, 2, 2]
FINAL_PROJECTION_Q=[[1, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, -1], [0, 1, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, -1, 0, 0, -1], [1, 0, 0, 0, 0, -1, 0, 0], [1, 0, 0, 0, 0, 0, -1, -1], [0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0], [1, -1, 0, 0, 0, 0, 0, 0], [1, 0, 0, -1, 0, -1, 0, 0], [1, 0, -1, 0, 0, 0, -1, -1], [0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0], [0, 1, -1, 0, 0, 0, 0, 0], [1, 0, 0, -1, -1, 0, 0, -1], [0, 0, 0, 0, 0, 0, 0, 1], [-1, 0, 0, 1, 1, 1, 0, 1], [0, -1, 1, 0, 0, 0, 1, 0], [-1, 1, 0, 0, 1, 0, 0, 1], [0, 0, 0, 0, 0, -1, 1, 1], [0, -1, 1, 0, 0, 1, 0, 0], [-1, 0, 0, 1, 1, 0, 1, 1], [0, 0, 1, -1, 0, 0, 0, 0], [0, -1, 1, 0, 0, 0, 1, 1], [1, 0, 0, -1, -1, -1, 0, 0], [0, -1, 0, 1, 0, 1, 0, 0], [1, 0, -1, 0, -1, 0, -1, -1]]
FINAL_LIFTS_L=[[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
GEN T group_matrix=[[1, 1, 0], [0, 1, 0], [0, 0, 1]] character_matrix=[[1, 0, 0], [1, 1, 0], [0, 0, 1]] tuple_permutation=[13, 16, 15, 14, 5, 8, 7, 6, 22, 21, 24, 23, 1, 4, 3, 2, 18, 17, 20, 19, 10, 9, 12, 11, 27, 26, 25, 28] final_row_matrix=[[0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0, 1, 1], [1, 0, 0, 1, 1, 0, 1, 1], [1, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 1, 0, 0, 1], [1, 0, 0, 1, 1, 1, 0, 1]]
GEN C group_matrix=[[0, 0, 1], [1, 0, 0], [0, 1, 0]] character_matrix=[[0, 0, 1], [1, 0, 0], [0, 1, 0]] tuple_permutation=[1, 13, 17, 18, 3, 15, 19, 20, 2, 4, 14, 16, 9, 22, 25, 27, 5, 10, 21, 26, 7, 11, 24, 28, 6, 8, 12, 23] final_row_matrix=[[1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 0, 0, 0, 1, 0], [1, 1, 0, 0, 1, 0, 0, 1], [1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 0, 0, 0, 0], [0, 1, 1, 0, 0, 1, 0, 0], [1, 0, 0, 0, 0, 1, 0, 0]]
GEN S group_matrix=[[0, 1, 0], [1, 0, 0], [0, 0, 1]] character_matrix=[[0, 1, 0], [1, 0, 0], [0, 0, 1]] tuple_permutation=[1, 3, 2, 4, 13, 15, 14, 16, 17, 18, 19, 20, 5, 7, 6, 8, 9, 10, 11, 12, 22, 21, 24, 23, 25, 27, 26, 28] final_row_matrix=[[1, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0], [1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 1, 0, 0, 1], [1, 0, 0, 0, 0, 1, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0], [1, 1, 0, 0, 0, 0, 0, 0]]
CLOSURE_START elements=168 field_arithmetic=false
CHECKS full_SNF_certificate=true residual_SNF_certificate=true quotient_maps_inverse=true relation_lattice_preserved=true closure=168 action_products=504/504 seconds=0.13632798194885254
ACTION_SECONDS p=2 r=3 time=0.5715348720550537
RUN_EXIT 0 WALL_SECONDS 15.853

```

Raw rank-three GAP and MeatAxe output follows.

```text
2026/10/07 11:46:03.0312: [11855276]:  WARNING:       mongoc: Falling back to malloc for counters.

JULIA_VERSION 1.12.4 OSCAR_VERSION 1.8.2
GAP_VERSION 4.16.1
CONVENTION hom_closure=168 hom_contradictions=0 hom_edges=1008
CONVENTION anti_closure=168 anti_contradictions=0 anti_edges=1008
DIRECT_ACTION hom_assignment_mismatches=140 anti_assignment_mismatches=0 hom_product_mismatches=970 anti_product_mismatches=0 edges=1008
BFS_AMBIGUITY map_S_transpose_g_S_fixes_generators=true explains_both_assignments=true
SELECTED anti_homomorphism. GAP receives transposes of row matrices
GENUINE_HOM closure=168 contradictions=0 edges=1008 image_order=168
MTX dimension=8 irreducible=true absolutely_irreducible=true factor_dimensions=[ 8 ] self_dual=true
SYLOW_FIXED subgroup_order=8 dimension=1 Steinberg_expected=1 match=true
BRAUER order=1 class_size=1 value=8 eigen_multiplicities=[ 8 ] Steinberg_expected=8 match=true
BRAUER order=7 class_size=24 value=1 eigen_multiplicities=[ 2, 1, 1, 1, 1, 1, 1 ] Steinberg_expected=1 match=true
BRAUER order=7 class_size=24 value=1 eigen_multiplicities=[ 2, 1, 1, 1, 1, 1, 1 ] Steinberg_expected=1 match=true
BRAUER order=3 class_size=56 value=-1 eigen_multiplicities=[ 2, 3, 3 ] Steinberg_expected=-1 match=true
MTX_ANALYSIS_CPU_SECONDS 99/1000
MTX_SCRIPT_COMPLETE
RUN_EXIT 0 WALL_SECONDS 12.657

```

Rank four was attempted only after all rank-three checks had passed. The probe examined 3876 candidate multisets, 840 generating tuples and 5040 relations. Tracked elimination took about 0.031 seconds and left a 3712 by 64 residual matrix. Residual SNF and its product check took about 2.432 seconds and gave 64 diagonal entries equal to 2. This is an exploratory residual computation, not a completed full action certificate or module classification.

```text
2026/10/07 11:42:41.0476: [11849023]:  WARNING:       mongoc: Falling back to malloc for counters.

PROBE p=2 r=4 n=4 Julia=1.12.4 Oscar=1.8.2
PROBE_PRESENTATION candidates=3876 generating_tuples=840 relations=5040 seconds=0.015748023986816406
PROBE_FULL_LEFT_TRANSFORM_ENTRIES 25401600
PROBE_ELIMINATION seconds=0.030961036682128906 pivots=776 residual=(3712, 64)
PROBE_RESIDUAL_SNF seconds=2.4322988986968994 moduli=[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
PROBE_COMPLETE
RUN_EXIT 0 WALL_SECONDS 38.464

```

Because the quick elimination test passed, the full rank-four action was attempted with a 240-second wall limit including startup. The original relation matrix needs a 5040 by 5040 left Smith transform, with 25401600 entries. The run timed out in the block computing the full original SNF and checking its transformed product and unimodular determinants. It never reached the `FULL_SNF` completion marker, so there is no finer timing separating the SNF calculation from those checks. This combined block dominated the attempted computation. The fast unit-pivot elimination was not the limiting step in the probe. The timeout was not bypassed and the run was not resumed.

```text
2026/10/07 11:43:46.0321: [11851749]:  WARNING:       mongoc: Falling back to malloc for counters.

GENERATORS p=2 r=4 labels=["T", "C", "S"] generated_order=20160 GL_order=20160
PRESENTATION characters=16 candidates=3876 generating_tuples=840 relations=5040 seconds=0.03488302230834961
TIMEOUT 240s WALL_SECONDS 240.035

```

The rank-four certificate file was opened but remained empty. No rank-four action data file was produced. Consequently no rank-four MeatAxe call was made. Its output filename contains this explicit status, not a purported computation result.

```text
R4_MTX_NOT_RUN. The certified rank-four action timed out after 240 seconds before producing action matrices.

```

A read-only attempt to inspect process CPU and memory use was rejected by the sandbox. No alternate monitoring method was attempted. The saved diagnostic is below.

```text
COMMAND ps -axo pid,etime,pcpu,rss,command
zsh:1: operation not permitted: ps
EXIT_CODE 1

```

The only rank-three execution issue was output capture. The first MeatAxe script reached its completion marker with exit code 0, but GAP `Print` text did not reach the redirected Julia output. That initial output is retained below. The corrected script writes GAP output to a local text stream, closes it, then copies it to Julia stdout. All reported results come from rerunning the corrected script, including the direct-action comparison and the explanation of the BFS ambiguity.

```text
2026/10/07 11:39:18.0087: [11842986]:  WARNING:       mongoc: Falling back to malloc for counters.

JULIA_VERSION 1.12.4 OSCAR_VERSION 1.8.2
MTX_SCRIPT_COMPLETE
RUN_EXIT 0 WALL_SECONDS 14.919

```

The raw logs also retain the startup warning about mongoc falling back to malloc for counters. All final rank-three mathematical assertions passed and both final rank-three scripts exited with code 0. No general claim for untested primes or ranks is made. Rank four remains unfinished at the full-certificate stage.


Files created for this task are listed below. Existing research sources and launch helpers were not edited.

- `gl_action_r3.jl`, the general-rank certified action implementation. Its default is p=2 and r=3. A rank argument selects r=4.
- `gl_run_r3.py`, the bounded Julia launcher using the supplied bootstrap.
- `gl_mtx_r3.jl` and `gl_mtx_r3.g`, the GAP BFS, direct-action comparison, MeatAxe and independent character/fixed-space analysis.
- `gl_action_r3_output.txt`, `gl_action_r3_certificates.txt` and `gl_action_r3_data.g`, the final action log, integer certificates and machine-readable GAP input.
- `gl_mtx_r3_output.txt` and `gl_mtx_r3_gap_raw.txt`, the final Julia-captured and original GAP results.
- `gl_action_r3_initial_output.txt`, `gl_mtx_r3_initial_output.txt` and `gl_mtx_r3_before_direct_output.txt`, retained intermediate logs. The final named outputs supersede them.
- `gl_probe_r4.jl` and `gl_probe_r4_output.txt`, the bounded rank-four feasibility test and raw output.
- `gl_action_r4_output.txt`, the timed-out full rank-four attempt. `gl_action_r4_certificates.txt` is empty and incomplete.
- `gl_mtx_r4_output.txt`, the explicit not-run status. `gl_r4_monitor_output.txt` records the denied process-monitoring command.
- `CODEX_REPORT_R3.md`, this report.
- Local runtime directories `gl_tmp`, `gl_scratch` and `gl_local_depot`, where present, hold temporary files and package bookkeeping under the task directory.

The final commands were run from the task directory. The rank-three action was rerun after the additional direct-action export was added, then the final MeatAxe script consumed that regenerated data.

```text
python3 gl_run_r3.py gl_action_r3.jl gl_action_r3_output.txt 120
python3 gl_run_r3.py gl_mtx_r3.jl gl_mtx_r3_output.txt 180
python3 gl_run_r3.py gl_probe_r4.jl gl_probe_r4_output.txt 180
python3 gl_run_r3.py gl_action_r3.jl gl_action_r4_output.txt 240 4
```

