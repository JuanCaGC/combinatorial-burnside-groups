# Guía de estudio — *Combinatorial Burnside groups* (Tschinkel–Yang–Zhang) y su implementación

Esta carpeta contiene una guía de estudio en varios archivos para entender **(a)** el paper
arXiv:2112.12801, **(b)** los resultados que reprodujimos, y **(c)** el código Julia/OSCAR que escribimos.
Está pensada para alguien con formación matemática (teoría de grupos de un curso de posgrado) pero sin
haber visto geometría birracional equivariante.

## Archivos y orden de lectura

| # | archivo | contenido | tiempo orientativo |
|---|---|---|---|
| 0 | `00_LEEME.md` | este índice, notación, diccionario paper ↔ código | 15 min |
| 1 | `01_prerequisitos.md` | todo lo que se usa y no es del paper: caracteres, órbitas de pares, Möbius, presentaciones de grupos abelianos, intuición geométrica | 1–2 h |
| 2 | `02_el_paper.md` | el paper sección por sección: **todas** las definiciones, relaciones, lemas, proposiciones, teoremas y conjeturas, con las pruebas que hace falta entender | 3–4 h |
| 3 | `03_ejemplos_y_resultados.md` | cálculos a mano (S₃, S₄, D₅, C₂×S₃…), las tablas de resultados, qué verificamos y cómo | 2 h |
| 4 | `04_el_codigo.md` | arquitectura del código, cada función, por qué es correcta, límites, cómo extenderlo | 2 h |
| 5 | `05_ejercicios_y_preguntas.md` | ejercicios (con pistas/soluciones), experimentos con el código, preguntas para los autores | a gusto |

Ruta mínima si tienes poco tiempo: §0 de este archivo → `02` §4–§5 (definiciones y Teorema 5.2) →
`03` §1–§3 (ejemplos a mano) → `04` §1–§3.

## La idea en diez líneas

1. Un grupo finito `G` actúa (regularmente) sobre una variedad `X`. En un modelo birracional adecuado
   ("forma estándar") los estabilizadores de puntos son **abelianos**.
2. Para cada componente `V` (subvariedad) de un lugar con estabilizador no trivial `H` se recogen tres
   datos [P, §1]: el subgrupo abeliano `H`; la acción inducida de `Z_G(H)` sobre `V`, de la que la versión
   *combinatoria* solo conserva un subgrupo `Y` con `H ≤ Y ≤ Z_G(H)` (heurísticamente, el estabilizador
   genérico de esa acción [H]; el paper usa la misma letra `Y` para la subvariedad y para este subgrupo);
   y los **caracteres** (pesos) con que `H` actúa en el fibrado normal de `V`: una lista
   `β=(b₁,…,b_r)` de caracteres no triviales de `H` que generan `H^∨`.
3. El **grupo de Burnside combinatorial** `BC_n(G)` es el grupo abeliano generado por esos símbolos
   `(H,Y,β)` módulo relaciones: reordenar (O), conjugar (C), anular (V), y el "blow-up" (B2).
4. Es un invariante *equivariante birracional* (versión combinatoria del grupo `Burn_n(G)` de Kresch–Tschinkel).
5. **Teorema 5.2** (resultado principal): mediante una inversión de Möbius sobre el retículo de subgrupos
   abelianos, `BC_n(G) ≅ ⊕_{[H,Y]} B_n(H)/(C_{(H,Y)})`, suma sobre clases de conjugación de pares `(H,Y)`,
   donde `B_n(H)` es el grupo de símbolos de Kontsevich–Pestun–Tschinkel. La relación de blow-up pierde su
   término extra `Θ₂`.
6. Consecuencia práctica: `BC_n(G)` se calcula como suma de grupos abelianos finitamente presentados,
   uno por cada clase `[H,Y]`; cada uno es el cokernel de una matriz entera (forma normal de Smith).
7. El paper da valores: `BC₂(S₃)=ℤ/2`, `BC₂(S₄)=(ℤ/2)³`, …, `BC₂(C₂×S₃)=(ℤ/2)⁵×ℤ/4`
   (que distingue dos acciones de `C₂×S₃` sobre superficies racionales), etc.
8. Nuestro código implementa el Teorema 5.2 (`bc`) **y** la definición directa (`bc_direct`), y compara.
9. Reproduce **todos** los valores del paper que pudimos identificar (86 comprobaciones, 0 fallos).
10. Hallazgos propios: un desajuste aparente con la Conjetura 4.2 tal como está impresa (§4 de `02`), y
    varios valores nuevos (BC₄(S₈)=(ℤ/2)²³, …) que **no** están en el paper.

## Convenciones de etiquetado (importante para no confundir fuentes)

En toda la guía cada afirmación importante lleva una etiqueta de procedencia:

* **[P]** — está en el paper (con sección/número). Es lo que dice el paper, no lo que yo creo.
* **[C]** — lo calculó nuestro código (reproducible con los comandos indicados).
* **[D]** — deducción mía o hecho estándar de matemáticas que el paper no enuncia.
* **[H]** — heurística/intuición (geométrica sobre todo); no es una prueba ni una afirmación del paper.

Las referencias `[5]`, `[7]`, `[8]`, `[11]`, `[12]` son las del propio paper (bibliografía de la p. 18–19):
`[7]` Kontsevich–Pestun–Tschinkel (grupos `B_n(G)`, símbolos modulares), `[8]` Kresch–Tschinkel
(*Equivariant birational types and Burnside volume*), `[12]` Kresch–Tschinkel (*Equivariant Burnside groups:
structure and operations*; aquí está la definición 8.1 de `BC_n`), `[5]` Hassett–Kresch–Tschinkel,
`[11]` Kresch–Tschinkel (*toric varieties*). **No he leído esos trabajos**, solo lo que este paper cita de ellos.

## Notación

| símbolo | significado |
|---|---|
| `G` | grupo finito |
| `H`, `Y` | `H ≤ G` abeliano; `Y` subgrupo con `H ≤ Y ≤ Z_G(H)` |
| `Z_G(H)`, `N_G(H)` | centralizador y normalizador |
| `H^∨ = Hom(H, ℂ^×)` | grupo de caracteres; **se escribe aditivamente** (`b+b'`, `−b`, `0` = carácter trivial) |
| `β = (b₁,…,b_r)` | secuencia (multiconjunto) de caracteres |
| `β|_K` | restricción de cada `bᵢ` a un subgrupo `K ≤ H` |
| `b^g` | conjugado de `b` por `g∈N_G(H)`: `b^g(h)=b(g⁻¹hg)` |
| `⟨b⟩` | subgrupo cíclico de `H^∨` generado por `b` |
| `(H,Y,β)` | símbolo generador de `SC_n(G)` |
| `[H,Y]` | clase de `G`-conjugación del par `(H,Y)` |
| `SC_n(G)`, `BC_n(G)` | símbolos y grupo de Burnside combinatorial |
| `BC'_n(G)` | versión "de Möbius" (relación B2′ sin `Θ₂`), Teorema 5.2 |
| `S_n(H)`, `B_n(H)` | símbolos y grupo de símbolos de KPT (`n` caracteres, con ceros permitidos) |
| `B_n([H,Y])` | `B_n(H)/(C_{(H,Y)})`, sumando de `BC_n(G)` |
| `Ψ`, `Φ` | isomorfismos de Möbius mutuamente inversos |
| `μ` | función de Möbius del poset de subgrupos abelianos |
| `cd(G)` | dimensión combinatorial |
| `(ℤ/2)^k × ℤ/4` | notación **primaria** (divisores elementales), la del paper |

Los sub-índices `1` vs `0`: en el código, el carácter cero tiene índice `1` (Julia cuenta desde 1);
en matemáticas es `0`. Se avisa cuando importa.

## Diccionario paper ↔ código

| concepto en el paper | dónde | dónde vive en el código |
|---|---|---|
| clases `[H,Y]` (Teorema 5.2, (1.1), (5.2)) | §1, §5 | `BCStructure` en [bc_structure.g:14](../bc_structure.g) |
| `H ≤ Y ≤ Z_G(H)` | §4 | `IntermediateSubgroups(C,H)` en [bc_structure.g:27](../bc_structure.g) |
| `N_G(H)∩N_G(Y)` | (C_{(H,Y)}), §5 | `Normalizer(N,Y)` en [bc_structure.g:35](../bc_structure.g) |
| `H^∨` y su suma | §3 | `CharCtx` en [BurnsideC.jl:249](../BurnsideC.jl) |
| acción `b ↦ b^g` | (C) | `char_perm` en [BurnsideC.jl:311](../BurnsideC.jl) |
| `S_n(H)`: multiconjuntos de `n` caracteres que generan | §3 | `multisets` + `generates_all` ([358](../BurnsideC.jl), [291](../BurnsideC.jl)) |
| (B) `β=β₁+β₂` | (3.1), (4.2) | líneas 405–410 de [BurnsideC.jl](../BurnsideC.jl) |
| duplicado `(b,b,…)=(0,b,…)` | (4.1)/(5.1) | líneas 399–401 |
| (V) `bᵢ+bⱼ=0` | §4 | líneas 402–404 y 407 |
| (C_{(H,Y)}) | §5 | líneas 423–426 |
| `B_n(H)/(C)` como grupo abeliano | Lema 5.1 | `bn_quotient` [379](../BurnsideC.jl) + `cokernel_group` [169](../BurnsideC.jl) |
| `BC_n(G)=⊕_{[H,Y]} B_n([H,Y])` | Teorema 5.2 | `bc` [499](../BurnsideC.jl) |
| relaciones (C), (V), (B2) con `Θ₂` sobre `SC_n(G)` | §4 | `bc_direct` [541](../BurnsideC.jl) |
| tablas de valores del paper | §6 | [validate.jl](../validate.jl) |

## Cómo reproducir todo

```
cd /Users/juancagc/Groups/bc
julia --project=. validate.jl            # todos los valores del paper hasta S₆ (~16 s)
julia --project=. validate.jl demo       # tabla por clase [H,Y] de C₂×S₃ (§6.5)
julia --project=. validate.jl crosscheck # Teorema 5.2 contra la definición directa
julia --project=. validate.jl full       # añade S₇ y S₈
```

El informe resumido de validación está en `../REPORT.md`; la salida completa en `../validation_output.txt`.
