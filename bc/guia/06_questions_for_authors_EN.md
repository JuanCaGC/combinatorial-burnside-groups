# Questions for the authors (English version)

Context: we implemented BC_n(G) in Julia/OSCAR (GAP), by two independent routes (Theorem 5.2 and the direct definition with relations (C), (V), (B2) including the Θ₂ term). It reproduces every value we could find in *Combinatorial Burnside groups* (arXiv:2112.12801): 86 checks, 0 failures. The questions below come out of that work. Each group is glossed the first time it appears.

Questions 1–3 are the ones I would prioritize.

---

**1. Conjecture 4.2 (integral version).**
As printed, cd(G) ≤ log₂|H| appears to fail for:

- G = C₃ (cyclic group of order 3),
- G = S₃ (symmetric group on 3 letters, order 6),
- G = C₇ (cyclic group of order 7).

For C₃ and S₃ it already follows from values in the paper: BC₂(C₃) = ℤ and BC₂(S₃) = ℤ/2 (ℤ/2 is the cyclic group of order 2) force cd ≥ 2 > log₂3 ≈ 1.58. For C₇, both of our implementations give BC₃(C₇) = ℤ/2, so cd(C₇) ≥ 3 > log₂7 ≈ 2.81.
Is this a typo (a ceiling ⌈log₂|H|⌉? an extra +1?), or is there an implicit hypothesis on H (for example |H| large, or H non-cyclic)?
Also, the rational version cd_ℚ(G) ≤ log₃|H| + 1 holds in all our data (with equality for C₃). Is there evidence or a proof in that direction?

**2. Definition of B_n(G) in Section 3.**
Read literally, (B) "for all β = (b₁,…,b_n)" with zero entries allowed gives β = 2β when b₁ = b₂ = 0, so every tuple with two zeros would vanish. We implemented the definition used in the proof of Lemma 5.1: (B) only for b₁ ≠ b₂, together with (b₁,b₁,…) = (0,b₁,…) and (b₁,−b₁,…) = 0. Can you confirm this is the intended definition? Does B_n in [7] (Kontsevich–Pestun–Tschinkel) include the vanishing relation (V)?

**3. Section 6.5: the class Ψ(difference).**
Here G = C₂ × S₃ = D₆ (dihedral group of order 12, with C₂ the cyclic group of order 2). How should the symbol (C₃, C₂×C₃, (1,2)) ∈ BC′₂(G) be read? For H = C₃, the characters 1 and 2 sum to 0, so relation (V) would kill it. Is it H = C₆ (cyclic group of order 6, ≅ C₂ × C₃) with Y = C₆ and β = (1,2), or should it be (C₃, C₆, (1,1))? (We verified the group BC₂(G) = (ℤ/2)⁵ × ℤ/4 and its decomposition over the classes [H,Y], but not the image of that specific class.)

**4. The dihedral family (Section 6.2).**
D_p denotes the dihedral group of order 2p, p prime.
(a) Is there a proof of the formula BC₂(D_p) = ℤ^{(p−5)(p−7)/24} × (ℤ/2)^{(p−3)/2} × ℤ/((p²−1)/12), or does it remain experimental? We confirmed it for p = 5, 7, 11, 13, 17, 19, 23, 31, 101.
(b) Is there a formula for the torsion of B₂(ℤ/p) itself (without the quotient by −1)? We found ℤ/2, ℤ/5, ℤ/7, ℤ/24, ℤ/15, ℤ/22 for p = 7, 11, 13, 17, 19, 23 respectively, and we see no simple pattern. The free rank matches (p−1)/2 + (p−5)(p−7)/24, i.e. (p−1)/2 plus the genus of X₁(p).

**5. Values not in the paper: do they match yours?**
- BC₄(S₈) = (ℤ/2)²³ and BC₅(S₈) = 0 (S₈ is the symmetric group on 8 letters, order 40320).
- S₉ (symmetric group on 9 letters): BC₂ = (ℤ/2)⁵²⁹ × (ℤ/4)⁸⁰ × (ℤ/8)¹⁷ × (ℤ/16)² × (ℤ/3)¹¹ × ℤ¹¹ and BC₃ = (ℤ/2)²⁶⁵ × (ℤ/4)⁷ × (ℤ/8)² × ℤ¹³.
- A₈ (alternating group on 8 letters, order 20160): BC₂ = (ℤ/2)⁶¹ × (ℤ/4)⁴ × (ℤ/8)² × ℤ⁴, BC₃ = (ℤ/2)¹⁶ × ℤ/4 × ℤ, BC₄ = (ℤ/2)².
- PSL₂(𝔽₈) (projective special linear group of degree 2 over the field with 8 elements, order 504): BC₂ = (ℤ/2)¹¹ × ℤ/4 × ℤ/3 × ℤ, BC₃ = (ℤ/2)³ × ℤ, BC₄ = 0.
- M₁₁ (Mathieu group of degree 11, order 7920): BC₂ = (ℤ/2)⁹ × ℤ/4 × ℤ/8 × ℤ³, BC₃ = (ℤ/2)² × ℤ, BC₄ = 0.
(As a sanity check, PSL₂(𝔽₉) — projective special linear group over the field with 9 elements — reproduces the paper's values for A₆, the alternating group on 6 letters, as it should since they are isomorphic.)

**6. Relation (V) and characters of order 2.**
Using (V) for b + b = 0 with b repeated, together with (4.1), kills (H,Y,β) whenever β contains a character of order 2 and the symbol can be lengthened by repeating it inside SC_n (that is, r + 1 ≤ n). This is what makes every summand with H = C₂ vanish for n ≥ 2. Is that the intended behaviour? What about r = n?

**7. Abelian G: the map BC_n(G) → B_n(G).**
For G abelian, is the surjection mentioned in the introduction the projection onto the summand H = Y = G of formula (6.1)? (We only observed that B_n(G) is a direct summand.)

**8. Dependence on (4.3).**
Proposition 4.1 uses vanishing under partial sums (relation (4.3)), which is taken from [8, Prop. 4.7]. Is there a self-contained derivation from (V) + (B2)? (Numerically, adding (4.3) never changed a result in our tests.)

**9. A sharper vanishing bound.**
From the proof of Proposition 4.1 we deduce BC_n(G) = 0 for n ≥ ℓ + a − 1, where ℓ is the maximal order of an element of G and a the maximal order of an abelian subgroup. It is far from sharp (for A₅, the alternating group on 5 letters, it gives n ≥ 9 while the truth is n ≥ 3). Do you know a better bound, for instance in terms of the rank or of |H|?

**10. Product and restriction.**
Are there multiplication tables for BC_*(G) (the ring structure of Section 4) or examples of the restriction map res^G_{G′} for small groups that we could compare against? We did not implement either.

**11. (New) Code.**
Do you have code for BC_n(G) that you would be willing to share, and in which system (Magma, Sage, GAP)? We found no public repository. Comparing outputs for the groups in question 5 would be a strong cross-check.

---

## Glossary of the groups that appear

| symbol | English name |
|---|---|
| C_n, ℤ/n | cyclic group of order n |
| C₂ × C₃ ≅ C₆ | direct product of cyclic groups of order 2 and 3, which is cyclic of order 6 |
| S_n (𝔖_n) | symmetric group on n letters (order n!) |
| A_n | alternating group on n letters (order n!/2) |
| D_p | dihedral group of order 2p |
| D₆ = C₂ × S₃ | dihedral group of order 12 |
| PSL₂(𝔽_q) | projective special linear group of degree 2 over the field with q elements |
| M₁₁ | Mathieu group of degree 11 |
| X₁(p) | the modular curve for the congruence subgroup Γ₁(p) (not a group; a curve) |
