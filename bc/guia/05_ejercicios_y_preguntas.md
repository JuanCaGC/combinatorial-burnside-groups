# 5. Ejercicios, experimentos y preguntas para los autores

Las soluciones están al final de cada bloque. **Todas las respuestas numéricas fueron comprobadas con el código**
(salvo que se indique lo contrario). Si vas justo de tiempo, haz los ejercicios marcados con ★.

---

## A. Ejercicios teóricos

### A1 ★ `B₂(ℤ/4)` y su cociente por `−1`
Calcula a mano `B₂(ℤ/4)` y `B₂(ℤ/4)/(−1)`. *(Pista: `H^∨={0,1,2,3}`; solo generan las tuplas que contienen un `1` o un `3`.
Ojo: `(2,2)` y `(0,2)` no generan.)*

### A2 ★ Möbius en `ℤ/6` y el Lema 2.1
(a) Calcula la función de Möbius `μ(K,ℤ/6)` para todo `K≤ℤ/6`.
(b) Comprueba el Lema 2.1 con `G=ℤ/6`, `H'=ℤ/2`, `H''=1`.
(c) Calcula `Φ((ℤ/4,Y,(b))′)` (con `b` generador de `(ℤ/4)^∨`) en términos de símbolos de `BC`.

### A3 `Ψ∘Φ=Id`
Demuestra a partir de la definición recursiva de `μ` que `Σ_{x≤z≤y} μ(z,y)=δ_{x,y}`, y de ahí que `Ψ∘Φ=Id` en el módulo `S` de la §2 del paper.

### A4 ★ `B₃(ℤ/3)=0` a mano
Enumera los 9 generadores de `B₃(ℤ/3)` y demuestra que todos son 0. *(Pista: aplica (B) a `(1,1,2)` tomando `b_i=1`, `b_j=2`.)*

### A5 `BC₁(G)` y conteo de órbitas
Demuestra que `BC₁(G)` es libre de rango igual al número de órbitas de `G` en `{(H,Y,b) : H cíclico ≠1, H≤Y≤Z_G(H), b generador de H^∨}`.
Usa la tabla de `𝔖₄` de `03` §3 para calcular `rango BC₁(𝔖₄)` y compáralo con el código.

### A6 ★ Grupos abelianos: `BC₂((ℤ/2)^r)`
Usa la fórmula (6.1) del paper y `B₂((ℤ/2)²)=(ℤ/2)²` (`03` §1.4) para calcular `BC₂((ℤ/2)^r)` para `r=2,3,4,5`. Da la fórmula general.

### A7 `BC₂(C₆)`, `BC₂(C₃×C₃)`, `BC₃(C₃×C₃)` con (6.1)
Descompón según (6.1) y usa los valores de `B₂(ℤ/2)`, `B₂(ℤ/3)`, `B₂(ℤ/6)` de `03` §2, y `B₂(C₃²)=ℤ⁷`, `B₃(C₃²)=ℤ³`, `B₃(ℤ/3)=0`.

### A8 ★ La familia diedral
Demuestra que `BC₂(𝔇_p)=B₂(ℤ/p)/(−1)` para `p` primo impar. ¿Qué pasa con las clases con `H=C₂`?

### A9 La cota de anulación
Con `ℓ=` máximo orden de un elemento y `a=` máximo orden de un subgrupo abeliano, deduce `BC_n(G)=0` para `n≥ℓ+a−1` a partir de la Prop. 4.1.
Calcula la cota para `𝔖₄`, `A₅`, `ℤ/7`. ¿Es ajustada? *(Compara con lo calculado en `03` §8.)*

### A10 Cuadro de la Conjetura 4.2
(a) Con `BC₂(ℤ/3)=ℤ`, comprueba por qué `cd(ℤ/3)≥2`. ¿Qué cota da la conjetura? (b) Repite con `BC₃(ℤ/7)=ℤ/2`. (c) ¿Para qué primos `p≤23` viola la conjetura entera (literal)?
*(Usa el resultado de la solución: `BC₃(ℤ/p)≠0` para `7≤p≤23` y `BC_n(ℤ/p)=0` para `n=4,5`.)*

### A11 Geometría del blow-up
Sea `H` actuando en `ℂ²` con pesos `(b₁,b₂)`, `b₁≠b₂`. Escribe las dos cartas del blow-up en el origen, calcula sus pesos, y prueba que el divisor excepcional está fijado punto a punto exactamente por `H̄=ker(b₁−b₂)`. Explica por qué eso da el término `Θ₂`. *(Ver `01` §6.)*

---

### Soluciones A

**A1.** Generadores: `x₁=(0,1)`, `x₃=(0,3)`, `y₁₁=(1,1)`, `y₃₃=(3,3)`, `y₁₃=(1,3)`, `y₁₂=(1,2)`, `y₂₃=(2,3)`.
Duplicados: `y₁₁=x₁`, `y₃₃=x₃`. (V): `y₁₃=0`. (B): `{1,3}`: `0=y₂₃+y₁₂` (`β₁=(1−3=2,3)`, `β₂=(1,3−1=2)`); `{1,2}`: `y₁₂=y₂₃+x₁` (`β₁=(1−2=3,2)`, `β₂=(1,1)`);
`{2,3}`: `y₂₃=x₃+y₁₂` (`β₁=(2−3=3,3)`, `β₂=(2,1)`). De las dos últimas: `x₁+x₃=0`. De la primera y la tercera: `2y₁₂=x₁`. Luego todo queda en términos de `y₁₂`
(`x₁=2y₁₂`, `x₃=−2y₁₂`, `y₂₃=−y₁₂`) y las relaciones se cumplen: **`B₂(ℤ/4)=ℤ`**.
Con `−1`: `x₁=x₃` da `4y₁₂=0`; `y₁₂=y₂₃=−y₁₂` da `2y₁₂=0`; entonces `x₁=2y₁₂=0`: **`ℤ/2`**. ✓ código (tabla de `03` §2).

**A2.** (a) `μ(ℤ/6,ℤ/6)=1`; `μ(ℤ/2,ℤ/6)=μ(ℤ/3,ℤ/6)=−1`; `μ(1,ℤ/6)=−(1−1−1)=1`. (b) Los `H` con `H∩ℤ/2=1` son `1` y `ℤ/3`: `μ(1,ℤ/6)+μ(ℤ/3,ℤ/6)=1−1=0` ✓.
(c) `Φ((ℤ/4,Y,(b))′) = (ℤ/4,Y,(b)) − (ℤ/2,Y,(b|_{ℤ/2}))` porque `μ(1,ℤ/4)=0`, `μ(ℤ/2,ℤ/4)=−1`, y la restricción a `1` tiene un cero (símbolo 0).

**A3.** La recursión del paper, `μ(x,y)=−Σ_{x≤z<y}μ(x,z)`, dice exactamente `Σ_{x≤z≤y}μ(x,z)=δ_{xy}`; de ahí sale **directamente** `Φ∘Ψ=Id`:
`Φ(Ψ(H))=Σ_{H'⊆H}Σ_{H''⊆H'}μ(H'',H')(H'')=Σ_{H''}(Σ_{H''⊆H'⊆H}μ(H'',H'))(H'')=(H)`. Para la otra composición se necesita `Σ_{x≤z≤y}μ(z,y)=δ_{xy}`:
se sigue de que `Ψ` y `Φ` son matrices cuadradas (el poset es finito) y una inversa por un lado es inversa por los dos (en el álgebra de incidencia, `μ` es la inversa de la función zeta). Entonces
`Ψ(Φ(H)) = Σ_{H'}μ(H',H)Σ_{H''⊆H'}(H'') = Σ_{H''}(Σ_{H''⊆H'⊆H}μ(H',H))(H'') = (H)`.

**A4.** Los 9 generadores: `(0,0,1),(0,0,2),(0,1,1),(0,1,2),(0,2,2),(1,1,1),(1,1,2),(1,2,2),(2,2,2)`.
(V): `(0,1,2)=(1,1,2)=(1,2,2)=0` (aparece la pareja `1,2`). (B) en `(1,1,2)` con `b_i=1`, `b_j=2`: `β₁=(1−2,1,2)=(2,1,2)=(1,2,2)`, `β₂=(1,1,2−1)=(1,1,1)`, luego `0=(1,1,2)=(1,2,2)+(1,1,1)=(1,1,1)`.
Duplicados: `(1,1,1)=(0,1,1)=(0,0,1)`, luego `(0,0,1)=0` y `(0,1,1)=0`. Como todas las relaciones son invariantes por `b↦−b`, el mismo argumento con `1↔2` da `(2,2,2)=(0,0,2)=(0,2,2)=0`. Todo es 0.
✓ código: `B₃(ℤ/3)=0`.

**A5.** Sin pares de entradas no hay relaciones (B) ni (V); solo (C) identifica símbolos en la misma órbita. Luego `BC₁` es libre sobre órbitas. Para `𝔖₄` (tabla `03` §3): las 7 clases con `H=C₂` aportan 1 cada una (un único carácter no nulo);
`C₃`: los generadores `{1,2}` con `|A|=2` (acción `−1`) forman 1 órbita; `C₄`: `{1,3}`, `|A|=2`: 1 órbita; `V₄` no es cíclico (no genera con 1 carácter): 0. Total `7+1+1=9`. ✓ código: `BC₁(𝔖₄)=ℤ⁹`.

**A6.** Por (6.1): `BC₂(G)=⊕_{H''⊆H'⊆G}B₂(H'')`. `B₂(H'')` es 0 si `H''` es trivial (V), si `H''=ℤ/2` (`03` §1.1), o si `rango H''≥3`. Para `n=2` solo cuentan los `H''≅(ℤ/2)²`, con `B₂=(ℤ/2)²`.
Cada uno aparece `#{H'⊇H''}=#Sub((ℤ/2)^{r−2})` veces. Luego
`BC₂((ℤ/2)^r) = (ℤ/2)^{2·#Gr(2,r)(𝔽₂)·#Sub((ℤ/2)^{r−2})}`, con `#Gr(2,r)(𝔽₂)=(2^r−1)(2^{r−1}−1)/3` y `#Sub(1,ℤ/2,(ℤ/2)²,(ℤ/2)³)=1,2,5,16`.
`r=2`: `2·1·1=2`; `r=3`: `2·7·2=28`; `r=4`: `2·35·5=350`; `r=5`: `2·155·16=4960`. ✓ código: `(ℤ/2)²`, `(ℤ/2)²⁸`, `(ℤ/2)³⁵⁰`, `(ℤ/2)⁴⁹⁶⁰`.

**A7.** `C₆`: clases `(H'',H')`: `(C₂,C₂),(C₂,C₆),(C₃,C₃),(C₃,C₆),(C₆,C₆)` (5). Aportes `0,0,ℤ,ℤ,B₂(ℤ/6)=ℤ/2×ℤ²`. Total **`ℤ/2×ℤ⁴`** ✓ código (5 clases, `BC₂(C₆)=ℤ/2×ℤ⁴`, `BC₃(C₆)=0`).
`C₃×C₃`: `H''=C₃` (4 subgrupos), `H'∈{H'',G}` ⇒ 8 sumandos `ℤ`; `H''=G`: `B₂(C₃²)=ℤ⁷`. Total `ℤ¹⁵` ✓. `BC₃`: `B₃(C₃)=0` (A4), `B₃(C₃²)=ℤ³`: **`ℤ³`** ✓ código.

**A8.** `𝔇_p=⟨r,s⟩`. Subgrupos abelianos no triviales: `C_p` (normal, `Z_G(C_p)=C_p`), y los `p` subgrupos `C₂` (todos conjugados, `Z_G(C₂)=C₂`). `[C_p,Y]`: `Y=C_p` es el único (`Y≤Z_G(C_p)=C_p`), y `N_G(C_p)=G` actúa sobre `C_p` por `{±1}`.
`[C₂,C₂]`: solo `Y=C₂`. Este `H=ℤ/2` aporta 0 (`03` §1.1). Luego `BC₂(𝔇_p)=B₂(ℤ/p)/(−1)`. ✓ código (2 clases para todos los `p` probados).

**A9.** Bound `n≥ℓ+a−1`. `𝔖₄`: `ℓ=4`, `a=4` ⇒ `n≥7`; `A₅`: `5+5−1=9`; `ℤ/7`: `7+7−1=13`. No es ajustada: calculamos `BC_n(𝔖₄)=0` ya para `n=3,…,6`; `BC_n(ℤ/7)=0` para `n=4,5,6`; y `A₅` para `n=3,…,9` (aquí sí se alcanza la cota, 9, de modo que `BC_n(A₅)=0` para **todo** `n≥3`).
Sirve para *cerrar* verificaciones con un número finito de `n`; solo `A₅` la alcanzó en nuestros cálculos.

**A10.** (a) `BC₂(ℤ/3)≠0` ⇒ `cd(ℤ/3)≥2` por (4.4); la conjetura (versión entera literal) da `cd≤log₂3=1.58<2`. Contradicción. (b) `BC₃(ℤ/7)≠0` ⇒ `cd≥3>log₂7=2.81`. (c) Con `BC_n(ℤ/p)≠0` exactamente para `n≤3` (`p≥7`), `n≤2` (`p=3,5`), y `p≤23`: la desigualdad literal falla para `p=3` (2>1.58) y `p=7` (3>2.81);
se cumple para `p=5` (2≤2.32) y para `p=11,13,17,19,23` (3≤3.46,…). Con `⌈log₂p⌉` se cumple para todos. La versión racional `cd_ℚ≤log₃p+1` se cumple para todos los `p≤23` calculados (con igualdad en `p=3`).

**A11.** Ver `01` §6: cartas `(x₁/x₂,x₂)` con pesos `(b₁−b₂,b₂)` y `(x₁,x₂/x₁)` con `(b₁,b₂−b₁)`. `h·[x₁:x₂]=[b₁(h)x₁:b₂(h)x₂]=[x₁:x₂]` para todo punto sii `b₁(h)=b₂(h)`, es decir, `h∈ker(b₁−b₂)=H̄`.
Así el divisor excepcional es una nueva componente del lugar fijo de `H̄`, cuyo símbolo es `(H̄,Y,β|_{H̄})` (con el peso repetido eliminado); si algún `b_k` se anula en `H̄` (Lema B) ese "símbolo" no es válido (peso trivial) y no se cuenta. *(Es una explicación heurística, no del paper.)*

---

## B. Experimentos con el código

Todos con `include("BurnsideC.jl"); using .BurnsideC, Oscar` desde `/Users/juancagc/Groups/bc`.

**B1 ★ Reproducir el ejemplo geométrico.** `julia --project=. validate.jl demo`. Identifica en la tabla los cuatro sumandos del paper (`H₁,H₂,H₃`) y comprueba que la suma es `(ℤ/2)⁵×ℤ/4`.

**B2 ★ Tabla por clase.** Genera la tabla `[H,Y]` de `𝔖₄` y `A₅` (`03` §9). Para cada fila, predice `B₂` *antes* de mirarlo usando las "reglas de oro" de `03` §0.

**B3 Fórmula de `𝔇_p`.** Comprueba `BC₂(𝔇_p)` para todos los primos `5≤p≤101` contra `ℤ^{(p−5)(p−7)/24}×(ℤ/2)^{(p−3)/2}×ℤ/((p²−1)/12)` (¡usa `ab(...)` para comparar!). ¿Hasta qué `p` es cómodo? *(El coste es `~p²/2` generadores.)*

**B4 Rango de `B₂(ℤ/m)`.** Con `BurnsideC.bn_quotient([m],2,Vector{Int}[])` para `m=2..40` (sin acción), tabula rango y torsión. Contrasta el rango con `(p−1)/2+(p−5)(p−7)/24` para `m=p` primo. ¿Ves un patrón en el rango para `m` compuesto?
Intenta descubrir uno para la torsión (no conocemos fórmula).

**B5 Conjetura 4.2.** Para `C_p` (`p` primo `≤23`, `n≤5`) reproduce la tabla de `03` §8; extiéndela a `n=6` para `p` pequeño (¡mira cuánto crece `C(p+n−1,n)`!). Calcula `cd` y `cd_ℚ` de otros grupos pequeños (`SmallGroup`) y contrasta con ambas desigualdades.

**B6 Cruce.** Elige un grupo pequeño nuevo (p. ej. `GAP.evalstr("SmallGroup(24,12)")`, `𝔖₄`) y compara `bc(G,n).total` con `bc_direct(G,n)` para `n=1,2,3`. Si difieren, tienes un bug o una idea nueva.

**B7 Convención de conjugación.** Modifica `char_perm` para usar `M'` (transpuesta) o `M⁻¹` (inversa) en lugar de `M`. Comprueba que los resultados **de grupo** no cambian pero cambian las permutaciones individuales (`01` §2). ¿Qué pasaría si usaras una convención *inconsistente* entre distintos generadores?

**B8 Anulación por sumas parciales.** Usa `bc(st,n; extra_vanishing=true)` en varios grupos y comprueba que nunca cambia (paper (4.3)). ¿Puedes encontrar un contraejemplo en algún `H`? (Sería un hallazgo.)

**B9 Escalado.** Mide el tiempo de `bc(st,3)` para `He_p` con `p=3,5,7` (y `11`, con paciencia; ver `scaling.jl`) y estima la ley de crecimiento frente al número de generadores `C(|H|+n−1,n)` con `|H|=p²`.

**B10 Un grupo nuevo del paper.** Elige un grupo de la tabla de `02` §6.3 (por ejemplo `𝔖₆`), y prueba que cada número de `n=2,3` se reproduce; luego calcula `n=4,5,6` y determina `cd(𝔖₆)`.

---

## C. Preguntas para los autores

Ordenadas por importancia. Las tres primeras son las que yo llevaría a la reunión.

1. **Conjetura 4.2 (integral).** Tal como está impresa, `cd(G)≤log₂|H|` parece fallar para `G=ℤ/3`, `𝔖₃` (`cd≥2>1.58`) y `ℤ/7`
   (`BC₃(ℤ/7)=ℤ/2`, `cd≥3>2.81`). Para `ℤ/3` y `𝔖₃` basta con los valores `BC₂(ℤ/3)=ℤ`, `BC₂(𝔖₃)=ℤ/2` publicados en el propio paper.
   ¿Es una errata (¿`⌈·⌉`? ¿`+1`?), o `H` tiene una hipótesis implícita (p. ej. `|H|` grande, o `H` no cíclico)? ¿Hay evidencia a favor de la versión racional `cd_ℚ≤log₃|H|+1` (que sí se cumple en nuestros datos, con igualdad en `ℤ/3`)?
2. **Definición de `B_n(G)` (Paper §3).** (B) para todo `β` con ceros permitidos daría `β=2β` para `b₁=b₂=0`. ¿Confirman que la definición operativa es la de las identidades de la prueba del Lema 5.1
   (`(b₁,b₁,…)=(0,b₁,…)`, (B) para `b₁≠b₂`, `(b₁,−b₁,…)=0`)? ¿En [7] `B_n` incluye (V)?
3. **§6.5: la clase `Ψ(diferencia)`.** ¿Cómo debe leerse el símbolo `(C₃,C₂×C₃,(1,2))∈BC′₂(G)`? Para `H=C₃`, `1+2=0` y (V) lo anula. ¿Es `H=C₆`, `Y=C₆`, `β=(1,2)`,
   o `(C₃,C₆,(1,1))`?
4. **`𝔇_p` (§6.2).** ¿Hay demostración de la fórmula para `BC₂(𝔇_p)`, o queda en el ámbito experimental? Nuestro cálculo la confirma en `p=5,7,11,13,17,19,23,31,101`. ¿Y una fórmula para la **torsión** de `B₂(ℤ/p)` (sin cociente)?
   (Vimos `ℤ/2, ℤ/5, ℤ/7, ℤ/24, ℤ/15, ℤ/22` para `p=7,11,13,17,19,23`.)
5. **Valores nuevos** (no en el paper): `BC₄(𝔖₈)=(ℤ/2)²³` y `BC₅(𝔖₈)=0` (¿coincide con sus experimentos?); `𝔖₉`, `A₈`, `PSL₂(𝔽₈)`, `M₁₁` (`03` §7). ¿Coinciden con lo que han calculado?
6. **(V) con caracteres de orden 2.** Usar (V) para `b+b=0` con `b` repetido y (4.1) mata `(H,Y,(b,…))` cuando `r<n`. ¿Es la intención? (Es lo que hace nulos todos los sumandos con `H=ℤ/2`.) ¿Y si `r=n`?
7. **Sobre `BC_n(G)→B_n(G)` (introducción).** Para `G` abeliano, ¿es la proyección sobre el sumando `H=Y=G` de (6.1)? (Nosotros solo observamos que `B_n(G)` es sumando directo.)
8. **Dependencia de (4.3).** La Prop. 4.1 usa la anulación por sumas parciales de [8]. ¿Hay una demostración autocontenida a partir de (V)+(B2)?
9. **Cota explícita.** ¿Conocen una cota mejor que `n≥ℓ+a−1` para la anulación (p. ej. en función del rango o de `|H|`)? La Conj. 4.2 sugiere `n≈log₂|H|`; con `⌈log₂|H|⌉` es consistente con todo lo que calculamos (`03` §8).
10. **Producto y restricción.** ¿Hay tablas de multiplicación de `BC_*(G)` para grupos pequeños que pudiéramos contrastar? (No lo implementamos.)

---

## D. Errores típicos al leer el paper

* Confundir `Y` (subgrupo, `H≤Y≤Z_G(H)`) con `Y` (subvariedad) — misma letra, cosas distintas.
* Pensar que `BC_n(G)` cuenta símbolos de longitud exactamente `n`: es longitud `1≤r≤n` (equivale a rellenar con ceros hasta `n`).
* Olvidar que (V) prohíbe `b_i+b_j=0` para posiciones **distintas**, incluso con `b_i=b_j` de orden 2.
* Olvidar que `Y` puede ser no abeliano y que **no** se cuentan salvo `N_G(H)`-conjugación: en `𝔖₄`, `H=⟨(1,3)(2,4)⟩` tiene 5 clases de `Y`.
* Creer que en `BC′` el símbolo `(H,Y,β)′` "es" el símbolo `(H,Y,β)` de `BC`: son distintos (`Φ` los relaciona con términos de subgrupos menores, `01` §4).
* Comparar cadenas en vez de estructuras: `ℤ/10` y `ℤ/2×ℤ/5` son el mismo grupo (usa `ab(...)`).
* Contar clases de `H` salvo conjugación pero **no** las órbitas de `Y`.
