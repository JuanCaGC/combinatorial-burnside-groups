# 4. Guía del código

Archivos (todos en `/Users/juancagc/Groups/bc/`):

| archivo | líneas | qué contiene |
|---|---|---|
| [BurnsideC.jl](../BurnsideC.jl) | 649 | el módulo: aritmética de caracteres, `B_n(H)/(C)`, Teorema 5.2 (`bc`), definición directa (`bc_direct`) |
| [bc_structure.g](../bc_structure.g) | 93 | código GAP: clases `[H,Y]`, acción de estabilizadores; datos crudos para la definición directa |
| [validate.jl](../validate.jl) | 227 | compara con todos los números del paper; `crosscheck`, `demo`, `full` |
| [scaling.jl](../scaling.jl) | 25 | sondeo de tiempos |
| `Project.toml`, `Manifest.toml` | — | entorno Julia (OSCAR 1.8.2) |

Referencias a líneas: `BurnsideC.jl:249` significa "línea 249 de `BurnsideC.jl`" (numeración a la fecha de escribir esto).

---

## 1. Panorama

```
          GAP  (bc_structure.g)                         Julia  (BurnsideC.jl)
 ┌──────────────────────────────────────┐    ┌───────────────────────────────────────────────┐
 │ ConjugacyClassesSubgroups(G)         │    │  para cada clase [H,Y]:                       │
 │  └─ H abeliano ≠ 1                   │    │    CharCtx(d)  ← H = ∏ ℤ/dᵢ                   │
 │      d = órdenes de gens indep.      │    │    perms = char_perm(M)  (acción sobre H^∨)   │
 │      Y ∈ IntermediateSubgroups(Z,H)  │ ─► │    key = (d, n, cierre(perms))                │
 │      Orbits(N_G(H), Ys)              │    │    bn_quotient(d,n,perms):                    │
 │      Stab = Normalizer(N_G(H), Y)    │    │        generadores = multiconjuntos de H^∨    │
 │      M = matriz de cada gen. de Stab │    │        relaciones  (B), dup., (V), (C)        │
 └──────────────────────────────────────┘    │        cokernel_group → SNF → AbGroup         │
        (datos enteros planos)               │  suma de todos los AbGroup = BC_n(G)          │
                                             └───────────────────────────────────────────────┘

 Validación:  bc_direct(G,n)  ── otra ruta, sin Teorema 5.2 ──►  se compara con bc(G,n)
```

API pública (exportada): `bc_structure(G; name)`, `bc(st, n)` / `bc(G, n)`, `bc_direct(G, n)`, `AbGroup`, `ab("…")`,
`format_ab`, `npairs`, `gapobj`, `load_gap!`. Internas útiles: `BurnsideC.bn_quotient`, `BurnsideC.CharCtx`,
`BurnsideC.invariant_factors`.

`G` puede ser cualquier grupo de OSCAR (permutaciones, matrices…) o un objeto GAP crudo (`gapobj(G)` devuelve `G.X`).

---

## 2. Convenciones de datos (leer antes de mirar el código)

**Caracteres.** `H = ⟨g₁⟩×…×⟨g_k⟩` con `d=(d₁,…,d_k)` los órdenes (GAP: `IndependentGeneratorsOfAbelianGroup`,
que da una descomposición **primaria**: `ℤ/6` sale como `[2,3]`). Un carácter `b` es el vector `c=(c₁,…,c_k)`,
`cᵢ∈ℤ/dᵢ`, con `b(gᵢ)=cᵢ/dᵢ ∈ ℚ/ℤ`. Se **numera** en base mixta: índice `1+Σ cᵢ·strideᵢ`, con `strideᵢ = d₁⋯d_{i−1}`. El
carácter **cero** tiene índice **1** (Julia cuenta desde 1). `ctx.add[a,b]` y `ctx.neg[a]` son tablas para la suma y el opuesto.

**Multiconjuntos.** Un generador de `B_n(H)` es un `Vector{Int}` **ordenado no decreciente** de `n` índices de caracteres
(así (O) queda incorporada: el orden no importa porque siempre se ordena).

**Acción.** Cada generador `g` del estabilizador `N_G(H)∩N_G(Y)` se codifica en GAP como matriz entera `M` con
`g_j^g = ∏ᵢ g_i^{M[j][i]}` (notación GAP `x^g = g⁻¹xg`). La acción sobre caracteres es `(b^g)(g_j) := b(g_j^g)`.
Esta convención da el inverso de la del paper, pero **el grupo generado es el mismo** (`01` §2), así que el cociente es idéntico.

**Salida.** `AbGroup(free, pp)`: rango libre y un diccionario `potencia de primo ↦ multiplicidad`. Se imprime como el paper:
`(Z/2)^6 × Z/4`. `ab("(Z/2)^6 x Z/4")` lo parsea (así se compara **estructuralmente**, no como cadena).

---

## 3. `bc_structure.g` (la parte de teoría de grupos, en GAP)

### `BCStructure(G)`  ([bc_structure.g:14](../bc_structure.g))

Para cada clase de conjugación de subgrupos `H` (línea 17, `ConjugacyClassesSubgroups`), si `H≠1` y es abeliano:

1. `gens := IndependentGeneratorsOfAbelianGroup(H)`, `d := List(gens, Order)` (línea 20–21).
2. `C := Centralizer(G,H)`, `N := Normalizer(G,H)`.
3. `Ys` = todos los subgrupos entre `H` y `C`: `H`, los `IntermediateSubgroups(C,H).subgroups`, y `C` (líneas 24–29). (Si `C=H`, solo `[H]`.)
4. `orbs := Orbits(N, Ys, OnPoints)` (línea 31): las órbitas de `N_G(H)` sobre los `Y` por conjugación = las clases `[H,Y]`
   (Lema D de `01` §3).
5. Para cada órbita, `Y` = su primer elemento y `S := Normalizer(N, Y)` (línea 35) `= N_G(H)∩N_G(Y)` (es el estabilizador del Lema D).
6. Para cada generador `g` de `S` (`SmallGeneratingSet`, línea 37), `M := List(gens, x -> IndependentGeneratorExponents(H, x^g))`
   (línea 38): filas = exponentes de `g_j^g` respecto de `gens`. Se guardan solo las matrices **no identidad**.
7. Se devuelve un registro por `H` con `d`, generadores, `|C|`, `|N|`, y la lista `pairs` (una entrada por clase `[H,Y]`).

Notas:

* Se usa `ConjugacyClassesSubgroups` entero y se filtra: es el cuello de botella para grupos grandes (`S₉`: 51 s, `S₁₀`: > 10 min).
  Enumerar solo los abelianos sería una mejora natural (ver §8).
* `Y` puede ser **no abeliano** y no necesita ser normal; lo único exigido es `H≤Y≤Z_G(H)`.
* Los datos vuelven a Julia como enteros/listas/cadenas planos: `GAP.gap_to_julia(…; recursive=true)`.

### `BCDirectData(G)`  ([bc_structure.g:65](../bc_structure.g))

Solo para `bc_direct` (grupos pequeños). Numera los elementos de `G` (`els := AsSSortedList(G)`, "posiciones") y devuelve:

* `conj[a]`: permutación de posiciones `x ↦ a x a⁻¹` para cada generador `a` de `G`;
* `allsubs`: **todos** los subgrupos (no salvo conjugación) como listas ordenadas de posiciones (candidatos a `Y`);
* `subs`: todos los abelianos no triviales, con sus elementos, generadores independientes, `d`, vectores de exponentes de cada
  elemento, y el centralizador.

Se deduplica por listas de posiciones (no por comparación de grupos).

---

## 4. `BurnsideC.jl`

### 4.1 `AbGroup` y utilidades ([BurnsideC.jl:48](../BurnsideC.jl)–155)

* `prime_power_factors(n)`: `12 ↦ [4,3]`. `AbGroup(free, invariantes)` construye la forma primaria.
* `Base.:+` = suma directa; `==` compara `free` y `pp`.
* `invariant_factors(a)`: pasa de primaria a factores invariantes (agrupando por primos).
* `format_ab`: `"(Z/2)^6 × Z/4 × Z^2"` (primos crecientes, luego `Z`).
* `ab(str)`: parser de la notación del paper (acepta `x` o `×`).

### 4.2 `cokernel_group(rows, ncols)` ([BurnsideC.jl:169](../BurnsideC.jl))

Calcula `ℤ^{ncols}/⟨filas⟩`. `rows` es un vector de diccionarios (matriz dispersa).

1. **Eliminación de pivotes ±1** (`01` §5): en bucle, busca una fila con un coeficiente `ε=±1` en alguna columna `c` (elige `c` con menos
   apariciones), sustituye `x_c` en todas las demás filas que la contienen (`row2 -= (row2[c]·ε)·row`), y descarta esa fila y esa columna.
   `neliminated` cuenta las columnas eliminadas.
2. Lo que queda (filas no vacías, columnas que aparecen) se vuelca a una `ZZMatrix` densa y se calcula `snf` (Nemo/FLINT).
3. `tors` = entradas diagonales `>1`; rango libre `= (ncols − neliminated) − #{entradas diagonales ≠ 0}` (incluye columnas que nunca
   aparecen en ninguna relación, que son libres).

Devuelve `(AbGroup, tamaño_denso)`. Ese tamaño denso residual suele ser pequeñísimo (p. ej. `(13,3)` para `𝔖₄`, n=2, definición directa) y da idea de cuánto trabajo
lo hace la eliminación.

**Corrección** [D]: si una relación `r` tiene `x_c` con coeficiente `ε=±1`, `x_c ≡ −ε Σ_{j≠c} r_j x_j`; sustituir en las demás relaciones
da una presentación equivalente con un generador y una relación menos. Es un cambio de base unimodular sobre `ℤ`.

### 4.3 Caracteres: `CharCtx`, `generates_all`, `min_generators`, `char_perm`, `perm_closure`

* **`CharCtx(d)`** ([:249](../BurnsideC.jl)): construye (y cachea por `d`) las tablas de `H^∨`: lista `chars`, `add`, `neg`, `stride`,
  `D=lcm(d)`. `encode(ctx,c)` codifica un vector.
* **`generates_all(ctx, ents)`** ([:291](../BurnsideC.jl)): ¿los caracteres `ents` generan todo `H^∨`? Clausura por BFS del subgrupo generado.
  Implementa "β genera `H^∨`" (Lema C de `01`).
* **`min_generators(d)`** ([:285](../BurnsideC.jl)): mínimo número de generadores = **máximo `p`-rango** (cuántos `dᵢ` divide cada primo).
  Se usa como atajo: si `min_generators(d) > n`, `B_n(H)=0` sin enumerar. *(Aquí hubo un bug; ver §7.)*
* **`char_perm(ctx, M)`** ([:311](../BurnsideC.jl)): la permutación de los índices de caracteres inducida por la matriz `M`.
  *Derivación:* `(b^g)(g_j) = b(g_j^g) = b(∏ g_i^{M_ji}) = Σ_i M_ji·c_i/d_i  (mod 1)`. Ese valor pertenece a `(1/d_j)ℤ/ℤ` porque `g_j^g`
  tiene orden `d_j`. Con `D=lcm(d)`: `s_j = Σ_i M_ji c_i (D/d_i) mod D` y `c'_j = s_j/(D/d_j)` (división exacta; el código comprueba la
  divisibilidad y que el resultado sea una permutación, es decir, un automorfismo).
* **`perm_closure(gens)`** ([:335](../BurnsideC.jl)): clausura (BFS) del grupo de permutaciones generado; con tope 200 000, si se supera
  devuelve `nothing` y se usa el conjunto de generadores como clave de caché.

### 4.4 `bn_quotient(d, n, perms)` ([BurnsideC.jl:379](../BurnsideC.jl)) — el corazón

Construye `B_n(H)/(C)` para `H=∏ℤ/dᵢ`, con `perms` el grupo de permutaciones de caracteres que da la conjugación.

**Generadores** (línea 383): `gens = [ms for ms in multisets(m,n) if generates_all(ctx,ms)]`. Cada multiconjunto ordenado es una columna
(`col[g]=i`). Hay `C(|H|+n−1, n)` candidatos: **este es el límite de escala** (§8).

**Relaciones** (por generador `β` y por par de posiciones `i<j`, con `a=β[i]`, `b=β[j]`):

| caso | código | relación del paper | fila añadida |
|---|---|---|---|
| `a=b=0` (índice 1) | `continue` (línea 398) | ninguna: (B) con dos ceros diría `β=2β`; ver `02` §3 | — |
| `a=b≠0` | 399–401 | `(b,b,…)=(0,b,…)`  (4.1)/(5.1) | `β − β₀`, con `β₀[j]=0` |
| `a=b≠0`, `2b=0` | 402–404 | (V) con `bᵢ+bⱼ=b+b=0` | `β` |
| `a≠b`, ambos `≠0`, `a+b=0` | 407 | (V) | `β` |
| `a≠b`, ambos `≠0` | 408–410 | (B): `β=β₁+β₂` | `β − β₁ − β₂` |
| un solo cero | ninguna | (B) solo reproduce (V) | — |
| (para cada `p ∈ perms`) | 423–426 | `(C_{(H,Y)})`: `β=β^p` | `β − p(β)` |
| `extra_vanishing` | 413–422 | (4.3) suma parcial | `β` |

Comentarios [D]:

* **(V) y (B) son independientes** y se añaden *ambas* cuando `a+b=0` con `a≠b`. Tratarlas como excluyentes (`if/else`) fue un error mío (§7).
* Nunca se aplica (B) a entradas nulas. Con `b_j=0`, (B) da `β=β+(b_i,−b_i,…)`, es decir, (V): sin información nueva. Con dos ceros daría `β=0` (mal).
  Esta regla es la que resuelve el problema de redacción de (B) en Paper §3 (`02`, §3).
* Las permutaciones `perms` incluyen la identidad y todo el cierre. Son más filas de las estrictamente necesarias (bastaría con generadores), pero da
  una **clave de caché canónica**.
* `β1[i] = ctx.add[a, ctx.neg[b]]` es `b_i − b_j`; `β2[j]=b_j−b_i`. Se reordena (`sort(key)`) al buscar la columna.

Al final: `cokernel_group(rows, length(gens))` (línea 428). Devuelve también `(ngens, nrels, dense)`.

### 4.5 `bc(st, n)` ([BurnsideC.jl:499](../BurnsideC.jl)) — Teorema 5.2

Para cada clase de `H` y cada `[H,Y]`:

1. `perms = [char_perm(ctx, M) for M in mats]`; `cl = perm_closure(perms)`.
2. Clave de caché `(d, n, cl, extra_vanishing)`; si ya se calculó `B_n(H)/(A)` con el mismo `d` y el mismo grupo de permutaciones, se reutiliza.
   (Justificación: `B_n(H)/(A)` solo depende de `d` y del subgrupo `A` de permutaciones de `H^∨`.)
3. Si `min_generators(d) > n` el sumando es 0 sin enumerar.
4. Se acumula `total += val` y se guarda un `Summand` (para las tablas por clase).

`bc(G, n; name)` es solo `bc(bc_structure(G;name), n)`. Conviene **llamar `bc_structure` una vez** y luego `bc(st, n)` para varios `n`.

### 4.6 `bc_direct(G, n)` ([BurnsideC.jl:541](../BurnsideC.jl)) — definición sin Teorema 5.2

Implementa literalmente `SC_n(G)` y las relaciones (O),(C),(V),(B2):

* **Generadores** ([:554–568](../BurnsideC.jl)): tuplas `(i, y, β)` con `H_i` **cualquier** subgrupo abeliano no trivial (no salvo conjugación),
  `Y` **cualquier** subgrupo con `H_i ⊆ Y ⊆ Z_G(H_i)`, `β` multiconjunto de `r=1..n` caracteres **no nulos** que generan `H_i^∨`.
* **(V)** ([:606–608](../BurnsideC.jl)): fila `s` si hay dos posiciones con `bₐ+b_b=0`.
* **(B2)** ([:609–635](../BurnsideC.jl)): para cada par de posiciones:
  * `bₐ=b_b`: `s − (β sin la posición b)`;
  * `bₐ≠b_b`: `s − s₁ − s₂ − [Θ₂]`, donde `Θ₂` está presente **si y solo si** ningún `b_t ∈ ⟨bₐ−b_b⟩` (líneas 619–624; el conjunto `sub` es
    el subgrupo cíclico generado por `δ=bₐ−b_b`), y entonces `H̄ = {h∈H : δ(h)=0}` (línea 626), su índice `k` se busca por sus elementos (`subidx`),
    y `β̄` se calcula restringiendo cada `b` a los generadores de `H̄` (`transport` con la aplicación identidad sobre posiciones).
* **(C)** ([:636–643](../BurnsideC.jl)): para cada generador `a` de `G` (basta con generadores: la relación cierra por composición) se envía
  `(H,Y,β) ↦ (aHa⁻¹, aYa⁻¹, β^a)` con `(β^a)(x)=β(a⁻¹xa)`; la conjugación de posiciones `cinv[a]` transporta los caracteres.
* Se resuelve todo con `cokernel_group`.

Es más lento pero **no usa** clases de conjugación, ni órbitas de `Y`, ni la aplicación de Möbius: si coincide con `bc`, coinciden a la vez
(i) la enumeración GAP de `[H,Y]`, (ii) las matrices de acción, (iii) las relaciones de `B_n`, y (iv) el propio Teorema 5.2 (para ese grupo).

---

## 5. `validate.jl`

* `check(label, st, n, "paper")`: calcula `bc(st,n)`, parsea la cadena del paper con `ab`, compara **estructuralmente** y contabiliza.
* `check_summands`: compara el multiconjunto de `(|H|, |Y|, valor)` de los sumandos no nulos (clases del paper).
* `check_count`: número de clases `[H,Y]` por `|H|` (fórmula `3p+5`, `p+1` para Heisenberg).
* `quick()` (defecto), `full()` (S₇, S₈), `crosscheck()` (definición directa y sumas parciales), `demo()` (tabla de `C₂×S₃`).
* `getstruct` cachea `bc_structure` por grupo e imprime el tiempo de GAP (el dominante).

Grupos según el paper: `group_C2S3` (`⟨(1..6),(1,6)(2,5)(3,4)⟩`), `group_ASL23`, `group_PSL27`, `group_A6` con **los generadores del paper**;
Heisenberg: `Image(IsomorphismPermGroup(ExtraspecialGroup(p^3,"+")))` (exponente `p`).

---

## 6. Por qué se puede confiar en los resultados (y qué cubre cada prueba)

| riesgo | qué lo detectaría |
|---|---|
| mala enumeración de `[H,Y]` (clases, órbitas de `Y`) | conteos de Heisenberg (`3p+5`,`p+1`); clases exactas de `𝔖₄`, `A₅`, `C₂×𝔖₃` del paper; `bc_direct` (no usa órbitas) |
| acción incorrecta sobre `H^∨` (matrices, convención) | `𝔇_p` (acción `−1`); `V₄` de `𝔖₄`/`A₅`/`C₂×𝔖₃` con imágenes de orden 1,2,3,6 (§1.4 de `03`); `bc_direct` |
| relaciones de `B_n` mal implementadas | valores del paper para `n=2,3,4`; hechos a mano de `03` §1; `bc_direct` |
| error en la teoría (Teorema 5.2 mal usado) | `bc_direct` (implementa el original con `Θ₂`) |
| error en Smith / eliminación | rangos y torsiones que casan con el paper en decenas de grupos; `ab` parser estructural |
| relación (4.3) faltante | `extra_vanishing=true` no cambia nada |
| caché incorrecta | los mismos `d` con acciones distintas dan resultados distintos correctos (p. ej. los `V₄` de `𝔖₄`) |

**Límites de la validación**: los valores del paper son "verdad de referencia" tal cual están impresos; `bc_direct` es exhaustivo pero solo
para grupos pequeños (`|G|≲720`, `n` pequeño). Para `S₇`, `S₈`, `S₉`, etc., la garantía es indirecta: es el mismo código que pasa
todo lo demás, y en `S₇`,`S₈` reproduce el paper.

---

## 7. Historial de errores (por honestidad y como lección)

1. **(V) y (B) como excluyentes.** La primera versión hacía `if a+b==0 → (V) else (B)`. Resultado: `BC₂(𝔖₃)=ℤ` (en vez de `ℤ/2`) y `BC₂(𝔖₄)=ℤ/2×ℤ²`
   (en vez de `(ℤ/2)³`). Causa: en `ℤ/3`, `(B)` sobre `{1,2}` da `x₁+x₂=0`, que se perdía. Ahora ambas se añaden. Lo detectó
   la comparación con el paper.
2. **`length(d) > n` como cota de generación.** `IndependentGeneratorsOfAbelianGroup` es primaria: `ℤ/6` da `d=[2,3]`, y `B₁(ℤ/6)` es no nulo aunque
   `length(d)=2>1`. Ahora `min_generators` (máximo `p`-rango). Lo detectó **`crosscheck`** con `BC₁(C₂×𝔖₃)`: `ℤ¹⁰` vs `ℤ¹¹`. **No** afectaba a ningún valor
   publicado probado entonces, pero habría afectado a `S₇` (`V₄×C₃`).
3. Detalles menores: campo `Hsize` inexistente en `check_count` (el error quedó oculto por una redirección `>`), corregido con `prod(h.d)`.

Moraleja: la **implementación independiente** (`bc_direct`) fue lo que reveló el bug 2, que ninguna tabla del paper habría detectado.

---

## 8. Rendimiento y límites  [C]

Máquina: Mac Apple Silicon, un hilo; sin contar ~10 s de arranque de Julia/OSCAR.

| caso | enumeración GAP | álgebra lineal |
|---|---|---|
| `S₆` | 1.1 s | <0.1 s |
| `S₇` | 0.6 s | <0.1 s |
| `S₈` (587 clases) | 5 s | 0.5 s (n=2), 2.4 s (n=5) |
| `S₉` (964 clases) | 51 s | <1 s (n=2,3) |
| `S₁₀` | >10 min (abortado) | — |
| `(ℤ/2)⁵` (5395 clases) | 3 s | segundos (n≤5) |
| `𝔥𝔢₇`, n=3 (20 825 generadores) | 0.2 s | 7 s |
| `𝔥𝔢₁₁`, n=3 (~3·10⁵ generadores) | 0.3 s | no terminó en 8 min |

**Cuellos de botella:**

1. `ConjugacyClassesSubgroups(G)` para `|G|` grande (`S₁₀`+).
2. `|B_n(H)|` generadores: `C(|H|+n−1, n)`; se vuelve impráctico hacia `10⁵` generadores.
3. `bc_direct` es mucho más lento (`C₆×C₆`, n=3: 14 192 generadores, 133 s; por eso el `crosscheck` por defecto solo llega a n=2 ahí).

**Mejoras naturales (no hechas):** enumerar solo clases de subgrupos abelianos (por extensión de cíclicos); reducir generadores de `B_n(H)` a
representantes de órbitas del grupo de automorfismos *antes* de escribir relaciones; sustituir `Dict` por estructuras dispersas más eficientes o usar
`snf` disperso; paralelizar por clase `[H,Y]` (los sumandos son independientes).

---

## 9. Recetas

**Calcular un grupo cualquiera**
```julia
include("BurnsideC.jl"); using .BurnsideC, Oscar
G  = alternating_group(6)                # o cualquier grupo de OSCAR / GAP
st = bc_structure(G; name="A6")          # GAP: una vez
for n in 1:5
    println(bc(st, n))                   # BC_n(A6) = ...
end
```

**Grupo dado por generadores** (como el paper): `S = symmetric_group(6); G = sub(S,[cperm(S,[1,2,3,4,5,6]), cperm(S,[1,6],[2,5],[3,4])])[1]`.
**Matrices:** `GL(2,3)` de OSCAR también funciona (todo pasa por GAP).
**Grupo GAP directo:** `G = GAP.evalstr("DirectProduct(SymmetricGroup(3),CyclicGroup(IsPermGroup,4))")`.

**Comparar con el paper:** `bc(st,2).total == ab("(Z/2)^3")`.

**Comprobar la definición directa:** `bc_direct(G, 2)` devuelve `(grupo, info)`; comparar con `bc(G,2).total`.

**Sumandos por clase:** `r = bc(st,2); for s in r.summands … end` (campos `Hdesc, d, Hgens, Ydesc, Ysize, orbitsize, stabsize, autsize, value`).

**Un solo `B_n(H)/A`:**
```julia
B = BurnsideC
ctx = B.CharCtx([5])                                   # H = Z/5
neg = B.char_perm(ctx, reshape([-1],1,1))              # b ↦ −b
first(B.bn_quotient([5], 2, [collect(1:5), neg]))      # B_2(Z/5)/(-1) = (Z/2)^2
```

**Añadir una comprobación nueva** a `validate.jl`: `check("BC_2(G)", getstruct("G", () -> mi_grupo()), 2, "valor del paper")`.

---

## 10. Lo que el código NO hace

* No implementa la **restricción** `res^G_{G'}` ni el **producto** de `BC_*(G)` (Paper §4).
* No calcula la aplicación `Burn_n(G)→BC_n(G)` ni la clase `[X↷G]−[ℙ²↷G]` de §6.5 (`02`).
* No calcula `BC_n(G)⊗𝔽_p` ni `⊗ℚ` separadamente (se ve en el rango libre y la torsión del resultado; `cd_ℚ`, `cd_p` salen leyendo `AbGroup`).
* No verifica por sí mismo que los `n` calculados sean "suficientes" para afirmar `BC_n=0` para todo `n` (para eso, `02` §4.4: `n ≥ ℓ+a−1`).
* Grupos muy grandes: ver §8.
