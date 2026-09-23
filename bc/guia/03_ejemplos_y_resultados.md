# 3. Ejemplos a mano, tablas y resultados

Todo lo que aparece con **[C]** lo produjo el código (comando indicado o `validation_output.txt`).
Los cálculos a mano están **contrastados con el código**: cada vez que doy un resultado manual, dice si coincide.

## 0. Receta general para calcular `BC_n(G)` (Teorema 5.2)

1. Enumerar las clases de conjugación de subgrupos **abelianos no triviales** `H≤G`.
2. Para cada `H`: los subgrupos `Y` con `H≤Y≤Z_G(H)`, agrupados en órbitas por `N_G(H)`. Cada órbita es una clase `[H,Y]`.
3. Para cada clase: el subgrupo `A ≤ Aut(H)` imagen de `N_G(H)∩N_G(Y)`.
4. Calcular `B_n(H)/(A)`:
   generadores = multiconjuntos de `n` caracteres de `H^∨` (ceros permitidos) que generan `H^∨`;
   relaciones = (B) para pares distintos no nulos; `(b,b,…)=(0,b,…)`; (V) `bᵢ+bⱼ=0`; y `β=β^a` para `a∈A`.
5. `BC_n(G)=` suma directa de todos esos grupos abelianos.

Reglas de oro para hacer cuentas a mano [D]:

* `H=ℤ/2` **siempre** da 0 para `n≥2` (ver §1.1).
* `H` con `H^∨` de rango `>n` da 0 (no se puede generar).
* Solo hay que aplicar (B) a **pares de entradas no nulas** (con un cero, (B) solo reproduce (V)).

---

## 1. Cálculos a mano

### 1.1 `B₂(ℤ/2)=0`  [D, ✓ código]

`H^∨={0,1}`. Multiconjuntos de 2 caracteres que generan: `x:=(0,1)` e `y:=(1,1)`.
Duplicado: `y=(0,1)=x`. (V): `1+1=0`, luego `y=0`. Entonces `x=y=0`. ∎

Consecuencia general: todo `H` de orden 2 aporta `0` a `BC_n` con `n≥2`.

### 1.2 `B₂(ℤ/3)` y `BC₂(ℤ/3)`, `BC₂(𝔖₃)`  [D, ✓ código]

`H^∨=ℤ/3={0,1,2}`. Generadores: `x₁=(0,1)`, `x₂=(0,2)`, `y₁₁=(1,1)`, `y₁₂=(1,2)`, `y₂₂=(2,2)`.

* Duplicados: `y₁₁=x₁`, `y₂₂=x₂`.
* (V): `1+2=0` ⇒ `y₁₂=0`.
* (B) sobre `{1,2}`: `β₁=(1−2,2)=(2,2)=y₂₂`, `β₂=(1,2−1)=(1,1)=y₁₁`, luego `y₁₂ = y₂₂+y₁₁ = x₂+x₁`.
  Con `y₁₂=0`: **`x₂=−x₁`**.

Resultado: `B₂(ℤ/3)=ℤ` generado por `x₁`. **Coincide** con `BC₂(C₃)=ℤ` del paper (§4). [C]

Ahora la conjugación de `𝔖₃` sobre `H=C₃`: una trasposición actúa por `b↦−b`, luego identifica `x₁=x₂`. Junto con `x₂=−x₁`:
`2x₁=0`. Resultado **`B₂([C₃,C₃])=ℤ/2`**.

`BC₂(𝔖₃)`: las clases son `(C₂,C₂)` (aporta 0 por §1.1) y `(C₃,C₃)` con `Z_{𝔖₃}(C₃)=C₃`, luego `Y=C₃` es la única. Total
**`BC₂(𝔖₃)=ℤ/2`**, que es lo que dice el paper. [C: `validate.jl`]

### 1.3 `B₂(ℤ/5)` y `BC₂(𝔇₅)=(ℤ/2)²`  [D, ✓ código]

`H^∨=ℤ/5`. Escribimos `x_a=(0,a)` (`a≠0`) e `y_{a,b}=(a,b)` (`a,b≠0`, no ordenados, ambos no nulos).
Relaciones (para los seis pares posibles `{a,b}`, `a≠b`, más duplicados y (V)):

| relación | contenido |
|---|---|
| duplicados | `y_{aa}=x_a` |
| (V) | `y_{1,4}=y_{2,3}=0` |
| (B) `{1,2}` | `y₁₂ = y₂₄ + y₁₁` (`β₁=(1−2=4,2)`, `β₂=(1,2−1=1)`) |
| (B) `{1,3}` | `y₁₃ = y₃₃ + y₁₂` |
| (B) `{1,4}` | `0 = y₂₄ + y₁₃` (`β₁=(1−4=2,4)`, `β₂=(1,4−1=3)`) |
| (B) `{2,3}` | `0 = y₃₄ + y₁₂` |
| (B) `{2,4}` | `y₂₄ = y₃₄ + y₂₂` |
| (B) `{3,4}` | `y₃₄ = y₄₄ + y₁₃` |

Sin conjugación resulta `B₂(ℤ/5)=ℤ²` [C].

**Con la conjugación** de `𝔇₅` (que actúa por `b↦−b`; ver Paper §6.2): identifica `x₁=x₄=:u`, `x₂=x₃=:v`,
`y₁₂=y₃₄=:s`, `y₁₃=y₂₄=:t`. Las relaciones quedan

    s = t + u,     t = v + s,     2t = 0  (de {1,4}),     2s = 0  (de {2,3}),

(las de `{2,4}` y `{3,4}` repiten las anteriores). De las dos primeras, `s = t+u = s+v+u`, luego `v=−u`; y
`2u = 2s − 2t = 0`. Queda un grupo generado por `u,t` con `2u=2t=0`, o sea **`(ℤ/2)²`**.

`𝔇₅` tiene solo dos clases `[H,Y]`: `(C₅,C₅)` y `(C₂,C₂)`, y la segunda da 0. Luego **`BC₂(𝔇₅)=(ℤ/2)²`**, que es lo que
predice la fórmula del paper: `ℤ^{0}×(ℤ/2)^{1}×ℤ/2`. [C: `validate.jl`, sección Dihedral groups]

### 1.4 `B₂(ℤ/2×ℤ/2)` y sus cocientes por subgrupos de `Aut=𝔖₃`  [D, ✓ código]

`H^∨={0,a,b,c}`, `a+b=c`. Generan pares de caracteres no nulos **distintos** (los otros no generan):
`p=(a,b)`, `q=(a,c)`, `r=(b,c)`. No hay (V) (la suma de dos distintos es el tercero, no cero).
(B):

    p = (a−b=c, b) + (a, b−a=c) = r + q,       q = r + p,       r = q + p.

Sumando las dos primeras: `2r=0`, y análogamente `2p=2q=0`. Queda `(ℤ/2)²` (generado por `p,q`, con `r=p+q`).

Ahora `Aut(H)=GL₂(𝔽₂)≅𝔖₃` permuta `a,b,c`, y por tanto permuta `p,q,r`. Los cocientes:

| subgrupo `A≤Aut(H)` | identificaciones | resultado |
|---|---|---|
| trivial | ninguna | `(ℤ/2)²` |
| orden 2 (intercambia `a,b`, fija `c`) | `q=r` | `p=r+q=2q=0`; queda `⟨q⟩` = `ℤ/2` |
| orden 3 (`a→b→c→a`) | `p=q=r` | `p=r+q=2p` ⇒ `p=0`: **0** |
| `𝔖₃` completo | ídem | **0** |

Todos **coinciden con el código** y con las tablas de abajo: en `𝔖₄` el `V₄` *normal* (imagen `𝔖₃`) da 0 y el `K₄` *no
normal* (imagen de orden 2) da `ℤ/2`; en `A₅` el `V₄` (imagen de orden 3) da 0; en `C₂×𝔖₃` el `V₄` (imagen trivial)
da `(ℤ/2)²`.

### 1.5 `BC₁(G)` es libre sobre órbitas  [D, ✓ código]

Para `n=1` no hay pares de entradas, luego no hay relaciones de (B) ni (V); solo (C). `BC₁(G)` es el `ℤ`-módulo libre sobre
las `G`-órbitas de ternas `(H,Y,(b))`, con `H` cíclico y `b` un generador de `H^∨`. Ejemplo `𝔖₃`: `(C₂,C₂,(1))` y `(C₃,C₃,{1∼2})`:
rango 2, y el código da `BC₁(𝔖₃)=ℤ²` [C]. (Estos `BC₁` no están en el paper; sirvieron como prueba de fuego del código, ver `04` §7.)

---

## 2. `B₂(ℤ/m)` para `m` pequeño, sin y con la conjugación `b↦−b`  [C]

Esto es `B₂(H)` para `H` cíclico, sin acción y con la acción de `−1` (la que hay en `𝔇_p`, `[C_m,C_m]`).

| `m` | `B₂(ℤ/m)` | `B₂(ℤ/m)/(−1)` |
|---|---|---|
| 2 | 0 | 0 |
| 3 | ℤ | ℤ/2 |
| 4 | ℤ | ℤ/2 |
| 5 | ℤ² | (ℤ/2)² |
| 6 | ℤ/2 × ℤ² | ℤ/2 × ℤ/4 |
| 7 | ℤ/2 × ℤ³ | (ℤ/2)² × ℤ/4 |
| 8 | ℤ/4 × ℤ³ | (ℤ/2)² × ℤ/8 |
| 9 | ℤ/3 × ℤ⁵ | (ℤ/2)³ × ℤ/3 × ℤ |
| 10 | (ℤ/2)³ × ℤ/3 × ℤ⁴ | (ℤ/2)⁴ × ℤ/4 × ℤ/3 |
| 11 | ℤ/5 × ℤ⁶ | (ℤ/2)⁵ × ℤ/5 × ℤ |
| 12 | ℤ/8 × ℤ⁷ | (ℤ/2)² × ℤ/16 × ℤ² |
| 13 | ℤ/7 × ℤ⁸ | (ℤ/2)⁶ × ℤ/7 × ℤ² |

Observaciones **[C]** (no son del paper):

* La columna de la derecha para `m=6` (`ℤ/2×ℤ/4`) es exactamente el sumando `B₂([C₆,C₆])` que el paper da en §6.5.
  Los `m=3,5,7,11,13` (primos) son los sumandos que dan la familia `𝔇_p`.
* Para `m=p` primo (`p=5,7,11,13,17,19,23`) el **rango** de `B₂(ℤ/p)` es `(p−1)/2 + (p−5)(p−7)/24`
  (rangos calculados `2, 3, 6, 8, 13, 16, 23`). El sumando `(p−5)(p−7)/24` es el género de `X₁(p)` (hecho estándar
  de curvas modulares, [D], no del paper), lo que concuerda con el comentario del paper de que el rango de
  `B₂([C_p,C_p])` está relacionado con `X₁(p)` [7, §11]. El paper dice que rango de `B₂([C_p,C_p])=B₂(ℤ/p)/(−1)` es
  `(p−5)(p−7)/24`: el cociente por `−1` deja justo esa parte.
* **No** vi un patrón simple para la **torsión** de `B₂(ℤ/p)`: `ℤ/2` (p=7), `ℤ/5` (11), `ℤ/7` (13), `ℤ/8×ℤ/3=ℤ/24` (17), `ℤ/3×ℤ/5`
  (19), `ℤ/2×ℤ/11` (23). Por eso no afirmo ninguna fórmula para ella. (Sí la del cociente por `−1`, ver §5.)

---

## 3. Tablas por clase `[H,Y]`: `𝔖₃`, `𝔖₄`, `A₅`  [C]

Columnas: `|Y|` orden de `Y`; `|Stab|` orden de `N_G(H)∩N_G(Y)`; `|A|` orden de su imagen en `Aut(H)`; `B₂` es
`B₂([H,Y])`. Se generan con el script de la §9 (`bc_structure` + `bc`).

### `𝔖₃` (2 clases)  → `BC₂ = ℤ/2`, `BC₃=0`

| `H` (gen.) | `Y` | `\|Y\|` | `\|Stab\|` | `\|A\|` | `B₂` |
|---|---|---|---|---|---|
| C₂ `(2,3)` | C₂ | 2 | 2 | 1 | 0 |
| C₃ `(1,2,3)` | C₃ | 3 | 6 | 2 | **ℤ/2** |

### `𝔖₄` (11 clases)  → `BC₂ = (ℤ/2)³`, `BC₃=0`

| `H` (gen.) | `Y` | `\|Y\|` | `\|Stab\|` | `\|A\|` | `B₂` | por qué |
|---|---|---|---|---|---|---|
| C₂ `(1,3)(2,4)` | C₂ | 2 | 8 | 1 | 0 | `H` de orden 2 |
| C₂ `(1,3)(2,4)` | D₈ | 8 | 8 | 1 | 0 | ídem |
| C₂ `(1,3)(2,4)` | C₂×C₂ | 4 | 8 | 1 | 0 | ídem |
| C₂ `(1,3)(2,4)` | C₂×C₂ | 4 | 8 | 1 | 0 | ídem (otra clase de `Y`) |
| C₂ `(1,3)(2,4)` | C₄ | 4 | 8 | 1 | 0 | ídem |
| C₂ `(3,4)` | C₂ | 2 | 4 | 1 | 0 | ídem |
| C₂ `(3,4)` | C₂×C₂ | 4 | 4 | 1 | 0 | ídem |
| **C₃ `(2,4,3)`** | C₃ | 3 | 6 | 2 | **ℤ/2** | §1.2 |
| C₂×C₂ `(1,4)(2,3),(1,3)(2,4)` (normal) | C₂×C₂ | 4 | 24 | 6 | 0 | `Aut` completo (§1.4) |
| **C₂×C₂ `(3,4),(1,2)(3,4)` (no normal)** | C₂×C₂ | 4 | 8 | 2 | **ℤ/2** | imagen de orden 2 (§1.4) |
| **C₄ `(1,3,2,4)`** | C₄ | 4 | 8 | 2 | **ℤ/2** | `B₂(ℤ/4)/(−1)` |

**Coincide con el paper (§6.3)**: las únicas clases con aporte a `BC₂` son `(C₃,C₃)`, `(K₄,K₄)` con
`K₄=⟨(3,4),(1,2)(3,4)⟩` y `(C₄,C₄)`, cada una `ℤ/2`, con los mismos generadores que cita el paper. ✓

### `A₅` (5 clases)  → `BC₂ = (ℤ/2)³`, `BC_n=0` para `n≥3`

| `H` | `Y` | `\|Y\|` | `\|Stab\|` | `\|A\|` | `B₂` |
|---|---|---|---|---|---|
| C₂ `(2,3)(4,5)` | C₂ | 2 | 4 | 1 | 0 |
| C₂ `(2,3)(4,5)` | C₂×C₂ | 4 | 4 | 1 | 0 |
| **C₃ `(3,4,5)`** | C₃ | 3 | 6 | 2 | **ℤ/2** |
| C₂×C₂ | C₂×C₂ | 4 | 12 | 3 | 0 |
| **C₅ `(1,2,3,4,5)`** | C₅ | 5 | 10 | 2 | **(ℤ/2)²** (§1.3) |

**Coincide con el paper (§6.4)**: `B₂([C₃,C₃])=ℤ/2`, `B₂([C₅,C₅])=(ℤ/2)²`. ✓

---

## 4. `C₂×𝔖₃=𝔇₆` (Paper §6.5, el ejemplo geométrico)  [C]

`validate.jl demo` imprime esta tabla (12 clases). `Z` es el centro `⟨z⟩`, `z=(1,4)(2,5)(3,6)`; la clase con
`Y=D12` es `Y=G`. Nombres del paper entre paréntesis.

| `H` | `Y` | `\|Y\|` | `\|Stab\|` | `\|A\|` | `B₂([H,Y])` |
|---|---|---|---|---|---|
| C₂ `(2,6)(3,5)` (reflexión) | C₂ | 2 | 4 | 1 | 0 |
| C₂ `(2,6)(3,5)` | C₂×C₂ | 4 | 4 | 1 | 0 |
| C₂ `Z=⟨z⟩` | C₂ | 2 | 12 | 1 | 0 |
| C₂ `Z` | D12 (=G) | 12 | 12 | 1 | 0 |
| C₂ `Z` | C₂×C₂ | 4 | 4 | 1 | 0 |
| C₂ `Z` | C₆ | 6 | 12 | 1 | 0 |
| C₂ `(1,2)(3,6)(4,5)` (reflexión, otra clase) | C₂ | 2 | 4 | 1 | 0 |
| C₂ `(1,2)(3,6)(4,5)` | C₂×C₂ | 4 | 4 | 1 | 0 |
| **C₃ `(1,3,5)(2,4,6)` (`H₁`)** | C₃ (`H₁`) | 3 | 12 | 2 | **ℤ/2** |
| **C₃ (`H₁`)** | C₆ (`H₃`) | 6 | 12 | 2 | **ℤ/2** |
| **C₂×C₂ (`H₂`)** | C₂×C₂ (`H₂`) | 4 | 4 | 1 | **(ℤ/2)²** |
| **C₆ (`H₃`)** | C₆ (`H₃`) | 6 | 12 | 2 | **ℤ/2 × ℤ/4** |

Total: `ℤ/2 + ℤ/2 + (ℤ/2)² + ℤ/2×ℤ/4 = (ℤ/2)⁵ × ℤ/4`, **exactamente `BC₂(C₂×𝔖₃)` y las cuatro contribuciones que da el paper**. ✓
Factores invariantes `[2,2,2,2,2,4]`, rango libre `0`. `BC₃(C₂×𝔖₃)=0` ✓ (el paper lo usa para decir que
`X×ℙ¹` y `ℙ²×ℙ¹` no se distinguen con esta herramienta).

Explicaciones [D]:

* Las 8 clases con `H=C₂` son 0 por §1.1.
* `C₃`: `𝔇₆` contiene reflexiones que invierten `C₃` ⇒ imagen `{±1}` (orden 2) ⇒ `B₂(ℤ/3)/(−1)=ℤ/2` (§1.2), para ambos `Y`.
* `C₂×C₂` (`H₂`): la imagen es trivial (`|A|=1`, es un `V₄` con `N_G(H)=H`) ⇒ `B₂(C₂²)=(ℤ/2)²` (§1.4, fila "trivial").
* `C₆`: imagen `{±1}` ⇒ `B₂(ℤ/6)/(−1)=ℤ/2×ℤ/4` (tabla del §2).

> Lo que **no** hicimos: la clase concreta `[X↷G]−[ℙ²↷G]` (véase `02`, §6.5). Verificamos el grupo en que vive y sus sumandos.

---

## 5. La familia diedral `𝔇_p`  [C]

`𝔇_p` (orden `2p`) tiene dos clases `[H,Y]`: `(C_p,C_p)` (con `−1` actuando) y `(C₂,C₂)` (que da 0). Luego
`BC₂(𝔇_p)=B₂(ℤ/p)/(−1)`, y esto se compara con la fórmula empírica del paper
`ℤ^{(p−5)(p−7)/24} × (ℤ/2)^{(p−3)/2} × ℤ/((p²−1)/12)`:

| `p` | calculado | fórmula (rango; `ℤ/2`; cíclico) | ✓ |
|---|---|---|---|
| 5 | (ℤ/2)² | `0; 1; ℤ/2` | ✓ |
| 7 | (ℤ/2)² × ℤ/4 | `0; 2; ℤ/4` | ✓ |
| 11 | (ℤ/2)⁵ × ℤ/5 × ℤ | `1; 4; ℤ/10` | ✓ |
| 13 | (ℤ/2)⁶ × ℤ/7 × ℤ² | `2; 5; ℤ/14` | ✓ |
| 17 | (ℤ/2)⁷ × ℤ/8 × ℤ/3 × ℤ⁵ | `5; 7; ℤ/24` | ✓ |
| 19 | (ℤ/2)⁹ × ℤ/3 × ℤ/5 × ℤ⁷ | `7; 8; ℤ/30` | ✓ |
| 23 | (ℤ/2)¹⁰ × ℤ/4 × ℤ/11 × ℤ¹² | `12; 10; ℤ/44` | ✓ |
| 31 | `(ℤ/2)¹⁴ × ℤ/16 × ℤ/5 × ℤ²⁶` | `26; 14; ℤ/80` | ✓ |
| 101 | `(ℤ/2)⁵⁰ × ℤ/25 × ℤ/17 × ℤ³⁷⁶` | `376; 49; ℤ/850` | ✓ |

(Para `p=7`: `(p²−1)/12=4`. Para `p=101`: `ℤ/850=ℤ/2×ℤ/25×ℤ/17`, así que el exponente de `ℤ/2` en primaria es `49+1=50` ✓.)
Los `p=5…23` están en `validate.jl`; `p=31,101` en las pruebas de escala (`scaling_log.txt`). Recordemos: **la fórmula es empírica** en el
paper; nosotros la hemos confirmado en 9 primos, pero sigue sin ser una demostración.

Comparando `B₂(ℤ/p)` (§2) con `B₂(ℤ/p)/(−1)` [C]: al pasar al cociente por `−1` la parte libre baja de `(p−1)/2 + g` a `g`
(`g=(p−5)(p−7)/24`) y la torsión se modifica (aparece `(ℤ/2)^{(p−3)/2}`).

---

## 6. Los grupos de Heisenberg `𝔥𝔢_p`  [C]

El paper afirma `BC_n(𝔥𝔢_p)=B_n([ℤ/p,ℤ/p])^{3p+5} ⊕ B_n([(ℤ/p)²,(ℤ/p)²])^{p+1}`. El código encuentra exactamente

| grupo | #clases con `\|H\|=p` | #clases con `\|H\|=p²` | total |
|---|---|---|---|
| `𝔥𝔢₃` | 14 = 3·3+5 | 4 = 3+1 | 18 |
| `𝔥𝔢₅` | 20 = 3·5+5 | 6 = 5+1 | 26 |

y los valores de cada sumando son

| grupo | `n` | sumandos con `H=ℤ/p` | sumandos con `H=(ℤ/p)²` | total |
|---|---|---|---|---|
| `𝔥𝔢₃` | 2 | 14 × ℤ | 4 × ℤ³ | ℤ¹⁴⁺¹² = **ℤ²⁶** ✓ |
| `𝔥𝔢₃` | 3 | 14 × 0 | 4 × ℤ | **ℤ⁴** ✓ |
| `𝔥𝔢₅` | 2 | 20 × ℤ² | 6 × ℤ¹⁴ | ℤ⁴⁰⁺⁸⁴ = **ℤ¹²⁴** ✓ |
| `𝔥𝔢₅` | 3 | 20 × 0 | 6 × ((ℤ/2)⁶×ℤ⁶) | **(ℤ/2)³⁶×ℤ³⁶** ✓ |

Notar [D]: los sumandos `H=ℤ/p` son `B_n(ℤ/p)` **sin** conjugación (en `𝔥𝔢_p` los estabilizadores actúan trivialmente sobre
un `C_p`), mientras que los `H=(ℤ/p)²` son cocientes de `B_n((ℤ/p)²)` por la acción de orden `p` de `G/H`. Por eso `B₂` da `ℤ³` y no el `ℤ⁷` sin cociente
(`B₂((ℤ/3)²)=ℤ⁷` [C]).

---

## 7. Resumen de verificación contra el paper

Todos [C]; ver `validation_output.txt` (86 comprobaciones, 0 fallos).

| bloque | resultado |
|---|---|
| `BC₂(𝔖_m)`, `m=3..8` | ✓ (incluye `S₇`, `S₈`) |
| `BC₃(𝔖_m)`, `m=3..8` | ✓ |
| `BC₂(A₅)`, `BC_n(A₅)=0` (`n=3..9`) | ✓ (y n ≥ 9 por Prop. 4.1, ver `02` §4.4) |
| `𝔇₅` y fórmula `𝔇_p` (9 primos) | ✓ |
| `BC₂(𝔇₄)`, `𝔥𝔢₃`, `𝔥𝔢₅`, `BC₃` | ✓ |
| `ASL₂(𝔽₃)`, `PSL₂(𝔽₇)`, `A₆` (`n=2,3,4,(5)`) | ✓ |
| `C₂×𝔖₃`: grupo y 4 sumandos | ✓ |
| `BC₂(C₃)=ℤ` | ✓ |
| **Cruce**: Teorema 5.2 vs definición directa | ✓ en 31 casos (grupo,n) |
| Anulación por sumas parciales (4.3) redundante | ✓ 5 casos |

**Valores que calculamos y NO están en el paper** (no verificados contra literatura; solo consistencia interna):

* `BC₄(𝔖₈)=(ℤ/2)²³`, `BC₅(𝔖₈)=0`.
* `𝔖₉`: `BC₂=(ℤ/2)⁵²⁹×(ℤ/4)⁸⁰×(ℤ/8)¹⁷×(ℤ/16)²×(ℤ/3)¹¹×ℤ¹¹`, `BC₃=(ℤ/2)²⁶⁵×(ℤ/4)⁷×(ℤ/8)²×ℤ¹³`.
* `A₈`: `BC₂=(ℤ/2)⁶¹×(ℤ/4)⁴×(ℤ/8)²×ℤ⁴`, `BC₃=(ℤ/2)¹⁶×ℤ/4×ℤ`, `BC₄=(ℤ/2)²`.
* `PSL₂(𝔽₈)`: `BC₂=(ℤ/2)¹¹×ℤ/4×ℤ/3×ℤ`, `BC₃=(ℤ/2)³×ℤ`, `BC₄=0`.
* `M₁₁`: `BC₂=(ℤ/2)⁹×ℤ/4×ℤ/8×ℤ³`, `BC₃=(ℤ/2)²×ℤ`, `BC₄=0`.
* `PSL₂(𝔽₉)`: reproduce `A₆` (coherente, pues `PSL₂(𝔽₉)≅A₆`).
* `𝔥𝔢₇`: `BC₂=(ℤ/2)⁵⁰×ℤ³⁴²`, `BC₃=(ℤ/2)¹⁷⁸×(ℤ/4)³²×ℤ¹²⁰`; `𝔥𝔢₁₁`: `BC₂=(ℤ/5)⁹⁸×ℤ¹⁴⁸⁸`.

---

## 8. Dimensión combinatorial: los datos frente a la Conjetura 4.2  [C]

`n` con `BC_n(G)≠0` (calculado para `1≤n≤N`), `n` con rango libre `>0`, y las cotas de la conjetura (Paper §4, sin partes enteras):

| grupo | `N` | `BC_n≠0` para `n=` | rango `>0` para `n=` | `max ord(H)` | `log₂` | `log₃+1` |
|---|---|---|---|---|---|---|
| `ℤ/3` | 6 | 1, 2 | 1, 2 | 3 | 1.58 | 2.00 |
| `ℤ/5` | 6 | 1, 2 | 1, 2 | 5 | 2.32 | 2.46 |
| `ℤ/7` | 6 | 1, 2, **3** | 1, 2 | 7 | 2.81 | 2.77 |
| `ℤ/11` | 6 | 1, 2, 3 | — | 11 | 3.46 | 3.18 |
| `ℤ/13` | 6 | 1, 2, 3 | 1, 2, 3 | 13 | 3.70 | 3.33 |
| `𝔖₃` | 6 | 1, 2 | 1 | 3 | 1.58 | 2.00 |
| `𝔖₄` | 6 | 1, 2 | 1 | 4 | 2.00 | 2.26 |
| `𝔖₅` | 7 | 1, 2 | 1 | 6 | 2.58 | 2.63 |
| `𝔖₆` | 7 | 1, 2, 3 | 1 | 9 | 3.17 | 3.00 |
| `𝔖₇` | 7 | 1, 2, 3 | 1 | 12 | 3.58 | 3.26 |
| `𝔖₈` | 7 | 1, 2, 3, 4 | 1, 2, 3 | 18 | 4.17 | 3.63 |
| `A₅` | 9 | 1, 2 | 1 | 5 | 2.32 | 2.46 |
| `(ℤ/2)³` | 5 | 1, 2, 3 | — | 8 | 3.00 | 2.89 |
| `(ℤ/2)⁴` | 6 | 1, 2, 3, 4 | — | 16 | 4.00 | 3.52 |

(La columna "rango > 0" solo se calculó para algunos grupos y hasta `n=5`; `—` = no calculada aquí. Para `ℤ/13` los rangos libres son
`12, 8, 2, 0, 0` para `n=1..5`, así que `cd_ℚ(ℤ/13)=3 ≤ log₃13+1 = 3.33`.)

Para los primos `p≤23` (calculado hasta `n=5`): `BC_n(ℤ/p)≠0` exactamente para `n≤2` si `p=3,5` y para `n≤3` si `p=7,11,13,17,19,23`; el rango libre es `>0` para `n≤2` si `p=3,5,7` y para `n≤3` si `p≥11`. Es decir, entre esos primos la
versión entera literal de la Conjetura 4.2 falla **solo** en `p=3` y `p=7`.

Lo que se ve [C/D]:

* La versión **entera literal** de la Conjetura 4.2 falla en `ℤ/3` (`cd≥2>1.58`), `𝔖₃` (`cd≥2>1.58`) y `ℤ/7` (`cd≥3>2.81`);
  las dos primeras son consecuencia de valores publicados en el propio paper. Con `⌈log₂⌉` todo lo calculado la satisface.
* La versión **racional** `cd_ℚ ≤ log₃|H|+1` se cumple en todos los casos calculados, con **igualdad** en `ℤ/3`.
* Para `𝔖_m` la cota `(m/3)log₂3` se cumple para `m≥4` en lo calculado y es **casi ajustada** en `𝔖₈` (`cd=4`, cota `4.23`).
  (Para `m=3`, `𝔖₃`: `cd=2` frente a `1.58`.)
* Cuidado: "hasta `N`" no es lo mismo que "para todo `n`". La cota rigurosa de anulación (`02` §4.4) es `n≥ℓ+a−1`; solo `A₅`
  (cota 9) la alcanza en lo calculado.

---

## 9. Cómo generar las tablas por clase

```julia
# desde /Users/juancagc/Groups/bc  (julia --project=.)
include("BurnsideC.jl"); using .BurnsideC, Oscar
st = bc_structure(symmetric_group(4); name="S4")
r  = bc(st, 2)
for s in r.summands
    println(s.Hdesc, " ", s.Hgens, "  Y=", s.Ydesc, "  |Y|=", s.Ysize, "  |Stab|=", s.stabsize,
            "  |Aut-img|=", s.autsize, "   B_2=", s.value)
end
println(r)                                  # BC_2(S4) = (Z/2)^3
BurnsideC.invariant_factors(r.total)        # factores invariantes
```
