# Diseño: Harness multi-agente para GdeS

**Fecha:** 2026-09-14
**Estado:** Aprobado por el usuario (diseño), pendiente de implementación

## 1. Propósito

GdesProject es un sistema de tres aplicaciones que funcionan como un todo:

- `mobile_app_gdes/` — app Expo/React Native para empleados (código existente, docs completas en `mobile_app_gdes/docs/`).
- `admin_web_app/` — web administrativa (sin código aún; spec funcional completa en `admin_web_app/docs/spec_definition.md`).
- `backend_api_gdes/` — backend que integra ambas (aún no definido).

Este documento define el **harness de orquestación multi-agente** que vive en el repositorio raíz `GdesProject/`. El repo raíz **no contiene código de producto**: solo orquestación, documentación compartida, configuraciones e instrucciones.

## 2. Principios (innegociables)

1. **Patrón Líder-Trabajador-Revisor**: el líder no implementa, el implementador no se autoaprueba, el revisor no edita código. La separación se **fuerza por herramienta** (frontmatter de agent files), no por convención.
2. **Estado en disco, no en chat**: `progress/<rol>/current.md` e `history.md` sobreviven a reinicios y a context windows agotadas.
3. **Anti teléfono-descompuesto**: los subagentes escriben resultados en archivos y devuelven solo una referencia ligera (path + status).
4. **Una sola feature a la vez por agente**: no se mezclan cambios de varias tareas en la misma sesión.
5. **La documentación es la fuente de verdad**: si algo no está en `docs/` (definiciones, specs, contratos, task specs), no se inventa — se frena y se consulta al humano. Lo mismo ante contradicciones entre documentos.
6. **Documentación durante el trabajo**: cada agente registra lo que hace *mientras* trabaja, no solo al final.
7. **Comunicación entre agentes siempre vía archivos `.md`** en `progress/` y `docs/tasks/`.

## 3. Mecanismo técnico

Se usa el soporte nativo de Kimi Code CLI:

- **Custom agents**: archivos Markdown con frontmatter en `.agents/agents/` (descubiertos a nivel proyecto porque `GdesProject/` tiene `.git`). El frontmatter permite restringir herramientas (`tools`, `disallowedTools`) y subagentes despachables (`subagents`).
- **Agente principal**: el leader se selecciona al iniciar la sesión con `kimi --agent leader`.
- **Skills**: archivos en `.agents/skills/`. El escaneo de skills es por cwd: como la sesión del harness corre desde `GdesProject/`, las skills de cada subproyecto (`.agents/skills/` dentro de cada subrepo) **no se escanean automáticamente**; el system prompt de cada implementer ordena leerlas explícitamente al iniciar una tarea.
- Los tres subproyectos son **repos git independientes** (tienen su propio `.git`). Todo el material del harness vive en el repo raíz; los subrepos solo reciben su directorio de skills y su `AGENTS.md` de contexto.

## 4. Estructura de archivos

```
GdesProject/
├── AGENTS.md                        # reglas globales del harness
├── README.md                        # cómo usar el harness (para el humano)
├── feature_list.json                # backlog con estados
├── docs/
│   ├── arquitectura/
│   │   ├── vision-sistema.md        # cómo encajan mobile + admin + backend
│   │   └── contratos-api.md         # contratos entre apps (fuente de verdad de integración)
│   ├── convenciones/
│   │   ├── convenciones-globales.md # idioma, formato de commits, estilo de docs
│   │   └── flujo-de-trabajo.md      # protocolo leader→implementer→reviewer detallado
│   ├── tasks/
│   │   └── TEMPLATE.md              # plantilla de spec de tarea
│   └── superpowers/specs/           # specs de diseño (como este documento)
├── progress/
│   ├── leader/    current.md + history.md
│   ├── reviewer/  current.md + history.md
│   ├── mobile/    current.md + history.md
│   ├── admin/     current.md + history.md
│   └── backend/   current.md + history.md
└── .agents/
    ├── agents/
    │   ├── leader.md
    │   ├── reviewer.md
    │   ├── implementer-mobile.md
    │   ├── implementer-admin.md
    │   └── implementer-backend.md
    └── skills/                      # skills comunes del sistema
```

En cada subrepo, además:

```
<subrepo>/
├── AGENTS.md            # contexto mínimo: rol de la app, dónde están sus docs, puntero al harness raíz
└── .agents/skills/      # skills específicas del stack de esa app
```

## 5. Agentes y restricciones

### 5.1 `leader` (main agent del repo raíz)

- **Rol**: planificar, descomponer features en tareas, escribir task specs, despachar implementers y reviewer, mantener `feature_list.json` y `progress/leader/`, consultar al humano ante vacíos/contradicciones.
- **Nunca escribe código.** Puede leer código y docs, escribir/modificar solo en `docs/`, `progress/`, `feature_list.json` y archivos del harness.
- **Tools**: `Read`, `Grep`, `Glob`, `Bash`, `Agent`, `TodoList`, `AskUserQuestion`, `WebSearch`, `FetchURL`. `Write`/`Edit` permitidos (la disciplina de no tocar código va en el system prompt; las rutas de producto están en subrepos separados, lo que refuerza el límite).
- **Subagentes**: `implementer-mobile`, `implementer-admin`, `implementer-backend`, `reviewer`, `explore`, `plan`.

### 5.2 `reviewer`

- **Rol**: revisar lo implementado por otros agentes. Verifica: criterios de aceptación del task spec, coherencia con `docs/` (definiciones y contratos), e **integración entre apps** (los contratos deben coincidir de forma directa). Puede aprobar, rechazar o pedir modificaciones con feedback accionable.
- **No edita código.** Registra veredictos en `progress/reviewer/current.md` y en la sección de review del task spec.
- **Tools**: `Read`, `Grep`, `Glob`, `Bash` (solo para ejecutar tests/checks/builds), `Write`/`Edit` limitadas por disciplina a `progress/reviewer/` y `docs/tasks/`. Sin `Agent` (no delega).
- **Subagentes**: ninguno.

### 5.3 `implementer-mobile`, `implementer-admin`, `implementer-backend`

- **Rol**: tomar una tarea del leader (vía task spec) e implementarla en su app. Una feature por sesión. Documentan en `progress/<app>/current.md` mientras trabajan.
- **Tools**: set completo de coder (`Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `TodoList`, `Skill`, `WebSearch`, `FetchURL`).
- **Subagentes**: ninguno.
- Su system prompt incluye: ruta de su app, rutas de sus docs, orden de leer sus skills en `<subrepo>/.agents/skills/` al iniciar, formato del registro de progreso, y la regla de devolver solo una referencia ligera al leader.
- `implementer-backend` se crea ya, pero su especialización queda mínima (stack a definir) hasta que el humano defina el backend.

## 6. Protocolo de trabajo (ciclo de una feature)

Detallado en `docs/convenciones/flujo-de-trabajo.md`:

1. **Leader**: toma la feature de `feature_list.json` → escribe/actualiza el spec en `docs/tasks/NNN-slug.md` (contexto, alcance, criterios de aceptación, archivos de referencia) → marca `in_progress` → despacha al `implementer-<app>` con prompt que apunta al spec y a los docs relevantes.
2. **Implementer**: trabaja una sola feature. Appendea a `progress/<app>/current.md` mientras trabaja (qué hizo, qué está haciendo, blockers). Al terminar, deja en `current.md` un resumen estructurado (archivos tocados, decisiones, cómo verificar) y devuelve al leader solo `{ path al registro, status }`.
3. **Leader** despacha al **reviewer**, que valida contra el task spec, las docs y los contratos de integración. Escribe el veredicto en `progress/reviewer/current.md` y en la sección "Review" del task spec: **aprobado** o **cambios requeridos** (lista accionable).
4. Si hay cambios requeridos → el leader re-despacha al implementer con el feedback del reviewer (loop hasta aprobar). Si aprueba → el leader marca `done` en `feature_list.json`, mueve `current.md` → entrada en `history.md` (en los roles involucrados), y actualiza las docs si cambiaron convenciones o contratos.
5. **Vacíos o contradicciones** en docs/specs/contratos → el agente frena y el leader consulta al humano. Prohibido inventar.
6. **Preguntas conceptuales o de exploración (lectura pura)**: el leader responde directamente, sin lanzar subagentes.

## 7. Formatos

### 7.1 `feature_list.json`

```json
{
  "features": [
    {
      "id": "F-001",
      "titulo": "string",
      "descripcion": "string",
      "apps": ["mobile" | "admin" | "backend"],
      "estado": "pending" | "in_progress" | "done",
      "criterios_aceptacion": ["..."],
      "task_doc": "docs/tasks/001-slug.md",
      "bloqueos": []
    }
  ]
}
```

### 7.2 `progress/<rol>/current.md`

Estado vivo de la tarea en curso:

```markdown
# Current — <rol>
## Tarea activa: <id-feature> — <título> (o "ninguna")
## Haciendo ahora
- ...
## Hecho (esta sesión)
- ...
## Blockers / Preguntas para el humano
- ...
## Resultado final (al cerrar)
- Archivos tocados, decisiones, cómo verificar, status
```

### 7.3 `progress/<rol>/history.md`

Append-only. Una entrada por tarea cerrada: fecha, id de feature, qué se hizo, veredicto del reviewer, links a task spec.

### 7.4 `docs/tasks/NNN-slug.md`

Generado desde `docs/tasks/TEMPLATE.md`. Secciones: contexto, alcance (in/out), archivos de referencia (docs + código), criterios de aceptación, notas de implementación, registro de progreso (resumen del implementer) y **sección Review** (veredictos del reviewer, con rondas si hubo rechazos).

## 8. Skills

Se investigan fuentes públicas y se instalan durante la implementación (el usuario optó por descargar skills existentes en vez de crearlas desde cero).

- **Raíz** `.agents/skills/`: `find-skills` + skills comunes del sistema.
- **mobile_app_gdes/.agents/skills/**: skill(s) de React Native/Expo (objetivo: `vercel-react-native-skills`).
- **admin_web_app/.agents/skills/**: `react-best-practices` (ya disponible en el plugin de Vercel instalado a nivel usuario; se copia o referencia), `web-design-guidelines` y afines.
- **backend_api_gdes/.agents/skills/**: directorio preparado con README placeholder; se completa cuando se defina el stack del backend.
- Cada `implementer-*` tiene en su system prompt la orden de leer las skills de su app antes de implementar (el escaneo automático no las alcanza desde la sesión raíz).
- La lista final de skills por subproyecto se acuerda con el usuario durante la implementación.

## 9. Documentación de arquitectura y convenciones

- `docs/arquitectura/vision-sistema.md`: nace de lo ya documentado (`mobile_app_gdes/docs/`, `admin_web_app/docs/spec_definition.md`). Describe el sistema completo y el rol de cada app.
- `docs/arquitectura/contratos-api.md`: contratos entre apps. Lo que ya existe tipado en mobile (`types/api.ts`, `types/document.ts`) y en la Parte 8 del spec de admin se releva; lo que depende del backend queda explícitamente marcado como **"a definir con el humano"** — no se inventa.
- `docs/convenciones/convenciones-globales.md`: idioma de documentación (español), formato de commits, estilo de docs, convenciones de nombres de task specs.
- `docs/convenciones/flujo-de-trabajo.md`: el protocolo de la sección 6 en forma operativa, con plantillas de prompt para despachar implementers y reviewer.

## 10. Qué NO hace este harness (alcance)

- No escribe código de producto.
- No define el stack del backend (pendiente del humano).
- No modifica los repos de las apps más allá de agregar `AGENTS.md` y `.agents/skills/` en cada uno.
- No automatiza git (commits/push) — cada mutación git requiere confirmación del usuario.

## 11. Verificación del harness

- `kimi --agent leader` arranca con el leader como main agent y su allowlist de subagentes.
- El leader no puede despachar tipos fuera de su allowlist; el reviewer no puede editar código (validado con una tarea de prueba trivial).
- Una feature de prueba end-to-end (task spec → implementación mínima → review → `done`) demuestra el ciclo completo.
