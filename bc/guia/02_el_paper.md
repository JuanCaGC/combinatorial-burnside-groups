# 2. El paper, sección por sección

Referencia: Tschinkel, Yang, Zhang, *Combinatorial Burnside groups*, arXiv:2112.12801v1 (23 dic 2021), copia local
`../paper.pdf`. Los números de sección/fórmula son los del paper. Uso el prefijo "Paper §k" para distinguirlos de
las secciones de esta guía.

Etiquetas: **[P]** enunciado del paper · **[C]** lo calculó nuestro código · **[D]** deducción mía/hecho estándar ·
**[H]** heurística.

## Índice de todo el contenido matemático del paper

| id | qué es | dónde | en esta guía |
|---|---|---|---|
| D1 | poset `𝓗` de subgrupos abelianos, `Ψ`, `μ`, `Φ` | Paper §2 | §2 |
| Lema 2.1 | suma de Möbius que se anula (tipo Weisner) | Paper §2 | §2 |
| Cor. 2.2 | suma doble de Möbius | Paper §2 | §2 |
| D2 | `S_n(G)` con (O) | Paper §3 | §3 |
| D3 | `B_n(G)` con (B) | Paper §3 | §3 |
| D4 | `SC_n(G)`, `SC_0(G)=ℤ` | Paper §4 | §4.1 |
| D5 | `BC_n(G)`: (C), (V), (B2), fórmulas (4.1), (4.2) | Paper §4 | §4.2 |
| D6 | símbolo *reducido*, filtración `BC_{n,r}` | Paper §4 | §4.3 |
| (4.3) | anulación por suma parcial | Paper §4 | §4.3 |
| Prop. 4.1 | `BC_n(G)=0` para `n≫0` | Paper §4 | §4.4 |
| D7 | `cd(G)`, `cd_ℚ`, `cd_p` (4.4) | Paper §4 | §4.5 |
| Conj. 4.2 | cotas de `cd` | Paper §4 | §4.5 |
| D8 | homomorfismo de restricción | Paper §4 | §4.6 |
| D9 | anillo `BC_*(G)` | Paper §4 | §4.6 |
| D10 | `BC′_n(G)` con (B2′) | Paper §5 | §5.1 |
| D11 | `B_n([H,Y])`, relación `(C_{(H,Y)})` | Paper §5 | §5.1–5.2 |
| Lema 5.1 | `B_n([H,Y]) ≅ B_n(H)/(C_{(H,Y)})` | Paper §5 | §5.3 |
| D12 | orden de símbolos, `Ψ`, `Φ` sobre `SC_n(G)` | Paper §5 | §5.4 |
| **Teor. 5.2** | `BC_n(G) ≅ BC′_n(G) = ⊕_{[H,Y]} B_n([H,Y])` | Paper §5 | §5.5 |
| (6.1), Prop. 6.2, Prob. 6.1 | caso abeliano | Paper §6.1 | §6.1 |
| datos §6.2–6.5 | `D_p`, extensiones centrales, `S_n`, Cremona, `C₂×S₃` | Paper §6.2–6.5 | §6.2–6.5 |

---

## 1. Paper §1 — Introducción

Contenido [P] (lo geométrico ya está resumido en `01_prerequisitos.md` §6):

* El invariante de una acción de `G` sobre `X` toma valores en `Burn_n(G)` [8], definido por generadores y relaciones,
  y se calcula en un modelo *estándar* (estabilizadores abelianos; traslaciones de componentes iguales o disjuntas).
* La versión **combinatoria** [12] `BC_n(G)`, definida en Paper §4, olvida la información de cuerpo.
* **Si `G` es abeliano** hay un homomorfismo sobreyectivo `BC_n(G) → B_n(G)` (grupo de [7], Paper §3), que tiene
  propiedades aritméticas notables [7], [9]: por ejemplo `B_n(G)⊗ℚ = H₀(Γ(n,G), F_n)⊗ℚ`, con `Γ(n,G) ⊂ GL_n(ℤ)` un
  subgrupo de congruencia y `F_n` el `ℚ`-espacio generado por las funciones características de conos poliédricos
  racionales convexos de `ℝⁿ` módulo funciones de soporte de dimensión `<n` [7, §9]. Los `B_n(G)` tienen
  operadores de Hecke. Para `n=2` hay relación con los símbolos de Manin.
* Los `BC_n(G)` son "análogos de símbolos de Manin para grupos no abelianos" y hay un anillo finitamente generado
  `BC_*(G) = ⊕_{n≥0} BC_n(G)`.
* **Resultado principal (Teorema 5.2), fórmula (1.1):**

      BC_n(G) ≃ ⊕_{[H,Y]} B_n([H,Y]),       B_n([H,Y]) ≃ B_n(H)/(C_{(H,Y)}),

  suma sobre clases de `G`-conjugación de pares `(H,Y)` con `H⊆G` abeliano y `H⊆Y⊆Z_G(H)`.
* **Caso `G` abeliano** [P]: `B_n([H,Y]) = B_n(H)` (no hay conjugación efectiva) y

      BC_n(G) = ⊕_{H'⊆G} ⊕_{H''⊆H'} B_n(H'').

  (Aquí `H'` hace de `Y` y `H''` de `H`: cuando `G` es abeliano, `Z_G(H'')=G`, así que `Y=H'` recorre *todos* los
  subgrupos que contienen a `H''`.)
* Observación [D]: para `G` abeliano no trivial, el sumando `H''=H'=G` es `B_n(G)`. Luego `B_n(G)` es un sumando
  directo de `BC_n(G)`, y de ahí un epimorfismo `BC_n(G)→B_n(G)` (coherente con lo anunciado en la introducción,
  aunque el paper no dice que sea *esa* la aplicación).

---

## 2. Paper §2 — Inversión de Möbius

Sea `G` finito y `𝓗` el **poset de subgrupos abelianos** de `G` ordenado por inclusión. `S = ⊕_{H∈𝓗} ℤ·(H)` el
`ℤ`-módulo libre sobre `𝓗`.

**D1.** `Ψ: S→S`, `Ψ((H)) = Σ_{H'⊆H} (H')` (extendida linealmente). Existe una única función `μ=μ_𝓗: 𝓗×𝓗→ℤ`
(**Möbius**) tal que `Φ((H)) := Σ_{H'⊆H} μ(H',H)(H')` es la inversa de `Ψ` (`Ψ∘Φ=Φ∘Ψ=Id`). Se construye recursivamente:
`μ(H,H)=1`; `μ(H',H)=0` si `H'⊄H`; `μ(H'',H) = −Σ_{H''⊆H'⊊H} μ(H'',H')` si `H''⊊H`.

Cuando `G` es abeliano, `𝓗` es *todo* el retículo de subgrupos, con `H'∧H = H'∩H` y `H'∨H = ⟨H',H⟩`.

### Lema 2.1  [P]
Sea `G` abeliano finito y `H'' ⊆ H' ⊊ G` subgrupos, `μ` la función de Möbius del retículo de subgrupos de `G`. Entonces

    Σ_{H⊆G, H∩H'=H''} μ(H,G) = 0.

El paper remite a [17] (Weisner) y [15] (Rota, §5). [D] Es el **teorema de Weisner dual** aplicado al intervalo
`[H'',G]` del retículo: en un retículo finito `L` con `a<1̂` se tiene `Σ_{x∧a=0̂} μ(x,1̂)=0`; aquí `L=[H'',G]`, `0̂=H''`, `a=H'≠G`
(todo `H` con `H∩H'=H''` contiene a `H''`, así que cae dentro del intervalo). No hace falta reproducir la prueba, pero sí
**entender cómo se usa** (en la prueba del Teorema 5.2, §5.5).

*Comprobación a mano* [D] (para sentir el enunciado): en `G=(ℤ/2)²={0,a,b,c}`, tomemos `H'=⟨a⟩`, `H''=1`. Los `H`
con `H∩⟨a⟩=1` son `1, ⟨b⟩, ⟨c⟩`, y `μ(1,G)=2`, `μ(⟨b⟩,G)=μ(⟨c⟩,G)=−1`: suma `2−1−1=0` ✓. Con `H''=H'=⟨a⟩`:
`H ⊇ ⟨a⟩` son `⟨a⟩` y `G`: `μ(⟨a⟩,G)+μ(G,G) = −1+1=0` ✓. Y en `G=ℤ/p²`, `H'=H''=1`: solo `H=1`, y
`μ(1,ℤ/p²)=0` ✓.

### Corolario 2.2  [P]
Sean `H, H'` subgrupos de un mismo abeliano finito y `H''⊆H∩H'`. Entonces

    Σ_{H̃⊆H, H̃'⊆H', H̃∩H̃'=H''}  μ(H̃,H)·μ(H̃',H')  =  μ(H'',H) si H=H',  0 si H≠H'.

*Prueba (la del paper, con los detalles)* [D]. Se reordena: `Σ_{H̃⊆H} μ(H̃,H) · Σ_{H̃'⊆H', H̃'∩H̃=H''} μ(H̃',H')`.
La suma interior es sobre subgrupos de `H'` con `H̃'∩(H̃∩H')=H''` (si `H''⊄H̃` está vacía); hay dos casos: si `H̃∩H' ⊊ H'`, el Lema 2.1
(con el ambiente `H'` y el subgrupo `H̃∩H'`) la anula; si `H' ⊆ H̃`, entonces `H̃'∩H̃=H̃'` y la suma se reduce
a `H̃'=H''`, dando `μ(H'',H')`. Queda `μ(H'',H')·Σ_{H'⊆H̃⊆H} μ(H̃,H)`, y la identidad `Σ_{H'⊆H̃⊆H}μ(H̃,H)=δ_{H',H}`
(de la definición de `μ`) da el resultado. ∎

*Dónde se usa:* solo en la Proposición 6.2 (caso abeliano). El Lema 2.1 en sí se usa en el Teorema 5.2.

---

## 3. Paper §3 — Grupos de símbolos (Kontsevich–Pestun–Tschinkel)

Aquí `G` es un abeliano finito (en la aplicación será el `H` de un símbolo).

**D2.** `S_n(G)` es el `ℤ`-módulo generado por las `n`-tuplas `β=(b₁,…,b_n)` de caracteres `b_j∈G^∨` **que generan `G^∨`**
(nada excluye que haya ceros), módulo

* **(O) reordenamiento:** `β = β^σ := (b_{σ(1)},…,b_{σ(n)})` para todo `σ∈S_n`.

O sea, los generadores son *multiconjuntos* de `n` caracteres que generan `G^∨`.

**D3.** `B_n(G)` es el cociente `S_n(G) → B_n(G)` por la **relación de blow-up**:

* **(B)** para toda `β=(b₁,b₂,…,b_n)` (`n≥2`): `β = β₁ + β₂`, con
  `β₁ := (b₁−b₂, b₂, …, b_n)`, `β₂ := (b₁, b₂−b₁, …, b_n)`   (3.1).

Notación `(3.2)`: para `H⊆G`, `β|_H := (b₁|_H,…,b_n|_H)`.

Contexto [P]: los `B_n(G)_ℚ := B_n(G)⊗ℚ` tienen operadores de Hecke y una multiplicación
`∇: B_{n'}(G')_ℚ ⊗ B_{n''}(G'')_ℚ → B_{n'+n''}(G)_ℚ` para cada sucesión exacta `0→G'→G→G''→0`.

> ### ⚠ Advertencia sobre (B) tal como está escrita  [D]
> Leída literalmente ("para *todo* `β`", con ceros permitidos), (B) aplicada a `b₁=b₂=0` da `β₁=β₂=β`, o sea `β=2β`, es
> decir `β=0`: **toda tupla con dos ceros valdría 0**, y `B_n(G)` sería casi nulo, lo que contradice los propios números
> del paper. La definición *operativa* es la que aparece en la **demostración del Lema 5.1** (Paper §5), donde se
> listan, como "identidades en `B_n(H)` por definición":
>
>     (b₁,b₁,b₂,…) = (0,b₁,b₂,…),      (b₁,b₂,…) = (b₁−b₂,b₂,…) + (b₁,b₂−b₁,…),      (b₁,−b₁,…) = 0.
>
> Es decir: (B) solo para `b₁≠b₂` (y, en la práctica, no nulos), más el caso de duplicados, más (V). **Es lo que
> implementa el código** (`04_el_codigo.md`, §4). Vale la pena mencionarlo a los autores como una imprecisión de
> redacción (pregunta 2 en `05`).

---

## 4. Paper §4 — Grupos de Burnside combinatoriales

### 4.1 Símbolos combinatoriales (D4)

Sea `G` finito, `n` entero positivo. El **grupo de símbolos combinatoriales** `SC_n(G)` es el `ℤ`-módulo generado por
las ternas `(H,Y,β)` con

* `H ⊆ G` abeliano,
* `Y ⊆ G` subgrupo con `H ⊆ Y ⊆ Z_G(H)`,
* `β=(b₁,…,b_r)` sucesión de caracteres **no triviales** de `H`, de longitud `r=r(β)` con `1 ≤ r ≤ n`, que **generan `H^∨`**,

módulo **(O)** `(H,Y,β)=(H,Y,β^σ)`, `σ∈S_r`. Convención: `SC_0(G):=ℤ`.

(La longitud `r` es variable, hasta `n`: es el **relleno con ceros** `n−r` de la §5.)

### 4.2 Burnside combinatorial (D5)

`BC_n(G)` es el cociente `SC_n(G) → BC_n(G)` [12, Def. 8.1] por las relaciones:

* **(C) conjugación:** `(H,Y,β) = (gHg⁻¹, gYg⁻¹, β^g)` para todo `g∈G`, donde `β^g` es la imagen de `β` por conjugación.
* **(V) anulación:** `(H,Y,β)=0` si `H=1`, o si `b₁+b₂=0` para dos caracteres de `β` (dos *posiciones* distintas).
* **(B2) blow-up:** para `b₁=b₂`:

      (H,Y,(b₁,…,b_r)) = (H,Y,(b₂,…,b_r))                                         (4.1)

  y para `b₁≠b₂`:

      (H,Y,β) = (H,Y,β₁) + (H,Y,β₂)                        si bᵢ ∈ ⟨b₁−b₂⟩ para algún i,
      (H,Y,β) = (H,Y,β₁) + (H,Y,β₂) + (H̄,Y,β̄)             en otro caso,

  con `β₁:=(b₁−b₂,b₂,b₃,…,b_r)`, `β₂:=(b₁,b₂−b₁,b₃,…,b_r)`, `H̄:=ker(⟨b₁−b₂⟩)⊆H` [sic: el núcleo del carácter `b₁−b₂`],
  `β̄:=β|_{H̄}`     (4.2).

Los términos se llaman `Θ₁=(H,Y,β₁)+(H,Y,β₂)` y `Θ₂=(H̄,Y,β̄)` [8, §4], [12, §2].

**Comentarios** [D]:

1. (B2) se aplica a **cualquier par de posiciones** de `β`, no solo a las dos primeras: basta usar (O) para
   reordenar.
2. Por el Lema B (`01`, §1), "ningún `bᵢ∈⟨b₁−b₂⟩`" ⟺ "`β̄` no contiene ceros". La relación se lee entonces
   uniformemente con la convención "símbolo con un cero := 0".
3. `H̄` es un subgrupo abeliano, `H̄⊆H⊆Y⊆Z_G(H)⊆Z_G(H̄)`, así que `(H̄,Y,β̄)` es un símbolo válido; además `β̄` genera
   `H̄^∨` porque la restricción `H^∨→H̄^∨` es sobreyectiva (K2).
4. (V) solo dice `b_i+b_j=0` para `i≠j` *posiciones*. Si `b` tiene orden 2 y aparece repetido, `(b,b,…)` se anula
   por (V) y a la vez es `(b,…)` por (4.1). Luego `(H,Y,β)=0` siempre que `β` contenga un carácter `b` de orden 2 y el símbolo
   pueda alargarse repitiendo `b` dentro de `SC_n` (es decir, `r+1 ≤ n`). Esto es lo que mata todos los
   sumandos con `H=ℤ/2` para `n≥2` [C].

### 4.3 Símbolos reducidos y filtración (D6)

(4.1) permite acortar `β` cuando hay caracteres repetidos. Un símbolo es **reducido** si los caracteres de `β` son
distintos dos a dos. Como (B2) **no aumenta `r(β)`**, se define `BC_{n,r}(G) ⊂ BC_n(G)` como el submódulo generado
por símbolos reducidos con `r(β) ≤ r`. Hay epimorfismos `BC_r(G) → BC_{n,r}(G)` (`1≤r≤n`) que no son isomorfismos
en general si `r<n` [P] (el paper no da la fórmula del morfismo; presumiblemente inducido por la identidad sobre símbolos [D]).

**Anulación por sumas parciales (4.3)** [P]: por la Prop. 4.7 de [8], (V) implica

    (H,Y,β) = 0 ∈ BC_n(G)    si existe I ⊆ {1,…,r} no vacío con  Σ_{i∈I} bᵢ = 0 en H^∨.

*Verificado numéricamente* [C]: añadir esta relación (`extra_vanishing=true` en el código) no cambia ningún resultado
en los casos probados (`validate.jl crosscheck`).

### 4.4 Proposición 4.1  [P]
Para `G` fijo, `BC_n(G)=0` para `n≫0`.

*Prueba del paper* (la reproduzco porque es corta y da información útil). Sea `ℓ=ℓ(G)` el máximo orden de un elemento de `G`.
Para cualquier elección de `bᵢ`,

    0 = (H,Y,(b₁,…,b₁ [ℓ veces], b₂,…,b_{n−ℓ})) = (H,Y,(b₁,b₂,…,b_{n−ℓ}))  ∈ BC_n(G),

la primera igualdad por (4.3) (`ℓ·b₁=0` porque `ord(b₁)` divide al exponente de `H`, que divide a `ℓ`), la segunda por (4.1)
repetida. Luego `BC_{n,r}(G)=0` para `1 ≤ r ≤ n−ℓ`. Basta notar que para `n≫0` todo símbolo reducido tiene `r ≤ n−ℓ`. ∎

**Cota explícita** [D, deducida de esta prueba]. Sea `a` el máximo orden de un subgrupo abeliano de `G`. Un símbolo
reducido tiene `r ≤ |H|−1 ≤ a−1` (caracteres no triviales distintos). Además `BC_n(G)` está generado por símbolos
reducidos (cualquier símbolo se reduce con (4.1)). Por tanto

    BC_n(G) = 0   para todo   n ≥ ℓ + a − 1.

Ejemplo: `A₅`: `ℓ=5`, `a=5`, luego `BC_n(A₅)=0` para `n≥9`. Nuestro código da `BC_n(A₅)=0` para `n=3,…,9` [C],
así que **`BC_n(A₅)=0` para todo `n≥3`**, cerrando el caso (esto sí es una verificación completa, condicionada a (4.3)).

### 4.5 Dimensión combinatorial (D7) y Conjetura 4.2

`cd(G) := min{ n∈ℕ : BC_m(G)=0 para todo m>n }` (4.4). Análogamente `cd_ℚ(G)` y `cd_p(G)` usando `BC_m(G)⊗ℚ`, `BC_m(G)⊗𝔽_p`.

**Conjetura 4.2** [P, p. 8, literal]: *Sea `G` finito y `H⊆G` un subgrupo abeliano maximal. Entonces*

    cd(G) ≤ log₂(|H|),      cd_ℚ(G) ≤ log₃(|H|) + 1.

*En particular, para `G=𝔖_m`, usando la determinación de subgrupos abelianos maximales de `𝔖_n` en [3]:*

    cd(G) ≤ (m/3)·log₂(3),      cd_ℚ(G) ≤ m/3 + 1.

Motivación del paper: "experimentos computacionales y el Teorema 5.2".

> ### ⚠ Desajuste aparente con nuestros cálculos  [C]
> Tomada **literalmente** (sin partes enteras; miré el PDF, no hay `⌊ ⌋` ni `⌈ ⌉`), la primera desigualdad falla para
> algunos grupos pequeños. Para violarla basta una **cota inferior** de `cd`: si `BC_n(G)≠0` entonces `cd(G) ≥ n` por (4.4).
>
> | grupo | `n` con `BC_n≠0` | fuerza `cd ≥` | `log₂ ord(H)`, `H` abeliano maximal de mayor orden |
> |---|---|---|---|
> | `ℤ/3` | `BC₂=ℤ` | 2 | `log₂3 = 1.58` |
> | `𝔖₃` | `BC₂=ℤ/2` | 2 | `log₂3 = 1.58` (y `(3/3)·log₂3 = 1.58`) |
> | `ℤ/7` | `BC₂=ℤ/2×ℤ³`, **`BC₃=ℤ/2`** | **3** | `log₂7 = 2.81` |
>
> `BC₂(ℤ/3)=ℤ` y `BC₂(𝔖₃)=ℤ/2` son valores **del propio paper** (§4 y §6.3). `BC₃(ℤ/7)=ℤ/2` lo dan **ambas**
> implementaciones nuestras, la del Teorema 5.2 y la de la definición directa [C]. Para `ℤ/3` y `𝔖₃` la violación
> es entonces consecuencia de números del propio paper.
>
> Las demás desigualdades sí se cumplen en todos los casos calculados (hasta los `n` que probamos, no hasta la cota
> rigurosa de §4.4): `cd_ℚ(ℤ/3)=2 ≤ log₃3+1=2` (con igualdad), `cd_ℚ(ℤ/7)=2 ≤ 2.77`, `cd_ℚ(𝔖₈)=3 ≤ 8/3+1`;
> `cd(𝔖₄)=2 = log₂4`, `cd((ℤ/2)⁴)=4 = log₂16`, `cd(𝔖₈)=4 ≤ (8/3)log₂3 = 4.23`.
> **No afirmo que el paper esté mal**: puede ser una errata (¿`⌈·⌉`?, ¿un `+1`?) o una hipótesis implícita sobre `H`.
> Es una buena pregunta para los autores (`05`, pregunta 1). Detalle de los datos en `03`, §8.

### 4.6 Restricción (D8) y anillo (D9)

**Restricción** [P] (introducida en [12, §7]). Para `G'⊆G`, `res^G_{G'}: BC_n(G) → BC_n(G')`. `G` actúa por conjugación sobre el
conjunto de símbolos generadores (como en (C)); para un símbolo `s=(H,Y,β)` la acción de `G'` parte su clase de
conjugación en órbitas finitas y

    s ↦ Σ_{s'} (H'∩G', Y'∩G', β'|_{H'∩G'}),

suma sobre representantes `s'=(H',Y',β')` de las `G'`-órbitas. "Respeta las relaciones por construcción."
No es sobreyectiva en general: `BC₂(𝔖₃)=ℤ/2`, `BC₂(ℂ₃)=ℤ`. [D: como `res:ℤ/2→ℤ` es nula (torsión ↦ sin torsión), no es sobreyectiva.]
(Nuestro código *no* implementa la restricción.)

**Anillo** [P]. Producto `BC_n(G)×BC_{n'}(G)→BC_{n+n'}(G)`: composición de
`BC_n(G)×BC_{n'}(G)→BC_{n+n'}(G×G)`, `(H,Y,β)×(H',Y',β') ↦ (H×H', Y×Y', β∪β')`, con la restricción a la diagonal.
Se obtiene el anillo graduado finitamente generado `BC_*(G)=⊕_{n≥0}BC_n(G)`, `BC_0(G)=ℤ`, "sujeto a varias propiedades
de funtorialidad". (Nuestro código no implementa el producto.)

---

## 5. Paper §5 — Teoría de la estructura

### 5.1 El grupo `BC′_n(G)` (D10) y la descomposición

Se define un cociente `SC_n(G) → BC′_n(G)` imponiendo (C), (V) y **(B2′)**, una modificación de (B2):

* **(B2′)** para `b₁=b₂`: `(H,Y,(b₁,b₂,…,b_r)) = (H,Y,(b₂,…,b_r))` (5.1); para `b₁≠b₂`: `(H,Y,β)=(H,Y,β₁)+(H,Y,β₂)` con `β₁,β₂`
  como en (4.2). **Es decir: se elimina el término `Θ₂`.**

Se escribe `(H,Y,β)′` para el símbolo visto en `BC′_n(G)`.

Como todas las relaciones conservan la `G`-clase `[H,Y]` del par:

    BC′_n(G) = ⊕_{[H,Y]} B_n([H,Y]),     B_n([H,Y]) := ⊕_{(H',Y',β'), (H',Y')∈[H,Y]} ℤ·(H',Y',β') / (C),(V),(B2′).     (5.2)

### 5.2 La relación `(C_{(H,Y)})` (D11)

Sobre `S_n(H)`: para todo `β∈S_n(H)` y `g∈N_G(H)∩N_G(Y)`: `β=β^g`.   **`(C_{(H,Y)})`**

### 5.3 Lema 5.1  [P]
`B_n([H,Y]) ≃ B_n(H)/(C_{(H,Y)})` como grupos abelianos (5.3).

**Prueba (la idea, con las partes que hay que entender)**:

* *Se define la aplicación.* Fijado el representante `(H,Y)`, un generador `(H',Y',β')` con `(H',Y')∈[H,Y]` se envía a
  `((b'₁)^g,…,(b'_r)^g,0,…,0) ∈ S_n(H)`, con `g∈G` tal que `H=gH'g⁻¹`, `Y=gY'g⁻¹`  (5.4): se transporta el símbolo
  a la representante y se **rellena con `n−r` ceros**.
* *No depende de `g`.* Si `g,g'` son dos elecciones, `g'g⁻¹∈N_G(H)∩N_G(Y)`, y la diferencia es exactamente lo que
  identifica `(C_{(H,Y)})`.
* *Respeta las relaciones.* (C) por construcción; (V) y (B2′) por linealidad de la conjugación,
  `(b₁+b₂)^g=b₁^g+b₂^g`, y porque en `B_n(H)` valen las tres identidades de la advertencia de §3
  (`(b₁,b₁,…)=(0,b₁,…)`, `(b₁,b₂,…)=(…)+(…)`, `(b₁,−b₁,…)=0`).
* *Inverso.* `(b₁,…,b_n) ↦ (H,Y,β)` donde `β` se obtiene quitando los ceros: compatible con (B) y `(C_{(H,Y)})`. ∎

**Lo esencial que hay que retener** [D]: un generador de `BC′_n` de longitud `r` se identifica con una `n`-tupla con
`n−r` ceros. Así `BC′_n(G)` es, sumando sobre `[H,Y]`, un `B_n(H)` (tuplas de `n` caracteres que generan `H^∨`, con
ceros) módulo la conjugación por el estabilizador. **Es exactamente lo que enumera el código.**

### 5.4 Poset de símbolos y `Ψ`, `Φ` (D12)

Se define `s′=(H′,Y′,β′) ≤ (H,Y,β)=s` si y solo si `Y=Y′`, `H′⊆H` y `β′=β|_{H′}`. Los intervalos son isomorfos a intervalos
de `𝓗` y localmente a intervalos de retículos de subgrupos de abelianos, cuya función de Möbius es la de (2.1).
Se definen `ℤ`-homomorfismos `Ψ,Φ: SC_n(G)→SC_n(G)`:

    Ψ : (H,Y,β) ↦ Σ_{H'⊆H} (H',Y,β')′,        Φ : (H,Y,β)′ ↦ Σ_{H'⊆H} μ(H',H)(H',Y,β'),        β' = β|_{H'},

extendidos por linealidad, con la **convención**: *si `β'` contiene un cero, el símbolo se considera nulo* (y se
recuerda `(H',…)` con `H'=1` nulo por (V)). Son isomorfismos mutuamente inversos, `Ψ∘Φ=Φ∘Ψ=Id` (por §2).

### 5.5 **Teorema 5.2**  [P]
Para todo `n≥1` y todo `G`, `Ψ` desciende a los cocientes de `SC_n(G)`, dando un diagrama conmutativo

    SC_n(G) --Ψ--> SC_n(G)
       |               |
  (C),(V),(B2)     (C),(V),(B2′)
       ↓               ↓
    BC_n(G) --Ψ--> BC′_n(G)

con isomorfismo en la fila inferior, cuyo inverso es `Φ`. Por (5.2) y el Lema 5.1:

    **BC_n(G)  ≅  ⊕_{[H,Y]}  B_n(H)/(C_{(H,Y)}).**

**Esquema de la prueba** (hay que entenderlo; los cálculos están en el paper, pp. 12–13):

*(a) `Ψ` respeta (C) y (V).* Claro (restringir conmuta con conjugar; una pareja `bᵢ+bⱼ=0` sigue siéndolo, o se vuelve un
cero, y el símbolo se anula). El caso `b₁=b₂` de (B2) es inmediato término a término [D].

*(b) `Ψ` respeta (B2).* Sea `s=(H,Y,β)`, `b₁≠b₂`, `H̄=ker(b₁−b₂)`. Para `H'⊆H̄` se cumple `b₁|_{H'}=b₂|_{H'}`
(pues `b₁−b₂` se anula ahí). Por tanto `(β₁)|_{H'}` y `(β₂)|_{H'}` contienen un **cero** (`b₁|−b₂|=0`), y sus
símbolos valen 0. Así

    Ψ((H,Y,β_i)) = Σ_{H'⊆H, H'⊄H̄} (H',Y,β_i|_{H'})′,        i=1,2.

Por otro lado, `Ψ(s)=Σ_{H'⊄H̄}(…)′ + Σ_{H'⊆H̄}(…)′` (5.5). Se aplica **(B2′)** al primer bloque (para `H'⊄H̄`,
`b₁|≠b₂|`) obteniendo `(β₁|)′+(β₂|)′`, es decir `Ψ(H,Y,β₁)+Ψ(H,Y,β₂)`; y en el segundo bloque `b₁|=b₂|` y (5.1) da
`(H',Y,(b₂|,…,b_r|))′`, que sumado sobre `H'⊆H̄` es **exactamente `Ψ(Θ₂(s))=Ψ((H̄,Y,β̄))`**. Luego
`Ψ(s)=Ψ(β₁)+Ψ(β₂)+Ψ(Θ₂)` en `BC′_n`, que es la imagen de la relación (B2). ∎(b)

*(c) `Φ` respeta (B2′).* Sea `s′=(H,Y,β)′`. Por definición `Φ(s′)=Σ_{H'⊆H}μ(H',H)(H',Y,β|_{H'})` ∈ `BC_n`. Se aplica **(B2)**
(con su `Θ₂`) a cada sumando `(H',Y,β|_{H'})`. Uniformemente (Lema B) el sumando es
`(β₁|_{H'}) + (β₂|_{H'}) + (H'∩H̄, Y, β|_{H'∩H̄})`, donde `H̄'=ker((b₁−b₂)|_{H'})=H'∩H̄`. Se obtiene
`Φ(β₁)+Φ(β₂)` más el **término residual**

    Σ_{H'⊆H} μ(H',H)·(H'∩H̄, Y, β|_{H'∩H̄})  =  Σ_{H''⊆H̄} ( Σ_{H'⊆H, H'∩H̄=H''} μ(H',H) ) · (H'',Y,β|_{H''}).

(Para `H'⊆H̄` esa igualdad es trivial: `β₁|_{H'}` y `β₂|_{H'}` contienen un cero, valen 0, y el "término `Θ₂`" es el propio
sumando.) Como `b₁≠b₂`, `H̄⊊H`, y el **Lema 2.1** (con `G:=H`, `H':=H̄`) dice que **cada paréntesis interior es 0**. Luego
`Φ(s′)=Φ(β₁′)+Φ(β₂′)` en `BC_n`. ∎(c)

*(d)* Como `Ψ∘Φ=Φ∘Ψ=Id` en `SC_n(G)` y ambos respetan las relaciones, inducen isomorfismos inversos entre `BC_n(G)` y `BC′_n(G)`. ∎

**Resumen conceptual** [D/H]: `Ψ` es una "inversión de Möbius" que pasa de "lugar con estabilizador `≥H`" a
"lugar con estabilizador exactamente `H`". En esa base la relación de blow-up pierde el término que nace del nuevo
lugar fijo del divisor excepcional (`Θ₂`), y el grupo se descompone limpiamente por clases `[H,Y]`.

---

## 6. Paper §6 — Ejemplos y aplicaciones

### 6.1 Grupos abelianos

**(6.1)** [P]. Para `G` abeliano (Teorema 5.2 + (5.2)): `BC_n(G) = ⊕_{H'⊆G}⊕_{H''⊆H'} B_n(H'')`.

Contexto [P]: la clasificación de subgrupos abelianos finitos del grupo de Cremona plano está bien entendida [1]; en
dimensiones altas se sabe mucho menos; primeras aplicaciones del formalismo (acciones de grupos cíclicos sobre
cúbicas de dimensión 4) en [5].

**Grupos abelianos elementales** [P]: para `G≅𝔽_p^r`, `B_n(G)=0` si `n<r` (una tupla de longitud `<r` no puede generar
`G^∨`; ver `01` §1). Por (6.1), calcular `BC_n(G)` se reduce a `B_n(H'')` con `H''≅𝔽_p^m`, `m≤n`. El número de
`H''≅𝔽_p^m` en `G` es `#Gr(m,r)(𝔽_p)`. Los resultados de [7, §5], en particular el Teorema 14, dan información más fina de
`B_n(H'')⊗ℚ`.

**Problema 6.1** [P]: determinar la estructura de anillo de `BC_*(G)`, `G=𝔽_p^r`.

Los isomorfismos `Φ,Ψ` inducen una estructura de anillo en `BC′_*(G):=⊕_n BC′_n(G)`, con el producto definido en símbolos por

    (H,Y,β)′ ⋆̃ (H′,Y′,β′)′ ↦ Ψ( Φ((H,Y,β)′) × Φ((H′,Y′,β′)′) )      (6.2)

y por construcción `Ψ,Φ` son isomorfismos de anillos `BC_*(G) ≃ BC′_*(G)`.

**Proposición 6.2** [P]. Si `G` es abeliano, el producto (6.2) es

    (H,Y,β)′ ⋆̃ (H′,Y′,β′)′  ↦  0  si H≠H′;   (H, Y∩Y′, β∪β′)′  si H=H′.

*Idea de la prueba* [P, con detalle mío]: se expande `Φ×Φ` como suma doble de Möbius; el producto en `SC` intersecta
subgrupos, `H̃∩H̃′`, y se reagrupa por `H''=H̃∩H̃′`. El **Corolario 2.2** colapsa la suma: vale 0 si `H≠H′` y, si `H=H′`,
`Σ_{H̃⊆H}μ(H̃,H)(H̃,Y∩Y′,(β∪β′)|_{H̃})`, que es `Φ((H,Y∩Y′,β∪β′)′)`; aplicar `Ψ` da el enunciado. ∎
(Moraleja [D]: en la base `′` el producto es "diagonal" en `H`.)

### 6.2 Extensiones centrales de grupos abelianos

Motivación [P]: por [2], sobre `k=𝔽̄_p` los cocientes `V/G` son *universales* para cohomología no ramificada, con `V` una
representación fiel de una extensión central `G` de un abeliano; hay un algoritmo general para calcular en `Burn_n(G)` la
clase de una acción lineal sobre `V`, basado en modelos de De Concini–Procesi [10]. Eso motiva estudiar `BC_*(G)` para
tales grupos.

**Diedral** `G=𝔇_p` de orden `2p`, `p≥5` primo. **"Experimentos computacionales sugieren"** [P]:

    BC₂(G) = B₂([C_p,C_p]) = ℤ^{(p−5)(p−7)/24} × (ℤ/2)^{(p−3)/2} × ℤ/((p²−1)/12).

(Lo miré en el PDF: el exponente de `ℤ/2` es `(p−3)/2` y el cociente es `(p²−1)/12`.)
La conjugación sobre `β=(b₁,b₂)` en `B₂([C_p,C_p])` equivale a `(C_p,C_p,(b₁,b₂))=(C_p,C_p,(−b₁,−b₂))`, lo que lleva a una
variante `B₂^−(C_p)` del grupo de [7], y `B₂^−(C_p)⊗ℚ ≃ B₂([C_p,C_p])⊗ℚ` pues, según [5, Prop. 3.2],
`(C_p,C_p,(a,b))+(C_p,C_p,(−a,b))=0` en `B₂([C_p,C_p])⊗ℚ`. El rango de la parte libre está relacionado con la curva
modular `X₁(p)` [7, §11].

**Extensiones** `0→ℤ/p→G→(ℤ/p)²→0` con `Z(G)≅ℤ/p` [P]:

* `p=2`, `G=𝔇₄`: `BC₂(G)=(ℤ/2)³`.
* `p=3`, `G=𝔥𝔢₃`: `BC₂(G)=ℤ²⁶`, `BC₃(G)=ℤ⁴`.
* `p=5`, `G=𝔥𝔢₅`: `BC₂(G)=ℤ¹²⁴`, `BC₃(G)=(ℤ/2)³⁶×ℤ³⁶`.

Para `p` impar (grupo de Heisenberg) [P]:

    BC_n(𝔥𝔢_p) = B_n([ℤ/p,ℤ/p])^{3p+5} ⊕ B_n([(ℤ/p)²,(ℤ/p)²])^{p+1}.

### 6.3 Grupos simétricos  [P]

Tabla (Paper §6.3):

| `m` | `BC₂(𝔖_m)` | `BC₃(𝔖_m)` |
|---|---|---|
| 3 | ℤ/2 | 0 |
| 4 | (ℤ/2)³ | 0 |
| 5 | (ℤ/2)⁶ × ℤ/4 | 0 |
| 6 | (ℤ/2)³¹ × (ℤ/4)³ × ℤ/8 | (ℤ/2)⁵ × ℤ/4 |
| 7 | (ℤ/2)⁵⁷ × (ℤ/4)¹² × (ℤ/8)² × ℤ/3 | (ℤ/2)¹⁶ × ℤ/4 |
| 8 | (ℤ/2)²⁹⁰ × (ℤ/4)³⁰ × (ℤ/8)⁶ × ℤ/16 × (ℤ/3)² × ℤ | (ℤ/2)¹²² × (ℤ/4)⁴ × ℤ/8 × ℤ |

**Ejemplo `𝔖₄`** [P]: las únicas clases `[H,Y]` que contribuyen a `BC₂` son (1) `(C₃,C₃)`, `C₃=⟨(2,4,3)⟩`;
(2) `(K₄,K₄)`, `K₄=⟨(3,4),(1,2)(3,4)⟩`; (3) `(C₄,C₄)`, `C₄=⟨(1,4,2,3)⟩`. Cada una da `B₂([H,Y])=ℤ/2`.
[C] Nuestro código encuentra 11 clases, de las cuales exactamente esas tres son no nulas (con *los mismos
generadores* de `C₃` y `K₄` que el paper), ver `03`, §3.

### 6.4 Subgrupos no abelianos del grupo de Cremona plano  [P]

Los que admiten acciones **primitivas** sobre `ℙ²`: `A₅`, `ASL₂(𝔽₃)`, `PSL₂(𝔽₇)`, `A₆`.

* `A₅=⟨(1,2,3),(3,4,5)⟩⊂𝔖₅` (el paper escribe `⟨(1,2,3)(3,4,5)⟩`, con la coma perdida, que sería un solo 5-ciclo; es una errata evidente).
  Aportes no triviales: `(C₃,C₃)` con `C₃=⟨(1,2,5)⟩`: `B₂=ℤ/2`; `(C₅,C₅)` con `C₅=⟨(1,4,5,3,2)⟩`: `B₂=(ℤ/2)²`.
  `BC₂(A₅)=(ℤ/2)³`, `BC_n(A₅)=0` para `n≥3`.
* `ASL₂(𝔽₃)=C₃²⋊SL₂(𝔽₃)⊂𝔖₉`, generado por `⟨(2,5,8)(3,9,6), (2,4,3,7)(5,6,9,8), (1,2,3)(4,5,6)(7,8,9)⟩`:
  `BC₂=(ℤ/2)⁷×ℤ¹³`, `BC₃=ℤ/2×ℤ`, `BC_n=0` para `n≥4`.
* `PSL₂(𝔽₇)=⟨(3,6,7)(4,5,8),(1,8,2)(4,5,6)⟩⊂𝔖₈`. No nulos: `(C₃,C₃)` con `C₃=⟨(2,6,5)(3,7,4)⟩`: `ℤ/2`;
  `(C₇,C₇)` con `C₇=⟨(1,2,5,3,6,7,4)⟩`: `ℤ/2×ℤ`; `(C₄,C₄)` con `C₄=⟨(1,3,4,8)(2,7,6,5)⟩`: `ℤ/2`.
  `BC₂=(ℤ/2)³×ℤ`, `BC₃=ℤ/2`, `BC_n=0` para `n≥4`.
* `A₆=⟨(1,2)(3,4,5,6),(1,2,3)⟩`: `BC₂=(ℤ/2)⁷×ℤ/4×ℤ`, `BC₃=ℤ/2×ℤ`, `BC_n=0` para `n≥4`.

### 6.5 Una aplicación geométrica: `C₂×𝔖₃`  [P]

`G=C₂×𝔖₃=𝔇₆=⟨(1,2,3,4,5,6),(1,6)(2,5)(3,4)⟩⊂𝔖₆`. Es sabido que la acción lineal de `G` sobre `ℙ²` y la acción tórica
sobre la superficie de del Pezzo `X` de grado 6 **no son equivariantemente birracionales** [6] (Iskovskikh); la prueba
de [6] usa el programa del modelo mínimo equivariante (enlaces de Sarkisov). En [5, §7.6] se distinguieron usando `Burn₂(G)`;
aquí se rehace con `BC`. Resultado:

    BC₂(G) = (ℤ/2)⁵ × ℤ/4,

con la descomposición por los subgrupos abelianos

* `H₁=C₃=⟨(1,3,5)(2,4,6)⟩`,
* `H₂=C₂²=⟨(2,6)(3,5),(1,4)(2,5)(3,6)⟩`,
* `H₃=C₆=⟨(1,2,3,4,5,6)⟩`,

y contribuciones no triviales a `BC′₂(G)`:

* `B₂([(H₁,H₁)])=ℤ/2`,
* `B₂([(H₂,H₂)])=(ℤ/2)²`,
* `B₂([(H₁,H₃)])=ℤ/2`,
* `B₂([(H₃,H₃)])=ℤ/2×ℤ/4`.

(`(H₁,H₃)`: `H=C₃`, `Y=C₆=Z_G(C₃)`.) Por [11, Prop. 6.1] hay una fórmula para la diferencia `[X↷G]−[ℙ²↷G]∈Burn₂(G)`, donde
`ℙ²=ℙ(1⊕V_χ)` y `V_χ` es la representación estándar de dimensión 2 de `𝔖₃` torcida por el carácter de `C₂`. Aplicando el
homomorfismo `Burn₂(G)→BC₂(G)` de [12, Prop. 8] se obtiene la clase

    (diag. en C₂×𝔖₂, C₂×𝔖₂, (1)) + (C₂, C₂×𝔖₂, (1)) + (C₃,C₃,(1,1)) − (C₂, C₂×𝔖₃, (1)) − (C₂×C₃, C₂×C₃, ((0,1),(1,2))) ∈ BC₂(G),

cuya imagen por `Ψ` es

    (C₃,C₃,(1,1)) − (C₃,C₂×C₃,(1,2)) ∈ BC′₂(G),

"una clase de 2-torsión no trivial". Además `BC₃(G)=0`, así que **no se pueden distinguir** `X×ℙ¹` y `ℙ²×ℙ¹` (acción trivial
en el factor `ℙ¹`), problema planteado en [13, Rem. 9.13].

**Notas** [D]: (i) nuestro código verifica el grupo `BC₂(G)` y su descomposición por `[H,Y]` (`03`, §4), **no** la
clase concreta de la diferencia (requeriría `Burn₂(G)→BC₂(G)`). (ii) La notación `(C₃,C₂×C₃,(1,2))` es ambigua para
mí: para `H=C₃` los caracteres `1` y `2` suman `0` y el símbolo se anularía por (V); presumiblemente el segundo
factor es `H=C₃` con `Y=C₂×C₃` y otra lectura de `β`, o `H` es otro subgrupo. Es la pregunta 3 en `05`.

---

## 7. Lista de imprecisiones/erratas detectadas (para no tropezar)

1. **Paper §3, (B)**: "para todo `β`" es incorrecta con ceros permitidos; la versión válida es la de las identidades del
   Lema 5.1 (ver la advertencia en §3).
2. **Paper §4, Conjetura 4.2**: literalmente falsa para `ℤ/3`, `𝔖₃`, `ℤ/7` según nuestros cálculos (§4.5).
3. **Paper §6.4, `A₅=⟨(1,2,3)(3,4,5)⟩`**: falta una coma.
4. **Paper §6.5, símbolo `(C₃,C₂×C₃,(1,2))`**: ambiguo (§6.5).
5. **Paper §4, (4.2)**: se define `H̄:=ker(⟨b₁−b₂⟩)`: el "núcleo de un subgrupo de caracteres" debe leerse "subgrupo de
   `H` donde se anula el carácter `b₁−b₂`" (equivalente a `ker(b₁−b₂)`).
6. **Notación (6.1)**: `H'` (el segundo índice) hace de `Y` y `H''` de `H`.
7. **Prop. 4.1**: la prueba usa (4.3) (anulación por sumas parciales), que el paper toma de [8]; nuestro código
   confirma numéricamente que no añade nada nuevo, pero es una dependencia de otra fuente.
8. Los valores de §6.2 para `D_p` son **empíricos** ("computer experiments suggest"): no hay demostración en el paper.
