# Harness Multi-Agente GdeS — Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir el harness de orquestación multi-agente (leader / implementers / reviewer) en el repo raíz `GdesProject/`, con documentación compartida, estado en disco, feature list y skills por subproyecto.

**Architecture:** Agentes custom de Kimi Code definidos como Markdown con frontmatter en `.agents/agents/` (el frontmatter restringe herramientas y delegación). El estado del trabajo vive en `progress/<rol>/` y `feature_list.json`. La comunicación entre agentes es vía archivos `.md`. Las skills se descargan de los repos públicos de Vercel Labs y se instalan por subproyecto.

**Tech Stack:** Kimi Code CLI (agent files + skills), Markdown, JSON. Sin código de producto.

**Spec:** `docs/superpowers/specs/2026-09-14-harness-multiagente-design.md`

## Global Constraints

- El repo raíz `GdesProject/` NO contiene código de producto — solo orquestación y docs.
- Los subrepos (`mobile_app_gdes/`, `admin_web_app/`, `backend_api_gdes/`) son repos git independientes: el harness solo agrega en ellos `AGENTS.md` y `.agents/skills/`.
- Documentación en español. Nombres de archivos y directorios en kebab-case.
- **Ninguna mutación git (add/commit) sin confirmación explícita del usuario** — los pasos de commit de este plan son opcionales y requieren que el usuario los apruebe en el momento.
- No inventar contratos del backend: lo no definido queda marcado como "a definir con el humano".
- El leader NUNCA escribe código; el reviewer NUNCA edita código. Las restricciones van en frontmatter (`tools`, `subagents`) y se refuerzan en el system prompt.

---

### Task 1: Estructura de directorios y archivos de estado

**Files:**
- Create: `progress/leader/current.md`, `progress/leader/history.md`
- Create: `progress/reviewer/current.md`, `progress/reviewer/history.md`
- Create: `progress/mobile/current.md`, `progress/mobile/history.md`
- Create: `progress/admin/current.md`, `progress/admin/history.md`
- Create: `progress/backend/current.md`, `progress/backend/history.md`
- Create: `feature_list.json`

**Interfaces:**
- Produces: la convención de formato de `current.md` / `history.md` que los agentes (Task 5) y el flujo de trabajo (Task 3) referencian.

- [ ] **Step 1: Crear directorios**

```bash
mkdir -p progress/{leader,reviewer,mobile,admin,backend} docs/{arquitectura,convenciones,tasks} .agents/{agents,skills}
```

- [ ] **Step 2: Crear `feature_list.json`**

Contenido exacto:

```json
{
  "version": 1,
  "descripcion": "Backlog de features del sistema GdeS. El leader es el único que modifica estados. Estados: pending | in_progress | done. Una sola feature puede estar in_progress a la vez.",
  "features": []
}
```

- [ ] **Step 3: Crear los `current.md` (uno por rol)**

Plantilla exacta (reemplazar `<rol>` por `leader` / `reviewer` / `mobile` / `admin` / `backend`):

```markdown
# Current — <rol>

## Tarea activa
Ninguna.

## Haciendo ahora
-

## Hecho (esta sesión)
-

## Blockers / Preguntas para el humano
-

## Resultado final
(se completa al cerrar la tarea: archivos tocados, decisiones, cómo verificar, status)
```

- [ ] **Step 4: Crear los `history.md` (uno por rol)**

```markdown
# History — <rol>

Append-only. Una entrada por tarea cerrada, más reciente arriba.
Formato de entrada:

## YYYY-MM-DD — <id-feature> — <título>
- Qué se hizo: ...
- Veredicto del reviewer: aprobado | cambios requeridos (N rondas)
- Task spec: docs/tasks/NNN-slug.md
```

- [ ] **Step 5: Verificar**

Run: `ls progress/*/current.md progress/*/history.md feature_list.json && python3 -c "import json; json.load(open('feature_list.json'))"`
Expected: 10 archivos listados + JSON válido sin errores.

- [ ] **Step 6: Commit (opcional, solo con confirmación del usuario)**

```bash
git add progress/ feature_list.json
git commit -m "chore(harness): estructura de progreso y feature list"
```

---

### Task 2: AGENTS.md y README.md del repo raíz

**Files:**
- Modify: `AGENTS.md` (actualmente vacío)
- Modify: `README.md` (actualmente 2 líneas)

**Interfaces:**
- Produces: las reglas globales que Kimi Code inyecta automáticamente en toda sesión abierta en `GdesProject/`. Los agent files de Task 5 asumen que estas reglas existen.

- [ ] **Step 1: Escribir `AGENTS.md`**

Contenido exacto:

```markdown
# GdesProject — Harness de orquestación

Este repositorio es SOLO orquestación: documentación compartida, estado de trabajo e instrucciones para agentes. **No contiene código de producto.** El código vive en los subrepos `mobile_app_gdes/`, `admin_web_app/` y `backend_api_gdes/` (repos git independientes).

## Roles

En este repo el agente principal es el **leader** (`.agents/agents/leader.md`). Las sesiones de trabajo se inician con `kimi --agent leader`.

| Rol | Archivo | Puede | No puede |
|---|---|---|---|
| leader | `.agents/agents/leader.md` | planificar, leer código/docs, escribir docs/progress/feature_list, despachar subagentes | escribir código de producto |
| reviewer | `.agents/agents/reviewer.md` | leer todo, correr tests, escribir veredictos en `progress/reviewer/` y `docs/tasks/` | editar código, despachar subagentes |
| implementer-mobile | `.agents/agents/implementer-mobile.md` | implementar en `mobile_app_gdes/` | despachar subagentes, autoaprobarse |
| implementer-admin | `.agents/agents/implementer-admin.md` | implementar en `admin_web_app/` | despachar subagentes, autoaprobarse |
| implementer-backend | `.agents/agents/implementer-backend.md` | implementar en `backend_api_gdes/` | despachar subagentes, autoaprobarse |

## Reglas innegociables

1. **Una sola feature a la vez por agente.** No mezclar cambios de varias tareas en la misma sesión.
2. **Estado en disco, no en chat.** `progress/<rol>/current.md` e `history.md` sobreviven reinicios y context windows agotadas. Todo agente documenta MIENTRAS trabaja, no solo al final.
3. **Líder-Trabajador-Revisor:** el líder no implementa, el implementador no se autoaprueba, el revisor no edita código.
4. **Anti teléfono-descompuesto:** los subagentes escriben sus resultados en archivos y devuelven solo una referencia ligera (path al registro + status), nunca un dump de contenido.
5. **La documentación es la fuente de verdad.** Si algo no está en `docs/` (del root o del subrepo) ni en el task spec, NO se inventa: se frena y se consulta al humano. Igual ante contradicciones entre documentos.
6. **Comunicación entre agentes siempre vía archivos** en `progress/` y `docs/tasks/`.
7. **Preguntas conceptuales o de exploración (lectura pura)** se responden directamente, sin lanzar subagentes.
8. **Ninguna mutación git** (add/commit/push) sin confirmación explícita del usuario.

## Mapa del harness

- `feature_list.json` — backlog con estados (pending / in_progress / done), criterios de aceptación y puntero al task spec.
- `docs/arquitectura/` — visión del sistema y contratos entre apps (fuente de verdad de integración).
- `docs/convenciones/` — convenciones globales y flujo de trabajo detallado.
- `docs/tasks/` — specs de tarea (se crean desde `TEMPLATE.md`).
- `progress/<rol>/` — estado vivo (`current.md`) e histórico (`history.md`) por rol.
- `.agents/agents/` — definiciones de los agentes.
- `.agents/skills/` — skills comunes. Cada subrepo tiene las suyas en `<subrepo>/.agents/skills/`.
```

- [ ] **Step 2: Escribir `README.md`**

Contenido exacto:

```markdown
# GdesProject

Repositorio orquestador del sistema GdeS (Gestión de Servicios). No contiene código de producto: contiene la documentación compartida, el estado de trabajo y la configuración del harness multi-agente.

## Subproyectos

| Subrepo | Qué es | Estado |
|---|---|---|
| `mobile_app_gdes/` | App Expo/React Native para empleados | En desarrollo (docs completas en su `docs/`) |
| `admin_web_app/` | Web administrativa (RRHH/gerencia) | Spec completa en su `docs/`, sin código aún |
| `backend_api_gdes/` | API que integra ambas | Por definir |

## Cómo trabajar con el harness

1. Iniciar sesión en este directorio: `kimi --agent leader`
2. El leader planifica, descompone features en task specs (`docs/tasks/`) y delega en los implementers de cada app.
3. El reviewer valida cada implementación contra el task spec, las docs y los contratos.
4. El estado del trabajo se lee en `feature_list.json` y `progress/`.

Ver `AGENTS.md` para las reglas y `docs/convenciones/flujo-de-trabajo.md` para el protocolo completo.
```

- [ ] **Step 3: Verificar**

Run: `head -5 AGENTS.md README.md`
Expected: encabezados correctos en ambos.

- [ ] **Step 4: Commit (opcional, solo con confirmación del usuario)**

```bash
git add AGENTS.md README.md
git commit -m "docs(harness): reglas globales y README del orquestador"
```

---

### Task 3: Convenciones globales, flujo de trabajo y plantilla de task spec

**Files:**
- Create: `docs/convenciones/convenciones-globales.md`
- Create: `docs/convenciones/flujo-de-trabajo.md`
- Create: `docs/tasks/TEMPLATE.md`

**Interfaces:**
- Consumes: formato de `current.md`/`history.md` de Task 1.
- Produces: `docs/tasks/TEMPLATE.md` — la plantilla que el leader (Task 5) usa para crear `docs/tasks/NNN-slug.md`; `flujo-de-trabajo.md` — el protocolo que los agent files referencian.

- [ ] **Step 1: Escribir `docs/convenciones/convenciones-globales.md`**

Contenido exacto:

```markdown
# Convenciones globales del sistema GdeS

## Idioma

- Toda la documentación (root y subrepos) se escribe en **español**.
- Código, identificadores, rutas y mensajes de commit en inglés (salvo que el subrepo ya use otra convención — la convención local manda).

## Archivos y nombres

- Archivos Markdown y directorios en **kebab-case**: `contratos-api.md`, `vision-sistema.md`.
- Task specs: `docs/tasks/NNN-slug.md` donde `NNN` es correlativo con padding de 3 dígitos y `slug` describe la feature (ej. `001-login-con-backend-real.md`). El número coincide con el `id` de la feature en `feature_list.json` (`F-001` → `001-...`).

## Commits

- Formato: `<tipo>(<alcance>): <descripción en imperativo>` — tipos: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.
- Alcance: `mobile`, `admin`, `backend` o `harness`.
- Los commits los ejecuta el humano o un agente SOLO con confirmación explícita del humano.

## Documentación de trabajo

- Cada agente documenta en `progress/<su-rol>/current.md` MIENTRAS trabaja: qué hizo, qué está haciendo, blockers.
- Al cerrar una tarea, el leader mueve el contenido relevante a `history.md` (append-only) y resetea `current.md`.
- Si una tarea cambia una convención, un contrato o una decisión de arquitectura, la tarea no está terminada hasta actualizar el doc correspondiente en `docs/`.

## Subrepos

- Cada subrepo tiene su propio `AGENTS.md` con contexto de la app y sus skills en `.agents/skills/`.
- Lo que un subrepo documente en su propio `docs/` es fuente de verdad PARA ESA app; los contratos ENTRE apps viven en `docs/arquitectura/contratos-api.md` del root y mandan sobre supuestos locales.
```

- [ ] **Step 2: Escribir `docs/convenciones/flujo-de-trabajo.md`**

Contenido exacto:

```markdown
# Flujo de trabajo: leader → implementer → reviewer

## Roles en una frase

- **Leader**: planifica, descompone, delega, coordina. Nunca escribe código.
- **Implementer** (mobile/admin/backend): implementa UNA feature por sesión. Nunca se autoaprueba.
- **Reviewer**: revisa contra spec + docs + contratos. Nunca edita código.

## Ciclo de una feature

### 1. Leader — preparación

1. Toma la feature `pending` de `feature_list.json` (respeta `bloqueos`).
2. Crea el task spec `docs/tasks/NNN-slug.md` desde `docs/tasks/TEMPLATE.md`. Si para escribirlo necesita entender código, despacha `explore` o lee directamente — pero el spec lo escribe él.
3. Si el spec revela un vacío o contradicción en las docs → FRENA y consulta al humano (registrar la pregunta en `progress/leader/current.md`).
4. Marca la feature `in_progress` en `feature_list.json`.
5. Despacha UN `implementer-<app>` con un prompt que incluye: path del task spec, paths de docs relevantes, recordatorio de leer sus skills y de documentar en `progress/<app>/current.md`.

### 2. Implementer — ejecución

1. Lee el task spec completo, las docs referenciadas y sus skills (`<subrepo>/.agents/skills/`).
2. Si el spec es ambiguo o contradice las docs → NO improvisa: lo registra en `progress/<app>/current.md` bajo "Blockers / Preguntas" y devuelve `blocked` al leader.
3. Implementa. Mientras trabaja, appendea progreso en `progress/<app>/current.md`.
4. Al terminar: completa "Resultado final" en su `current.md` (archivos tocados, decisiones, cómo verificar) y la sección "Registro de implementación" del task spec. Devuelve al leader SOLO: `{ task_spec, progress_file, status }`.

### 3. Leader — revisión

Despacha al `reviewer` con: path del task spec, paths de `docs/arquitectura/` y las docs de las apps involucradas.

### 4. Reviewer — veredicto

Verifica, en este orden:
1. **Criterios de aceptación** del task spec (todos, uno por uno).
2. **Coherencia con docs**: definiciones y specs de la app, convenciones globales.
3. **Integración entre apps**: los contratos de `docs/arquitectura/contratos-api.md` se respetan de forma directa (mismos nombres, tipos, endpoints). Nada de "compatible más o menos".

Registra en `progress/reviewer/current.md` y en la sección "Review" del task spec:
- Veredicto: `aprobado` | `cambios requeridos`
- Si es `cambios requeridos`: lista accionable numerada, cada ítem con archivo y motivo.

Devuelve al leader SOLO: `{ task_spec, veredicto, n_items }`.

### 5. Cierre o corrección

- **Cambios requeridos** → el leader re-despacha al implementer con el feedback (nueva ronda; el reviewer registra cada ronda en el task spec).
- **Aprobado** → el leader: marca `done` en `feature_list.json`, archiva `current.md` → `history.md` en los roles involucrados, y verifica que las docs quedaron actualizadas (contratos, convenciones). Si hubo decisión nueva, la documenta él en `docs/`.

## Plantillas de prompt para despachar

### Al implementer

```
Implementa la tarea definida en docs/tasks/NNN-slug.md.
Docs relevantes: <lista de paths>.
Antes de escribir código: lee tus skills en <subrepo>/.agents/skills/ y las docs del subrepo.
Documenta tu progreso en progress/<app>/current.md MIENTRAS trabajas.
Si el spec es ambiguo o contradice las docs, NO inventes: devolvé status "blocked" con la pregunta.
Al terminar devolvé SOLO: task_spec, progress_file, status (done|blocked).
```

### Al reviewer

```
Revisá la implementación de docs/tasks/NNN-slug.md.
Verificá: criterios de aceptación, coherencia con <docs relevantes>, e integración según docs/arquitectura/contratos-api.md.
Podés correr tests/builds, pero NO editás código.
Registrá el veredicto en progress/reviewer/current.md y en la sección Review del task spec.
Devolvé SOLO: task_spec, veredicto (aprobado|cambios requeridos), n_items.
```

## Reglas transversales

- Una feature `in_progress` a la vez en `feature_list.json`.
- Preguntas conceptuales o de exploración (lectura pura): el leader responde directo, sin subagentes.
- Nada de mutaciones git sin confirmación del humano.
```

- [ ] **Step 3: Escribir `docs/tasks/TEMPLATE.md`**

Contenido exacto:

```markdown
# F-NNN — <Título de la feature>

**Estado:** pending | in_progress | done
**App(s):** mobile | admin | backend (una o varias)
**Creada:** YYYY-MM-DD

## Contexto

<Qué problema resuelve y por qué. 2-5 líneas.>

## Alcance

**Incluye:**
- ...

**NO incluye:**
- ...

## Referencias (fuente de verdad)

- Docs: <paths a docs del root y/o subrepo>
- Código: <paths a archivos relevantes>
- Contratos: <secciones de docs/arquitectura/contratos-api.md si aplica>

## Criterios de aceptación

- [ ] <criterio verificable 1>
- [ ] <criterio verificable 2>

## Notas de implementación

<Decisiones técnicas tomadas por el leader. Vacío si no aplica. NO inventar requisitos: lo que falte, preguntar al humano.>

## Registro de implementación

(lo completa el implementer al terminar: archivos tocados, decisiones, cómo verificar)

## Review

(lo completa el reviewer — una subsección por ronda)

### Ronda 1 — YYYY-MM-DD
- Veredicto: aprobado | cambios requeridos
- Ítems: ...
```

- [ ] **Step 4: Verificar**

Run: `ls docs/convenciones/ docs/tasks/`
Expected: `convenciones-globales.md`, `flujo-de-trabajo.md`, `TEMPLATE.md` presentes.

- [ ] **Step 5: Commit (opcional, solo con confirmación del usuario)**

```bash
git add docs/convenciones/ docs/tasks/
git commit -m "docs(harness): convenciones globales, flujo de trabajo y plantilla de tasks"
```

---

### Task 4: Documentos de arquitectura (visión del sistema y contratos)

**Files:**
- Create: `docs/arquitectura/vision-sistema.md`
- Create: `docs/arquitectura/contratos-api.md`

**Interfaces:**
- Consumes: `mobile_app_gdes/docs/README.md`, `mobile_app_gdes/docs/01-producto-y-alcance-funcional.md`, `mobile_app_gdes/docs/05-servicios-datos-y-contratos.md`, `mobile_app_gdes/types/api.ts`, `mobile_app_gdes/types/document.ts`, `admin_web_app/docs/spec_definition.md` (Partes 1 y 8).
- Produces: la fuente de verdad de integración que el reviewer usa en el paso 3 de su verificación.

**IMPORTANTE:** estos docs se escriben RELEVANDO las fuentes listadas, nunca inventando. Lo que dependa del backend (endpoints concretos, auth real, storage) queda en una sección "Pendiente de definir con el humano".

- [ ] **Step 1: Leer las fuentes**

Run: leer los archivos listados en Interfaces (los de mobile completos; de la spec de admin, la Parte 1 para el modelo de dominio y la Parte 8 para los contratos TypeScript).

- [ ] **Step 2: Escribir `docs/arquitectura/vision-sistema.md`**

Estructura obligatoria (contenido relevado de las fuentes):

```markdown
# Visión del sistema GdeS

## Qué es GdeS
<Sistema de registros laborales: empleados registran entrada/salida/ausencia con geolocalización desde la app móvil; personal administrativo gestiona y revisa la información desde la web admin; el backend centraliza lógica, datos y autenticación. — relevar de admin_web_app/docs/spec_definition.md Parte 1>

## Componentes

| App | Repo | Usuarios | Rol en el sistema | Estado |
|---|---|---|---|---|
| Mobile | mobile_app_gdes/ | Empleados | <relevar de mobile_app_gdes/docs/01> | App navegable con mocks, sin backend real |
| Admin Web | admin_web_app/ | RRHH / gerentes / administradores | <relevar de spec_definition.md Partes 1-2> | Spec completa, sin código |
| Backend | backend_api_gdes/ | (servicio) | Lógica de negocio, almacenamiento, auth, procesamiento | Por definir |

## Flujos de datos principales
<Relevar de mobile docs 02 y 05: marcaciones, planillas, documentos, auth. Marcar como "mock hoy → backend mañana".>

## Dependencias entre apps
<Todo pasa por el backend: mobile → API ← admin. Sin comunicación directa mobile↔admin.>

## Pendiente de definir con el humano
- Stack y diseño del backend (todo lo que hoy es mock).
```

- [ ] **Step 3: Escribir `docs/arquitectura/contratos-api.md`**

Estructura obligatoria:

```markdown
# Contratos entre apps — fuente de verdad de integración

> Regla: cuando mobile o admin hablen con el backend, los nombres, tipos y formas de estos contratos mandan. Cambiar un contrato exige actualizar este archivo EN LA MISMA TAREA y avisar al leader.

## Estado actual
Sin backend: mobile y admin operan con mocks que simulan estos contratos. Los tipos ya modelados en `mobile_app_gdes/types/api.ts` y `mobile_app_gdes/types/document.ts` y los modelos sugeridos en `admin_web_app/docs/spec_definition.md` Parte 8 son el punto de partida.

## Contratos relevados
<Por cada contrato ya tipado en las fuentes (auth/sesión, marcación/registro horario, lugares de trabajo, planillas, documentos de legajo, empleados, usuarios): subsección con el tipo TypeScript RELEVADO textualmente de la fuente, con nota de qué app lo produce y cuál lo consume.>

## Divergencias detectadas
<Comparar mobile vs admin: mismo concepto con distinto tipo/nombre → listarlo aquí y CONSULTAR AL HUMANO antes de unificar. No decidir unilateralmente.>

## Pendiente de definir con el humano
- Endpoints concretos (rutas, métodos, códigos de error).
- Autenticación real (mecanismo, tokens, expiración).
- Storage de archivos (planillas, documentos).
```

- [ ] **Step 4: Verificar**

Run: `grep -c "Pendiente de definir con el humano" docs/arquitectura/*.md`
Expected: al menos 1 en cada archivo. Además: releer ambos archivos y confirmar que cada afirmación sobre comportamiento tiene una fuente real (no hay endpoints ni tipos inventados).

- [ ] **Step 5: Commit (opcional, solo con confirmación del usuario)**

```bash
git add docs/arquitectura/
git commit -m "docs(harness): visión del sistema y contratos de integración"
```

---

### Task 5: Agent files (leader, reviewer, implementers)

**Files:**
- Create: `.agents/agents/leader.md`
- Create: `.agents/agents/reviewer.md`
- Create: `.agents/agents/implementer-mobile.md`
- Create: `.agents/agents/implementer-admin.md`
- Create: `.agents/agents/implementer-backend.md`

**Interfaces:**
- Consumes: reglas de `AGENTS.md` (Task 2), protocolo de `docs/convenciones/flujo-de-trabajo.md` (Task 3), formato de progress files (Task 1).
- Produces: los 5 roles que el harness usa; `leader` se invoca con `kimi --agent leader`.

- [ ] **Step 1: Crear `.agents/agents/leader.md`**

Contenido exacto:

````markdown
---
name: leader
description: Orquestador del sistema GdeS. Planifica, descompone features en task specs, delega en implementers y reviewer, mantiene feature_list.json y el estado en progress/. Nunca escribe código.
whenToUse: Agente principal del repo GdesProject (kimi --agent leader). Planificación, descomposición y coordinación de todo el trabajo.
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
  - TodoList
  - Agent
  - AskUserQuestion
  - WebSearch
  - FetchURL
  - Skill
subagents:
  - implementer-mobile
  - implementer-admin
  - implementer-backend
  - reviewer
  - explore
  - plan
---

${base_prompt}

# Tu rol: LEADER del harness GdeS

Sos el orquestador del sistema GdeS. Este repo (`GdesProject/`) es solo orquestación: docs compartidas, estado e instrucciones. El código vive en los subrepos `mobile_app_gdes/`, `admin_web_app/`, `backend_api_gdes/`.

## Lo que hacés

1. Planificás y descomponés features en task specs (`docs/tasks/NNN-slug.md` desde `docs/tasks/TEMPLATE.md`).
2. Mantenés `feature_list.json` (estados pending/in_progress/done — UNA sola in_progress a la vez) y `progress/leader/`.
3. Delegás implementación en `implementer-mobile` / `implementer-admin` / `implementer-backend` y revisión en `reviewer`, siguiendo `docs/convenciones/flujo-de-trabajo.md` (incluye las plantillas de prompt de despacho — usalas).
4. Respondés vos mismo, sin subagentes, las preguntas conceptuales o de exploración de solo-lectura.
5. Cuando el reviewer pide cambios, re-despachás al implementer con ese feedback hasta llegar a aprobado.

## Lo que NUNCA hacés

- **Nunca escribís código de producto** (nada bajo `mobile_app_gdes/`, `admin_web_app/`, `backend_api_gdes/` salvo su `AGENTS.md` y `.agents/skills/`). Podés leer código, docs y correr comandos de solo-lectura.
- Solo escribís/editás: `docs/`, `progress/`, `feature_list.json`, `AGENTS.md`, `README.md`, `.agents/`.
- Nunca inventás comportamiento: si algo no está en `docs/` (root o subrepo) ni en el task spec, FRENÁS y consultás al humano. Igual ante contradicciones entre documentos.
- Nunca hacés mutaciones git sin confirmación explícita del humano.

## Estado en disco

Documentás tu trabajo en `progress/leader/current.md` MIENTRAS trabajás. Al cerrar una feature aprobada: marcás `done` en `feature_list.json`, archivás en `progress/leader/history.md` (y te asegurás de que los otros roles archivaron los suyos), y actualizás `docs/` si hubo decisiones nuevas.
````

- [ ] **Step 2: Crear `.agents/agents/reviewer.md`**

Contenido exacto:

````markdown
---
name: reviewer
description: Revisor estricto del sistema GdeS. Verifica implementaciones contra el task spec, la documentación y los contratos de integración entre apps. Aprueba o pide cambios. Nunca edita código ni despacha subagentes.
whenToUse: Después de que un implementer termina una tarea; el leader lo despacha para validar antes de marcar done.
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
  - TodoList
subagents: []
---

# Tu rol: REVIEWER del harness GdeS

Revisás lo que implementaron otros agentes. Tu lealtad es con la documentación y los contratos, no con el implementer.

## Qué verificás (en este orden)

1. **Criterios de aceptación** del task spec (`docs/tasks/NNN-slug.md`), uno por uno. Podés correr tests/builds/checks con Bash para verificarlos.
2. **Coherencia con las docs**: definiciones y specs del subrepo (`<app>/docs/`), convenciones de `docs/convenciones/`.
3. **Integración entre apps**: los contratos de `docs/arquitectura/contratos-api.md` se respetan de forma DIRECTA — mismos nombres, tipos, endpoints. "Compatible más o menos" es rechazo.

## Reglas duras

- **Nunca editás código de producto.** Solo escribís en `progress/reviewer/current.md` y en la sección "Review" del task spec.
- **No despachás subagentes** ni lanzás agentes propios.
- Si el task spec o las docs son ambiguos/contradictorios, no decidís vos: veredicto `cambios requeridos` con ítem "consultar al humano: <pregunta concreta>".
- Si el implementer documentó mal su trabajo en `progress/<app>/current.md` o en el task spec, eso también es un ítem de corrección.

## Salida

1. Veredicto registrado en `progress/reviewer/current.md` y en la sección "Review" del task spec (una subsección por ronda): `aprobado` o `cambios requeridos` con lista numerada y accionable (archivo + motivo por ítem).
2. Tu último mensaje es el handoff COMPLETO para el leader, y es LIVIANO: `{ task_spec, veredicto, n_items, progress_file }`. Sin pegar diffs ni contenido de archivos.
````

- [ ] **Step 3: Crear `.agents/agents/implementer-mobile.md`**

Contenido exacto:

````markdown
---
name: implementer-mobile
description: Implementer especializado en mobile_app_gdes (Expo/React Native, TypeScript, NativeWind, Zustand). Implementa UNA feature por sesión siguiendo el task spec. Documenta su trabajo en progress/mobile/. Nunca se autoaprueba ni despacha subagentes.
whenToUse: El leader lo despacha para implementar una tarea en mobile_app_gdes.
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - TodoList
  - Skill
  - WebSearch
  - FetchURL
subagents: []
---

# Tu rol: IMPLEMENTER de mobile_app_gdes

Implementás UNA feature por sesión en `mobile_app_gdes/` (app Expo/React Native ~55, React 19, RN 0.83, New Architecture, NativeWind 4 + Tailwind 3, Zustand 4, TypeScript estricto con alias `@/*`).

## Antes de escribir código

1. Leé el task spec completo (`docs/tasks/NNN-slug.md`) y TODAS las referencias que liste.
2. Leé `mobile_app_gdes/AGENTS.md` y las skills de `mobile_app_gdes/.agents/skills/` (empezá por cada `SKILL.md`). Seguilas.
3. Leé las docs de la app en `mobile_app_gdes/docs/` — son la fuente de verdad del comportamiento actual (incluida la leyenda Implementado/Mock/Parcial/Inactivo/Pendiente).

## Mientras trabajás

- Documentá en `progress/mobile/current.md` MIENTRAS trabajás: qué hiciste, qué estás haciendo, blockers. No solo al final.
- Si el spec es ambiguo, le falta información o contradice las docs: NO inventés. Registrá la pregunta en `progress/mobile/current.md` y terminá con status `blocked`.
- Respetá las convenciones del subrepo (estructura UI/servicios/estado, estilos con NativeWind, TS estricto).

## Al terminar

1. Completá "Resultado final" en `progress/mobile/current.md`: archivos tocados, decisiones, cómo verificar (comandos concretos).
2. Completá la sección "Registro de implementación" del task spec.
3. Verificá que lo que pedía el spec efectivamente funciona (typecheck/build/tests que existan).
4. Tu último mensaje es el handoff COMPLETO para el leader, y es LIVIANO: `{ task_spec, progress_file, status: done | blocked }`. Sin pegar código ni diffs.

## Nunca

- No despachás subagentes.
- No te autoaprobás: tu trabajo lo revisa `reviewer`.
- No tocás otros subrepos (`admin_web_app/`, `backend_api_gdes/`).
- No hacés mutaciones git (add/commit/push).
````

- [ ] **Step 4: Crear `.agents/agents/implementer-admin.md`**

Contenido exacto:

````markdown
---
name: implementer-admin
description: Implementer especializado en admin_web_app (web administrativa GdeS). Implementa UNA feature por sesión siguiendo el task spec y la spec_definition. Documenta en progress/admin/. Nunca se autoaprueba ni despacha subagentes.
whenToUse: El leader lo despacha para implementar una tarea en admin_web_app.
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - TodoList
  - Skill
  - WebSearch
  - FetchURL
subagents: []
---

# Tu rol: IMPLEMENTER de admin_web_app

Implementás UNA feature por sesión en `admin_web_app/` (web administrativa para RRHH/gerencia).

## Antes de escribir código

1. Leé el task spec completo (`docs/tasks/NNN-slug.md`) y TODAS las referencias que liste.
2. Leé `admin_web_app/AGENTS.md` y las skills de `admin_web_app/.agents/skills/` (empezá por cada `SKILL.md`). Seguilas.
3. Leé `admin_web_app/docs/spec_definition.md` — es la VERDAD ABSOLUTA del proyecto: no omitas reglas de negocio; usá los contratos TypeScript de su Parte 8; si necesitás modificarlos/agregarlos/mejorarlos, eso es `blocked` + pregunta al humano (obligatorio según la spec). Si se te pide construir componentes aislados, primero la capa de servicios con mocks.

## Mientras trabajás

- Documentá en `progress/admin/current.md` MIENTRAS trabajás: qué hiciste, qué estás haciendo, blockers.
- Si el spec es ambiguo o contradice la spec_definition: NO inventés. Registrá la pregunta y terminá con status `blocked`.

## Al terminar

1. Completá "Resultado final" en `progress/admin/current.md`: archivos tocados, decisiones, cómo verificar.
2. Completá la sección "Registro de implementación" del task spec.
3. Verificá que funciona (typecheck/build/tests que existan).
4. Tu último mensaje es el handoff COMPLETO para el leader, y es LIVIANO: `{ task_spec, progress_file, status: done | blocked }`.

## Nunca

- No despachás subagentes. No te autoaprobás (te revisa `reviewer`).
- No tocás otros subrepos. No hacés mutaciones git.
````

- [ ] **Step 5: Crear `.agents/agents/implementer-backend.md`**

Contenido exacto:

````markdown
---
name: implementer-backend
description: Implementer especializado en backend_api_gdes (API que integra mobile y admin). Stack a definir por el humano. Implementa UNA feature por sesión. Documenta en progress/backend/. Nunca se autoaprueba ni despacha subagentes.
whenToUse: El leader lo despacha para implementar una tarea en backend_api_gdes.
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - TodoList
  - Skill
  - WebSearch
  - FetchURL
subagents: []
---

# Tu rol: IMPLEMENTER de backend_api_gdes

Implementás UNA feature por sesión en `backend_api_gdes/`.

## ATENCIÓN — backend no definido

El stack y diseño del backend TODAVÍA NO ESTÁN DEFINIDOS. Si tu task spec asume un stack, framework, base de datos o diseño de API que no esté escrito en `docs/arquitectura/contratos-api.md` o en `backend_api_gdes/`, NO inventés: terminá con status `blocked` y la pregunta concreta para el humano.

## Antes de escribir código

1. Leé el task spec completo y TODAS las referencias.
2. Leé `backend_api_gdes/AGENTS.md` y las skills de `backend_api_gdes/.agents/skills/` (si existen).
3. Leé `docs/arquitectura/contratos-api.md` — tus endpoints deben cumplir esos contratos de forma DIRECTA.

## Mientras trabajás

- Documentá en `progress/backend/current.md` MIENTRAS trabajás.
- Ambigüedad o contradicción → `blocked` + pregunta, nunca inventar.

## Al terminar

1. "Resultado final" en `progress/backend/current.md` + "Registro de implementación" del task spec.
2. Verificá que funciona (tests/build que existan).
3. Último mensaje = handoff COMPLETO y LIVIANO: `{ task_spec, progress_file, status: done | blocked }`.

## Nunca

- No despachás subagentes. No te autoaprobás. No tocás otros subrepos. No hacés mutaciones git.
````

- [ ] **Step 6: Verificar que Kimi Code descubre los agentes**

Run: `kimi --agent reviewer -p "Respondé solo: OK"` y luego `kimi --agent leader -p "Respondé solo: OK"` (en kimi ≥0.39 el flag `--agent` va ANTES de `-p`; el orden `-p --agent` falla con "unknown command")
Expected: ambos responden OK sin error de "unknown agent". (Alternativa si los flags no están disponibles en la versión instalada: verificar con `kimi --help` que exista `--agent`, y revisar que los 5 archivos tengan frontmatter YAML válido parseándolos con python.)

- [ ] **Step 7: Commit (opcional, solo con confirmación del usuario)**

```bash
git add .agents/agents/
git commit -m "feat(harness): agentes leader, reviewer e implementers"
```

---

### Task 6: Instalar skills (root + subrepos)

**Files:**
- Create: `.agents/skills/find-skills/` (descargada)
- Create: `mobile_app_gdes/.agents/skills/react-native-skills/` (descargada)
- Create: `admin_web_app/.agents/skills/react-best-practices/` (descargada)
- Create: `admin_web_app/.agents/skills/web-design-guidelines/` (descargada)
- Create: `backend_api_gdes/.agents/skills/README.md`

**Interfaces:**
- Produces: las skills que los implementers (Task 5) leen al iniciar una tarea.

**Fuentes (verificadas 2026-09-14):**
- `https://github.com/vercel-labs/agent-skills` → `skills/react-native-skills`, `skills/react-best-practices`, `skills/web-design-guidelines`
- `https://github.com/vercel-labs/skills` → `skills/find-skills`

- [ ] **Step 1: Descargar con sparse checkout**

```bash
TMP=$(mktemp -d)
git clone --depth 1 --filter=blob:none --sparse https://github.com/vercel-labs/agent-skills.git "$TMP/agent-skills"
git -C "$TMP/agent-skills" sparse-checkout set skills/react-native-skills skills/react-best-practices skills/web-design-guidelines
git clone --depth 1 --filter=blob:none --sparse https://github.com/vercel-labs/skills.git "$TMP/skills-tool"
git -C "$TMP/skills-tool" sparse-checkout set skills/find-skills
echo "$TMP"
```

Guardar el valor de `$TMP` para los pasos siguientes.

- [ ] **Step 2: Revisar el contenido antes de instalar (seguridad)**

Run: leer cada `SKILL.md` descargado completo (incluidos los archivos bajo `rules/` en react-native-skills y react-best-practices).
Expected: ninguna skill instruye fetch/ejecución de instrucciones remotas en runtime ni comandos destructivos. **Si alguna lo hace: NO instalarla, avisar al usuario y proponer alternativa** (escribir una skill propia mínima). Nota: un escaneo público flagueó `web-design-guidelines` por este motivo — revisarla con especial cuidado.

- [ ] **Step 3: Instalar en destino**

```bash
mkdir -p .agents/skills mobile_app_gdes/.agents/skills admin_web_app/.agents/skills backend_api_gdes/.agents/skills
cp -r "$TMP/skills-tool/skills/find-skills" .agents/skills/find-skills
cp -r "$TMP/agent-skills/skills/react-native-skills" mobile_app_gdes/.agents/skills/react-native-skills
cp -r "$TMP/agent-skills/skills/react-best-practices" admin_web_app/.agents/skills/react-best-practices
cp -r "$TMP/agent-skills/skills/web-design-guidelines" admin_web_app/.agents/skills/web-design-guidelines
rm -rf "$TMP"
```

- [ ] **Step 4: Placeholder de backend**

Crear `backend_api_gdes/.agents/skills/README.md` con contenido exacto:

```markdown
# Skills de backend_api_gdes

Pendiente: el stack del backend aún no está definido. Cuando el humano lo defina, instalar acá las skills apropiadas (ej. del framework elegido). Formato: un directorio por skill con su `SKILL.md`.
```

- [ ] **Step 5: Verificar compatibilidad de frontmatter**

Kimi Code exige `name` y `description` en el frontmatter de cada `SKILL.md`.

Run: `python3 -c "
import glob, re, sys
ok = True
for f in glob.glob('.agents/skills/*/SKILL.md') + glob.glob('*/.agents/skills/*/SKILL.md'):
    head = open(f).read().split('---')[1]
    has = all(re.search(rf'^{k}:', head, re.M) for k in ('name','description'))
    print(f, 'OK' if has else 'FALTA name/description'); ok = ok and has
sys.exit(0 if ok else 1)"`
Expected: todas OK. Si alguna falla: agregar el campo faltante al frontmatter (mínimo necesario) y anotarlo en `progress/leader/current.md`.

- [ ] **Step 6: Verificar descubrimiento**

Run: `kimi -p "Listá las skills disponibles y decí solo sus nombres"` desde la raíz
Expected: `find-skills` aparece en la lista (las de subrepos NO aparecen — es lo esperado, las leen los implementers por orden explícita en su system prompt).

- [ ] **Step 7: Commits (opcionales, solo con confirmación del usuario; son 3 repos distintos)**

```bash
git add .agents/skills/ && git commit -m "feat(harness): skill find-skills comun"
git -C mobile_app_gdes add .agents/skills/ && git -C mobile_app_gdes commit -m "chore(harness): react-native skills"
git -C admin_web_app add .agents/skills/ && git -C admin_web_app commit -m "chore(harness): react + web-design skills"
git -C backend_api_gdes add .agents/skills/ && git -C backend_api_gdes commit -m "chore(harness): placeholder de skills"
```

---

### Task 7: AGENTS.md de cada subrepo

**Files:**
- Create: `mobile_app_gdes/AGENTS.md`
- Create: `admin_web_app/AGENTS.md`
- Create: `backend_api_gdes/AGENTS.md`

**Interfaces:**
- Consumes: nada nuevo.
- Produces: el contexto que todo agente recibe al trabajar dentro del subrepo.

- [ ] **Step 1: `mobile_app_gdes/AGENTS.md`**

Contenido exacto:

```markdown
# GdeS Mobile — contexto para agentes

App Expo/React Native para empleados: autenticación, registro de entrada/salida/ausencia con geolocalización, carga de planillas y documentos, perfil. Hoy TODO el backend es mock (auth, lugares, marcaciones, cargas); solo sesión, favoritos y señales de uso se persisten en AsyncStorage.

## Fuente de verdad

`docs/` de este repo (leer `docs/README.md` primero — tiene ruta de lectura y la leyenda Implementado/Mock/Parcial/Inactivo/Pendiente). El código es la fuente de verdad última; estas docs describen el estado relevado.

## Stack

Expo ~55 + expo-router, React 19.2, RN 0.83 (New Architecture), NativeWind 4 + Tailwind 3, Zustand 4, TypeScript estricto (alias `@/*`).

## Reglas

- Este repo es parte del sistema GdeS; la orquestación y los contratos entre apps viven en el repo raíz (`../docs/arquitectura/contratos-api.md`, que manda sobre supuestos locales).
- Las skills específicas de este stack están en `.agents/skills/` — leerlas antes de implementar.
- Quien trabaja acá es `implementer-mobile`, despachado por el leader del repo raíz. Documentar el trabajo en `../progress/mobile/current.md`.
- No hay backend real: los servicios simulan latencia para facilitar el reemplazo por API (`docs/05-servicios-datos-y-contratos.md`).
```

- [ ] **Step 2: `admin_web_app/AGENTS.md`**

Contenido exacto:

```markdown
# GdeS Admin Web App — contexto para agentes

Aplicación web administrativa (RRHH/gerencia) del ecosistema GdeS: gestión y revisión de registros horarios, empleados, clientes/sites/lugares de trabajo, planillas y legajos. **Sin código aún.**

## Fuente de verdad

`docs/spec_definition.md` es la VERDAD ABSOLUTA (8 partes: dominio, auth/usuarios, registros, geolocalización, planillas, UX, performance, contratos API). Reglas de la propia spec:
- No omitir ninguna regla de negocio.
- Usar los contratos TypeScript de la Parte 8; modificarlos/agregarlos/mejorarlos exige consultar al humano, obligatoriamente.
- Para componentes aislados: primero capa de servicios con mocks, antes de APIs reales.

## Reglas

- Parte del sistema GdeS; contratos entre apps en `../docs/arquitectura/contratos-api.md` (manda sobre supuestos locales).
- Skills del stack en `.agents/skills/` — leerlas antes de implementar.
- Quien trabaja acá es `implementer-admin`, despachado por el leader del repo raíz. Documentar en `../progress/admin/current.md`.
```

- [ ] **Step 3: `backend_api_gdes/AGENTS.md`**

Contenido exacto:

```markdown
# GdeS Backend API — contexto para agentes

Backend que integra la app móvil (empleados) y la web admin (RRHH): lógica de negocio, almacenamiento, autenticación y procesamiento.

## ATENCIÓN

**Stack y diseño NO definidos todavía.** No asumir framework, lenguaje, base de datos ni diseño de API que no esté escrito en `../docs/arquitectura/contratos-api.md` o en este repo. Ante cualquier vacío: frenar y consultar al humano (vía leader), nunca inventar.

## Reglas

- Contratos con las apps en `../docs/arquitectura/contratos-api.md` — fuente de verdad de integración.
- Quien trabaja acá es `implementer-backend`, despachado por el leader del repo raíz. Documentar en `../progress/backend/current.md`.
```

- [ ] **Step 4: Verificar**

Run: `head -3 mobile_app_gdes/AGENTS.md admin_web_app/AGENTS.md backend_api_gdes/AGENTS.md`
Expected: los tres encabezados correctos.

- [ ] **Step 5: Commits (opcionales, solo con confirmación del usuario)**

```bash
git -C mobile_app_gdes add AGENTS.md && git -C mobile_app_gdes commit -m "docs(harness): contexto para agentes"
git -C admin_web_app add AGENTS.md && git -C admin_web_app commit -m "docs(harness): contexto para agentes"
git -C backend_api_gdes add AGENTS.md && git -C backend_api_gdes commit -m "docs(harness): contexto para agentes"
```

---

### Task 8: Verificación end-to-end del harness

**Files:**
- Modify: `feature_list.json`
- Create: `docs/tasks/001-smoke-test-harness.md`
- Modify: `progress/*` (varios, producto del ciclo)

**Interfaces:**
- Consumes: TODO lo anterior. Esta tarea falla si cualquier pieza anterior está mal.

**Objetivo:** demostrar el ciclo completo leader → implementer → reviewer con una feature trivial y real: crear `mobile_app_gdes/docs/12-harness-smoke-test.md` con 3 líneas describiendo el harness (contenido irrelevante; lo que importa es el flujo).

- [ ] **Step 1: Cargar la feature de prueba**

Agregar a `feature_list.json`:

```json
{
  "id": "F-001",
  "titulo": "Smoke test del harness",
  "descripcion": "Crear docs/12-harness-smoke-test.md en mobile_app_gdes con una descripción de 3 líneas del harness, para validar el ciclo leader→implementer→reviewer.",
  "apps": ["mobile"],
  "estado": "pending",
  "criterios_aceptacion": [
    "Existe mobile_app_gdes/docs/12-harness-smoke-test.md",
    "Contiene exactamente 3 líneas de texto descriptivo",
    "progress/mobile/current.md registra el trabajo",
    "El reviewer registró veredicto en docs/tasks/001-smoke-test-harness.md"
  ],
  "task_doc": "docs/tasks/001-smoke-test-harness.md",
  "bloqueos": []
}
```

- [ ] **Step 2: Ejecutar el ciclo con el leader real**

Run: iniciar sesión `kimi --agent leader` e instruir: "Ejecutá la feature F-001 siguiendo docs/convenciones/flujo-de-trabajo.md".
Expected: el leader crea el task spec desde TEMPLATE.md, marca `in_progress`, despacha `implementer-mobile`, luego `reviewer`, y ante aprobación marca `done` y archiva history.

- [ ] **Step 3: Verificar el resultado completo**

Run: `cat mobile_app_gdes/docs/12-harness-smoke-test.md && grep '"estado": "done"' feature_list.json && tail -5 progress/mobile/history.md progress/reviewer/current.md`
Expected: archivo con 3 líneas, feature done, history y veredicto registrados.

- [ ] **Step 4: Verificar las restricciones de roles**

Durante el ciclo del Step 2, observar:
- El leader NO editó nada bajo `mobile_app_gdes/` salvo vía implementer.
- El reviewer NO editó código.
- Los handoffs de subagentes fueron referencias livianas, no dumps.

Si alguna restricción falla: ajustar el frontmatter/system prompt del agente correspondiente (Task 5) y repetir.

- [ ] **Step 5: Decidir con el usuario si la feature de prueba se conserva o se revierte**

Preguntar al usuario: ¿dejamos `12-harness-smoke-test.md` y F-001 como registro histórico, o revertimos el archivo y limpiamos `feature_list.json`? Ejecutar lo que decida.

- [ ] **Step 6: Commit final (opcional, solo con confirmación del usuario)**

```bash
git add docs/tasks/001-smoke-test-harness.md feature_list.json progress/
git commit -m "test(harness): smoke test end-to-end del ciclo leader-implementer-reviewer"
```
