# 1. Prerrequisitos: lo que el paper da por sabido

El paper es muy corto (19 páginas) y da por sabidos varios hechos elementales. Aquí están todos, con
prueba cuando la prueba es corta y *se usa realmente* más adelante. Etiquetas: **[P]** paper, **[C]** calculado,
**[D]** deducción/hecho estándar, **[H]** heurística.

Contenido:
1. Caracteres de grupos abelianos finitos (y dos lemas clave que el paper usa sin nombrarlos)
2. Acción de `N_G(H)` sobre `H` y sobre `H^∨`
3. Clases de pares `(H,Y)` y estabilizadores
4. Función de Möbius y las transformaciones `Ψ`, `Φ`
5. Presentaciones de grupos abelianos, forma normal de Smith, notación primaria
6. Contexto geométrico mínimo (heurístico): de dónde salen las relaciones

---

## 1. Caracteres de un grupo abeliano finito

Sea `H` abeliano finito. Su **grupo de caracteres** es `H^∨ = Hom(H, ℂ^×)`, con el producto puntual.
Como los valores son raíces de la unidad, es equivalente (y más cómodo) ver un carácter como un
homomorfismo `H → ℚ/ℤ`; **el paper escribe `H^∨` aditivamente**: `b+b'`, `−b`, y `0` es el carácter trivial.

Hechos estándar [D]:

* **(K1)** `H^∨ ≅ H` (isomorfismo *no* canónico); en particular `|H^∨| = |H|`.
  Si `H = ⟨g₁⟩×⋯×⟨g_k⟩` con `ord(gᵢ)=dᵢ`, un carácter `b` queda determinado por `(c₁,…,c_k)∈∏ ℤ/dᵢ`
  con `b(gᵢ)=exp(2πi cᵢ/dᵢ)`. **Es exactamente la codificación que usa el código** (`CharCtx`).
* **(K2)** Para `K ≤ H`, la restricción `H^∨ → K^∨`, `b ↦ b|_K`, es **sobreyectiva** (los caracteres de un
  subgrupo se extienden). Su núcleo es el *anulador* `K^⊥ = {b ∈ H^∨ : b|_K = 0}`, luego
  `K^∨ ≅ H^∨/K^⊥` y `|K^⊥| = |H|/|K|`.
* **(K3)** *Dualidad.* Para `S ⊆ H^∨` sea `S_⊥ = ⋂_{b∈S} ker b ≤ H`. Entonces `(S_⊥)^⊥ = ⟨S⟩`.

**Cuántos caracteres hacen falta para generar `H^∨`.** El mínimo número de generadores de `H^∨ ≅ H` es el
**máximo `p`-rango** de `H` (el mayor `p`-rango entre los primos que dividen `|H|`). Por ejemplo `ℤ/6 = ℤ/2×ℤ/3`
tiene *una* sola generación necesaria, aunque su descomposición primaria tenga dos factores. Este detalle es la causa de
un error que cometí y corregí en el código (ver `04_el_codigo.md`, §7).

### Lema A (anulador de un núcleo)  **[D]**
Para `c ∈ H^∨`: `(ker c)^⊥ = ⟨c⟩`.

*Prueba.* `⟨c⟩ ⊆ (ker c)^⊥` es obvio (`c` se anula en su propio núcleo). El cociente `H/ker c` es isomorfo a la imagen
`c(H) ⊂ ℂ^×`, un grupo cíclico de orden `ord(c)`. Por (K2), `|(ker c)^⊥| = |H|/|ker c| = ord(c) = |⟨c⟩|`.
Inclusión más igualdad de órdenes da la igualdad. ∎

### Lema B (criterio de la aparición de `Θ₂`)  **[D]**
Sean `b₁ ≠ b₂` en `H^∨`, `H̄ = ker(b₁−b₂) ≤ H`. Entonces para todo `b ∈ H^∨`:

    b|_{H̄} = 0   ⟺   b ∈ ⟨b₁ − b₂⟩.

*Prueba.* Es el Lema A con `c = b₁−b₂`: `b|_{H̄}=0` significa `b∈H̄^⊥=(ker c)^⊥=⟨c⟩`. ∎

**Por qué importa.** La relación (B2) del paper (§4) dice: se añade el término `(H̄,Y,β̄)` *cuando ningún* `bᵢ`
pertenece a `⟨b₁−b₂⟩`. Por el Lema B eso equivale a que **`β̄ = β|_{H̄}` no contiene ningún cero**, es decir, a que
`(H̄,Y,β̄)` sea un símbolo legítimo (no automáticamente nulo). Con la convención "un símbolo con un cero vale 0"
(que el paper adopta explícitamente en §5, al definir `Φ`), la relación (B2) se puede leer de forma **uniforme**:

    (H,Y,β) = (H,Y,β₁) + (H,Y,β₂) + (H̄,Y,β|_{H̄})      [con símbolo := 0 si β|_{H̄} tiene un 0]

Es la lectura que usa la demostración del Teorema 5.2 y la que implementa `bc_direct`.

### Lema C (generar `H^∨` ⟺ acción fiel)  **[D]**
`β=(b₁,…,b_r)` genera `H^∨` **si y solo si** `⋂ᵢ ker bᵢ = 1`.

*Prueba.* Por (K3), `⟨β⟩ = (⋂ ker bᵢ)^⊥`. Este anulador es todo `H^∨` sii `|K^⊥|=|H|`, sii (K2) `|K| = 1`. ∎

*Lectura geométrica* [H]: `H` actúa sobre un espacio vectorial por los pesos `b₁,…,b_r`; que la acción sea **fiel**
es lo mismo que `⋂ ker bᵢ = 1`. Ésa es la razón de la condición "generan `H^∨`" en la definición de los símbolos.

---

## 2. La acción de `N_G(H)` sobre `H` y sobre `H^∨`

Sea `H ≤ G` abeliano. Todo `g ∈ N_G(H)` induce un automorfismo `φ_g(h) = g h g⁻¹` de `H` (la convención
`g⁻¹hg` da la inversa; **el conjunto de automorfismos inducidos por un subgrupo es el mismo con ambas
convenciones**, así que los cocientes que aparecen no dependen de ella). Se obtiene un homomorfismo

    N_G(H) → Aut(H),     con núcleo  Z_G(H).

La acción sobre caracteres es `(b^g)(h) = b(g⁻¹ h g)`; es lineal: `(b₁+b₂)^g = b₁^g + b₂^g`, y por tanto **envía
generadores de `H^∨` en generadores**, conserva la trivialidad, y respeta `b₁+b₂=0`. Esa compatibilidad es lo que hace
que (V), (B), (B2′) sean invariantes por conjugación (se usa en el Lema 5.1).

Consecuencia: los elementos de `Z_G(H)` actúan trivialmente sobre `H^∨`, así que la relación de conjugación
`β = β^g` solo ve la imagen de `N_G(H)∩N_G(Y)` en `Aut(H)` —un subgrupo de `Aut(H)`, que en el código llamamos
"imagen en Aut" (`autsize`).

---

## 3. Clases de pares `(H,Y)` y estabilizadores

Sea `𝒫 = {(H,Y) : H ≤ G abeliano, H ≤ Y ≤ Z_G(H)}`. `G` actúa por conjugación simultánea; es una acción bien
definida porque `g Z_G(H) g⁻¹ = Z_G(gHg⁻¹)`. Nótese: `Y` es **cualquier subgrupo** entre `H` y `Z_G(H)`:
no tiene por qué ser abeliano ni normal en nada (si `H≤Y≤Z_G(H)`, entonces `H ≤ Z(Y)`).

### Lema D (clasificación de las órbitas)  **[D]** (es implícito en el paper, Lema 5.1)
Las órbitas de `G` sobre `𝒫` están en biyección con pares
`( [H] , orbita de Y bajo N_G(H) )`: se elige un representante `H` de cada clase de conjugación de subgrupos abelianos
y se toman las órbitas de `N_G(H)` (por conjugación) sobre `{Y : H≤Y≤Z_G(H)}`.
El estabilizador de `(H,Y)` en `G` es `N_G(H)∩N_G(Y)`.

*Prueba.* Si `g·(H,Y)=(H,Y')` entonces `gHg⁻¹=H`, es decir, `g∈N_G(H)`, y `Y'=gYg⁻¹`. Esto da la biyección con órbitas de
`N_G(H)` sobre los `Y`. El estabilizador es `{g : gHg⁻¹=H, gYg⁻¹=Y}`. ∎

**Es exactamente lo que hace `BCStructure`** (`Orbits(N, Ys, OnPoints)` y `Normalizer(N,Y)`), ver `04`.

---

## 4. Función de Möbius y las transformaciones `Ψ`, `Φ`

Sea `P` un poset finito. Su **función de Möbius** `μ(x,y)` (definida para `x≤y`) se caracteriza por

    μ(x,x)=1,        μ(x,y) = − Σ_{x ≤ z < y} μ(x,z)      (x<y),

y se extiende por `μ(x,y)=0` si `x≰y`. Es la que aparece en la §2 del paper para el poset `𝓗` de subgrupos abelianos.

**Inversión de Möbius** [D, estándar]: si `g(y) = Σ_{x≤y} f(x)` entonces `f(y) = Σ_{x≤y} μ(x,y) g(x)`.
En el paper: `Ψ((H)) = Σ_{H'⊆H} (H')` ("función zeta") y `Φ((H)) = Σ_{H'⊆H} μ(H',H)(H')` son inversas una de otra.

**Intervalos.** El intervalo `[H',H]` en `𝓗` es el retículo de todos los subgrupos de `H` que contienen a `H'`
(subgrupos de un abeliano son abelianos). Así, cuando `H` es abeliano, **`μ(H',H)` coincide con la función de Möbius
del retículo de subgrupos de `H`** (el paper lo señala en la prueba del Teorema 5.2).

Valor explícito, **hecho estándar que el paper no enuncia** [D]: para `H` abeliano finito,
`μ(K,H)=0` salvo que `H/K` sea elemental (producto de grupos `ℤ/p`), y en ese caso
`μ(K,H) = ∏_p (−1)^{k_p} p^{k_p(k_p−1)/2}`, con `k_p` el rango de la parte `p`-primaria de `H/K`.
Ejemplos: `μ(1,ℤ/p)=−1`; `μ(1,ℤ/4)=0`, `μ(ℤ/2,ℤ/4)=−1`; `μ(1,ℤ/6)=+1`; `μ(1,(ℤ/2)²)=2`.

**Cómo actúan `Ψ` y `Φ` sobre símbolos** (paper §5): `Ψ(H,Y,β)=Σ_{H'⊆H} (H',Y,β|_{H'})′` y
`Φ((H,Y,β)′)=Σ_{H'⊆H} μ(H',H)(H',Y,β|_{H'})`, con la convención "si `β|_{H'}` contiene un `0`, el símbolo es `0`".
Ejemplo pequeño [D]: `H=ℤ/4`, `β=(b)` con `b` generador de `H^∨`. Los subgrupos son `1<ℤ/2<ℤ/4`; `b|_{ℤ/2}` es
un carácter no nulo (el generador de `(ℤ/2)^∨`); `b|_1=0` (símbolo nulo). Entonces

    Φ((ℤ/4,Y,(b))′) = (ℤ/4,Y,(b)) − (ℤ/2,Y,(b|_{ℤ/2})).

Interpretación [H]: en `BC′` el símbolo `(H,Y,β)′` cuenta "el lugar con estabilizador *exactamente* `H`"
(en `BC` el lugar con estabilizador `≥ H`, que incluye los puntos con estabilizador mayor).

---

## 5. Presentaciones de grupos abelianos finitamente generados

Un grupo abeliano dado por generadores `x₁,…,x_N` y relaciones `Σⱼ Aᵢⱼ xⱼ = 0` (`i=1..R`) es el **cokernel**
`ℤ^N / (espacio fila de A)`, con `A ∈ M_{R×N}(ℤ)`. Es lo que construye `bn_quotient`: una fila por relación.

**Forma normal de Smith** [D, estándar]: existen `U,V` unimodulares con `U A V = diag(s₁,…,s_r,0,…)`, `s₁|s₂|⋯|s_r`
(`r` = rango de `A`). Entonces

    coker A ≅ ℤ/s₁ ⊕ ⋯ ⊕ ℤ/s_r ⊕ ℤ^{N−r}.

Los `sᵢ` son los **factores invariantes**. Por el teorema chino del resto, cada `ℤ/sᵢ` se descompone en
`ℤ/q` con `q` potencias de primo: los **divisores elementales** o descomposición **primaria**.
**El paper escribe siempre la descomposición primaria**, p. ej. `(ℤ/2)^{31} × (ℤ/4)³ × ℤ/8` (aquí solo interviene el primo 2, así que
los factores invariantes coinciden con los divisores elementales: `[2 (31 veces), 4, 4, 4, 8]`). Cuando intervienen varios primos
se agrupan: `ℤ/10` y `ℤ/2×ℤ/5` son el mismo grupo, y `ℤ/2×ℤ/3×ℤ/5×ℤ/4` tiene factores invariantes `[2, 60]`.

**Eliminación con pivotes ±1** (es lo que hace `cokernel_group`) [D]: si una relación tiene un coeficiente `±1`
en la columna `c`, ese generador se puede despejar (`x_c = ∓Σ_{j≠c} a_j x_j`); se sustituye en las demás filas y se
descarta *tanto* la fila como la columna `c`. El cokernel no cambia. En nuestro caso casi todas las relaciones son de
la forma `x = y`, `x = y+z` o `x = 0`, así que esto reduce drásticamente el tamaño antes de llamar a Smith.

---

## 6. Contexto geométrico mínimo (todo esto es [H], salvo lo citado del paper)

**Lo que dice el paper** [P, §1]. `G` finito actúa regularmente sobre una variedad proyectiva lisa `X` sobre un
cuerpo algebraicamente cerrado de característica 0. El estudio de esas acciones salvo equivalencia birracional
`G`-equivariante es un problema clásico (Cremona, etc.). En [8] se introdujeron invariantes con valores en
un grupo `Burn_n(G)` definido por generadores y relaciones; se calculan en un modelo *estándar* de `X` donde
(i) todos los estabilizadores son abelianos; (ii) la traslación por `G` de una componente irreducible `Y` de un lugar con estabilizador no trivial es
igual a `Y` o disjunta de ella. El invariante tiene en cuenta: subvariedades `Y ⊂ X` con estabilizadores no
triviales (abelianos) `H`; la acción inducida de `Z_G(H)` sobre `Y`; y la representación de `H` en el fibrado
normal a `Y`. La versión combinatoria [12] "olvida la información teórico-de-cuerpos", es decir, el tipo
birracional de la acción sobre las componentes; sólo conserva la información puramente de teoría de grupos.

**Pesos.** Si `Y` tiene codimensión `r` en `X` y `H` fija `Y` punto a punto, `H` actúa linealmente y de forma fiel
sobre el fibrado normal (rango `r`); diagonalizándola, obtenemos `r` caracteres `b₁,…,b_r` de `H`.
Son *no triviales* (si no, `Y` no sería una componente de `Fix(H)`) y *generan* `H^∨` (acción fiel, Lema C). Ése es el
símbolo `β`. Sólo importa el multiconjunto: relación (O). Renombrar por conjugación: relación (C). Como `r ≤ n = dim X`,
la longitud está acotada: `1 ≤ r ≤ n`.

**Blow-up** (explica (B) y el término `Θ₂`) [H — derivación mía, estándar en geometría tórica, no es del paper].
Sea `V = ℂ^r` con `H` actuando por los pesos `(b₁,b₂,b₃,…)`, y consideremos el blow-up del subespacio
`{x₁=x₂=0}` (las dos primeras coordenadas). Hay dos cartas:

* carta `x₂ ≠ 0`: coordenadas `(x₁/x₂, x₂, x₃,…)`, pesos `(b₁−b₂, b₂, b₃,…)` = `β₁`;
* carta `x₁ ≠ 0`: coordenadas `(x₁, x₂/x₁, x₃,…)`, pesos `(b₁, b₂−b₁, b₃,…)` = `β₂`.

Son los `β₁, β₂` de la relación (B) (paper (3.1)/(4.2)). Además, el divisor excepcional `E ≅ ℙ¹` tiene puntos
`[x₁:x₂]` y `h∈H` los mueve a `[b₁(h)x₁ : b₂(h)x₂]`: actúa trivialmente sobre `E` exactamente cuando `b₁(h)=b₂(h)`,
o sea `h ∈ H̄ = ker(b₁−b₂)`. Así **`E` es una nueva componente del lugar fijo de `H̄`**, con peso normal `b₁|_{H̄}=b₂|_{H̄}`:
es el símbolo `(H̄,Y,β|_{H̄})` (con el peso repetido eliminado), el término `Θ₂`. Si algún `bᵢ` vale cero sobre `H̄`
(Lema B), ese nuevo símbolo tendría un peso trivial y no es una componente legítima, luego no se cuenta.

**Vanishing (V).** `H=1` no aporta estabilizador; la anulación con `b_i+b_j=0` viene de [12, Def. 8.1]/[8, Prop. 4.7]
y no la justifico geométricamente. Sí observo [D] que, algebraicamente, (V) es exactamente lo que dice (B) cuando una de las entradas es `0`
(ver `04_el_codigo.md`, §4).

**Ojo con el nombre `Y`:** en la introducción del paper `Y` es la subvariedad; en la definición de símbolo `Y` es un
subgrupo con `H≤Y≤Z_G(H)`. Heurísticamente [H] este `Y` recoge la parte combinatoria de la acción de `Z_G(H)`
sobre la componente (algo así como su estabilizador genérico).
