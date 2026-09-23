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
| A | Certificado de forma normal de Smith (`U·A·V=D` verificable independientemente) | `/Users/juancagc/Groups/task-snf` | `task-mudnvhcd-gux4fe` | en curso |
| B | Enumerador de subgrupos abelianos de `S_n` (evitar el cuello de botella de `ConjugacyClassesSubgroups` en GAP) | `/Users/juancagc/Groups/task-sn-enum` | `task-mudnvzp3-zjac5n` | en curso |
| C | Exploración de `BC_n(AGL(1,p))`, buscando una fórmula nueva (no publicada) | `/Users/juancagc/Groups/task-agl1p` | `task-mudnx60e-fak29n` | en curso |

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

<!-- Las siguientes entradas se añaden cuando cada tarea reporte un resultado real. -->
