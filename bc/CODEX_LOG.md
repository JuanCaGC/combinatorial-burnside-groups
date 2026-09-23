# Registro de trabajo delegado a Codex

Bitácora del proceso de extender la implementación de `BC_n(G)` con ayuda de Codex
(vía el subagente `codex:codex-rescue` de este entorno de Claude Code). Se actualiza
cada vez que una tarea delegada termina de verdad (no en el despacho, sino cuando llega
el resultado real).

**Protocolo por ciclo** (por instrucción explícita del usuario, 2026-09-23):
1. **Evaluar** el estado del proyecto una vez llega un resultado real.
2. **Planear** qué sigue (¿se integra? ¿hace falta otra tarea? ¿investigar algo primero?).
3. **Investigar** si hace falta (lectura del código/reporte entregado, búsquedas, o correr
   pruebas propias).
4. **Ejecutar**: fusionar cambios, correr `validate.jl`, o delegar una tarea nueva a Codex
   (`codex:codex-rescue`) o a un subagente de Claude Code (`Agent`), según convenga.
5. **Registrar** aquí: qué se decidió, qué se hizo, qué falta.

---

## Configuración de la sesión

- **Codex CLI**: `codex-cli 0.156.1`, sesión de ChatGPT activa (`oipli190@gmail.com`).
- **Review gate**: activado (`reviewGateEnabled: true`) — Codex revisa su propio trabajo
  antes de dar una tarea por terminada.
- **Aislamiento**: el mecanismo nativo `isolation: "worktree"` del Agent tool **no funciona**
  en este entorno (falla con "not in a git repository... no WorktreeCreate hooks configured"
  incluso con el repo correctamente inicializado en `/Users/juancagc/Groups`). Solución
  adoptada: copias de carpeta independientes por tarea (`cp -r bc task-nombre`), cada agente
  trabaja solo dentro de su copia, y yo reviso/fusiono manualmente después.
- **Repositorio git**: inicializado en `/Users/juancagc/Groups` (no en `bc/`, que es donde
  vive el código pero no donde el Agent tool esperaba la raíz del repo).
- **GitHub**: repo privado creado y pusheado — https://github.com/JuanCaGC/combinatorial-burnside-groups
  Publicado: `bc/BurnsideC.jl`, `bc/bc_structure.g`, `bc/validate.jl`, `bc/scaling.jl`,
  `bc/REPORT.md`, `bc/validation_output.txt`, `bc/Project.toml`/`Manifest.toml`.
  **No publicado** (gitignored, solo local): `*.tex` (la nota para el Prof. Tschinkel),
  `*.pdf` (los papers descargados), y `bc/guia/` (la guía de estudio).

## Las tres tareas en curso (despachadas 2026-09-23)

| # | tarea | carpeta de trabajo | id de tarea Codex | estado |
|---|---|---|---|---|
| A | Certificado de forma normal de Smith (`U·A·V=D` verificable independientemente) | `/Users/juancagc/Groups/task-snf` | `task-mudnvhcd-gux4fe` | ✅ fusionado |
| B | Enumerador de subgrupos abelianos de `S_n` (evitar el cuello de botella de `ConjugacyClassesSubgroups` en GAP) | `/Users/juancagc/Groups/task-sn-enum` | `task-mudnvzp3-zjac5n` | ❌ idea matemática incorrecta, detenido a propósito |
| C | Exploración de `BC_n(AGL(1,p))`, buscando una fórmula nueva (no publicada) | `/Users/juancagc/Groups/task-agl1p` | `task-mudnx60e-fak29n` | 📊 datos registrados, no requiere fusión |

Motivación de cada una está en `guia/04_el_codigo.md` §8 (bottleneck de GAP), la conversación
sobre el certificado SNF (no-Lean), y `guia/03_ejemplos_y_resultados.md` §5 (familia `D_p`,
de donde sale la idea de probar `AGL(1,p)` por analogía). Los criterios de aceptación exactos
que se le dieron a Codex en cada caso están en los prompts de despacho (no repetidos aquí);
en resumen: A y B deben dejar `validate.jl all` en `passed: 86 failed: 0` sin excepción antes
de darse por terminadas; C es exploratoria y debe marcarse explícitamente como dato nuevo, no
verificado contra el paper.

---

## Entradas del ciclo

### 2026-09-23 — Despacho inicial
Las tres tareas se lanzaron en paralelo. Sin resultados reales todavía, solo confirmación de
que cada una arrancó dentro de Codex (ver tabla arriba). Nada que evaluar aún.

**Nota de proceso**: la notificación automática del Agent tool solo avisa cuando el *subagente
envoltorio* despacha la tarea a Codex, no cuando Codex termina de verdad. Las tres tareas ya
habían terminado (entre 5 y 13 minutos después del despacho) mucho antes de que yo me enterara.
Para chequear el estado real hay que usar
`node .../codex-companion.mjs status --all --json`, no esperar una segunda notificación.

---

### 2026-09-23 — Tarea A (certificado SNF): ✅ evaluada, verificada de forma independiente, fusionada

**Evaluar.** Codex añadió `certify_snf(rows, ncols) -> (A,U,V,D)` en `BurnsideC.jl`, usando
`Nemo.snf_with_transform` sobre la matriz original (sin la eliminación de pivotes `±1`, tal
como se pidió). Verificó `U·A·V=D`, `det(U)=±1`, `det(V)=±1` para **los 2 bloques `[H,Y]` de
`S_3`, n=2 y los 11 bloques de `S_4`, n=2** (no solo un sumando suelto — cubrió la presentación
completa del Teorema 5.2 en ambos casos). Lo hizo con **aritmética propia desde cero**
(eliminación de Bareiss para el determinante, multiplicación de matrices con `BigInt` normal),
sin reusar ninguna función de Nemo para el chequeo — que es justo el punto de un certificado
independiente. `validate.jl all` reportó `passed: 86 failed: 0`.

**Investigar / ejecutar.** No me quedé con su palabra: copié `BurnsideC.jl` y
`verify_certificates.jl` al proyecto real (`bc/`) y corrí ambos yo misma, en el entorno normal
(Codex tuvo que usar un *depot* de Julia temporal porque su sandbox no podía escribir en las
rutas por defecto; eso no afectó al código, solo a cómo lo ejecutó). Resultado idéntico:
`U·A·V==D: true` en ambos casos, `passed: 86 failed: 0` de nuevo.

**Decisión y registro.** Se fusiona. Commits: `Add certify_snf: independently-checkable Smith
normal form certificate`, `Add snf_certificates.txt: full A,U,V,D matrices for S_3, S_4 (n=2)`.
Publicado en GitHub. El cambio es puramente aditivo (nuevo parámetro `return_presentation`
en `bn_quotient`, con valor por defecto `false`; nueva función exportada); nada del camino
por defecto de `bc`/`cokernel_group` cambió.

---

### 2026-09-23 — Tarea C (`BC_n(AGL(1,p))`): 📊 datos registrados, un hallazgo real

**Evaluar.** GAP no tiene un constructor global `AGL` en esta instalación (lo asumí sin
comprobar al escribir el prompt — Codex lo notó y lo verificó en vez de dar por hecho que
existía). Construyó `AGL(1,p)` a mano (traslación + multiplicación por raíz primitiva mod `p`)
y **verificó exhaustivamente**, recorriendo todos los elementos, que la acción es realmente
`x↦ax+b` — no se conformó con que el orden coincidiera. Calculó `BC_1, BC_2, BC_3` para
`p=5,7,11,13,17,19,23` (pedidos) y además `29,31,37` (extendió por su cuenta, dentro de lo
razonable).

**Investigar.** Revisé la tabla completa y el razonamiento. Lo más valioso no es una fórmula
para `BC_2` o `BC_3` (no encontró ninguna, y lo dice honestamente: "No clear universal
polynomial/quadratic formula... was found"), sino una **fórmula exacta y con demostración
corta para `BC_1`**: escribiendo `m=p−1`,

    rango(BC_1(AGL(1,p))) = 1 + Σ_{d|m, d>1} φ(d)·τ(m/d) = 1 + σ(m) − τ(m)

(`σ`=suma de divisores, `τ`=número de divisores), verificada exactamente para los 10 primos
probados (`5,9,15,23,27,34,33,51,65,83`). La derivación es correcta: todo subgrupo abeliano no
trivial de `AGL(1,p)` es o bien la traslación `C_p` (con `N_G(H)=G` actuando por todo `𝔽_p^*`),
o bien está contenido en un estabilizador de punto `C_m` (cíclico, acción de conjugación
trivial sobre él) — de ahí la suma de divisores. **No verifiqué esta fórmula independientemente
yo misma** (no repetí el cálculo con `bc_direct` ni con otro método), solo revisé que el
argumento es internamente consistente y que coincide con los números de la tabla.

**Ejecutar.** No hay código que fusionar (tarea exploratoria, sin tocar `BurnsideC.jl` ni
`bc_structure.g`, tal como se pidió). Los datos quedan en `task-agl1p/CODEX_REPORT.md` y sus
logs (no publicados en GitHub, son exploratorios).

**Decisión.** Queda como dato de investigación, no como resultado verificado del mismo nivel
que las 86 comprobaciones contra el paper. Si se quiere usar en la reunión, presentarlo
explícitamente como nuevo y sin verificación cruzada — la fórmula de `BC_1` sí tiene
demostración, `BC_2`/`BC_3` son solo tablas.

---

### 2026-09-23 — Tarea B (enumerador de `S_n`): ❌ mi propia idea matemática estaba incompleta

**Evaluar.** Codex se detuvo *antes* de implementar nada, tal como se le pidió explícitamente
si encontraba un problema con la clasificación propuesta. Encontró un contraejemplo mínimo en
`S_4`:

- `H = ⟨(1,2)(3,4)⟩`, orden 2.
- `K = ⟨(1,2),(3,4)⟩`, orden 4.

Ambos tienen las mismas órbitas (`{1,2}` y `{3,4}`) y en cada órbita actúan como el mismo grupo
regular `C_2`. Según mi clasificación ("clase de conjugación ⟺ multiconjunto de (tamaño de
órbita, tipo de grupo)"), serían la misma clase. Pero `|H|=2 ≠ |K|=4`: no pueden ser
conjugados. Mi clasificación estaba **incompleta**, no solo mal implementada.

**Investigar (la parte que me tocaba a mí).** El error de fondo: un subgrupo abeliano `H` que
actúa con órbitas `O_1,…,O_k` se **inyecta** en el producto `∏ᵢ (imagen regular en Oᵢ)`, pero
no tiene por qué ser *todo* ese producto — puede ser un subgrupo "diagonal" (más precisamente,
un **producto subdirecto**, en el sentido del lema de Goursat). `H` en el contraejemplo es
exactamente la diagonal de `C_2×C_2`; `K` es el producto completo.

Peor: por Goursat, un producto subdirecto propio de `A` y `B` existe siempre que `A` y `B`
tengan un cociente común no trivial — **no hace falta que `A≅B`**. Por ejemplo `ℤ/4` y `ℤ/2`
comparten el cociente `ℤ/2`, así que hay productos subdirectos propios de `ℤ/4×ℤ/2` que ninguna
clasificación "por tipo de isomorfismo de cada órbita" vería. Es decir: la clasificación
correcta de subgrupos abelianos de `S_n` salvo conjugación no es solo "partición de `n` +
un grupo abeliano por bloque" — hace falta, para cada conjunto de órbitas cuyos grupos
regulares comparten algún cociente no trivial (no solo las isomorfas entre sí), enumerar los
subgrupos del producto de esos grupos que se sobreyectan en cada factor, salvo la simetría de
permutar bloques compatibles. Esto es un problema combinatorio genuinamente más profundo de lo
que asumí al plantear la tarea — no es un bug de implementación, es que mi plan matemático
estaba incompleto.

**Ejecutar.** No se hizo ningún cambio a `bc_structure.g` ni a `BurnsideC.jl` (correcto, según
lo pedido). El único archivo nuevo es el script de diagnóstico con el contraejemplo, que se
queda en `task-sn-enum/`, sin fusionar (no aporta capacidad nueva, solo evidencia del problema).

**Decisión — pendiente, se la paso al usuario.** Hay tres caminos con costo/riesgo muy distinto:
1. Comprobar primero si GAP ya tiene los datos precalculados (paquete `TomLib`, tablas de
   marcas) para `S_9`/`S_10` — barato de verificar, evita todo el problema de Goursat si ya
   existe la tabla.
2. Rediseñar la clasificación correctamente (productos subdirectos vía Goursat) — matemáticamente
   más satisfactorio, pero es un proyecto real, no una tarea de una tarde, y con riesgo de
   encontrar más sutilezas.
3. Dejarlo así: el cuello de botella de GAP para `S_9`/`S_10`+ queda como limitación conocida
   (ya documentada en `guia/04_el_codigo.md` §8), sin más inversión por ahora.

Preguntado al usuario en el chat el 2026-09-23.

**Respuesta del usuario**: hacer las dos cosas — primero verificar TomLib, y si hace falta,
recién ahí rediseñar.

---

### 2026-09-23 — Investigación propia: TomLib resuelve el problema sin necesidad de Goursat

**Investigar** (hecho por mí directamente, sin delegar — era una comprobación rápida).
`TestPackageAvailability("tomlib")` y `LoadPackage("tomlib")` → ambos `true`: el paquete ya
está instalado con OSCAR. `TableOfMarks("Sn")` funciona instantáneamente para `n=4..11`
(no para `n=3`, sin importancia — ahí el método viejo ya es trivial). Cada tabla trae:

- `UnderlyingGroup(tom)`: el propio `S_n` concreto (grupo de permutaciones real).
- `RepresentativeTom(tom, i)`: un **subgrupo concreto** (con generadores reales) para cada una
  de las clases de conjugación de *todos* los subgrupos de `S_n` — no solo datos abstractos.

Medido: filtrar las clases abelianas (recorrer todas las clases y comprobar `IsAbelian`) tarda
`S_9`: 0.01s, `S_10`: 0.02s, `S_11`: 0.1s — donde el método viejo (`ConjugacyClassesSubgroups`)
tardaba 51s en `S_9` y no terminaba en `S_10` en 10 minutos. Esto es una mejora de varios
órdenes de magnitud, **y de paso resuelve el problema de Goursat**: como GAP ya calculó
correctamente todas las clases de conjugación de subgrupos (incluidos los productos
subdirectos), no hace falta re-derivar esa clasificación a mano.

**Plan.** No hace falta el rediseño matemático difícil. Se delega a Codex una nueva tarea,
mucho mejor informada que la primera: conectar `TableOfMarks`/`RepresentativeTom` como fuente
de los `H` en `bc_structure.g`, manteniendo el resto del pipeline (Centralizer, Normalizer,
IntermediateSubgroups, Orbits) exactamente igual, con la misma disciplina de verificación
cruzada contra el método viejo para `S_4..S_8` antes de confiar en `S_9,S_10,S_11`.

Despachado como tarea B2, carpeta `/Users/juancagc/Groups/task-sn-tomlib`.
