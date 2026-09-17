# GdesProject — Template del harness y orquestación global

Este repo **ya no orquesta el trabajo operativo**. Contiene:

1. El **template del conocimiento común** (`template/`) que se propaga a los subrepos.
2. El agente **orchestrator** (`.agents/agents/orchestrator.md`), único agente de este repo (`kimi --agent orchestrator`).

El código y el trabajo operativo viven en los subrepos `mobile_app_gdes/`, `admin_web_app/` y `backend_api_gdes/` (repos git independientes y **autocontenidos**: cada uno tiene su propio `leader`, `reviewer`, `implementer-<app>`, `feature_list.json`, `progress/` y `docs/`).

## Roles

| Rol | Dónde vive | Puede | No puede |
|---|---|---|---|
| orchestrator | `GdesProject/.agents/agents/orchestrator.md` | mantener `template/`, propagar con `scripts/sync-template.sh`, procesar `changes_proposals/`, dejar instrucciones cross-app en `<repo>/progress/leader/inbox/` | escribir código de producto, crear task specs en subrepos (eso es del leader local) |
| leader | `<repo>/.agents/agents/leader.md` (SYNCED) | planificar, crear task specs, mantener `feature_list.json` y `progress/` de SU repo, despachar implementer y reviewer locales | escribir código, editar archivos SYNCED |
| reviewer | `<repo>/.agents/agents/reviewer.md` (SYNCED) | leer todo, correr tests, escribir veredictos en `progress/reviewer/` y en el task spec | editar código, despachar subagentes |
| implementer-\<app\> | `<repo>/.agents/agents/implementer-<app>.md` (SYNCED) | implementar UNA feature por sesión en su repo | despachar subagentes, autoaprobarse |

## Conocimiento común (SYNCED)

- Fuente única: `template/common/` (+ `template/apps/<app>/` para el implementer de cada app).
- Los archivos propagados llevan el encabezado `SYNCED-FROM-TEMPLATE` y son **de solo lectura** en los subrepos.
- Cambios: cualquier agente de un subrepo deja una propuesta en `<repo>/docs/changes_proposals/YYYYMMDD-slug.md`; el orchestrator la aplica en `template/` y propaga.
- Propagación: `scripts/sync-template.sh push` (aplica) y `scripts/sync-template.sh --check` (detecta deriva, exit 1 si la hay). En un push, los archivos del template **ganan** sobre modificaciones locales.

## Flujo cross-app

1. El humano le trae la iniciativa al **orchestrator** (`kimi --agent orchestrator` en este repo).
2. El orchestrator evalúa, actualiza contratos comunes si hace falta (template + sync) y deja instrucciones en `<repo>/progress/leader/inbox/` de cada repo involucrado.
3. El humano abre cada repo con `kimi --agent leader`; el leader local procesa su inbox y gestiona el ciclo leader → implementer → reviewer en su propio repo.

## Reglas innegociables

1. **Paralelismo coordinado**: por defecto una sola feature `in_progress` a la vez por repo; el leader local puede despachar varios implementers en paralelo si las tareas son independientes y bien acotadas (cada agente sigue haciendo UNA sola tarea; ver `docs/convenciones/flujo-de-trabajo.md` de cada repo).
2. **Estado en disco, no en chat.** Todo agente documenta en `progress/<rol>/current.md` MIENTRAS trabaja.
3. **Leader-orquestador-trabajador-revisor:** el orchestrator no implementa ni hace de leader local; el leader no implementa; el implementer no se autoaprueba; el reviewer no edita código.
4. **Anti teléfono-descompuesto:** los subagentes escriben resultados en archivos y devuelven solo una referencia ligera (path + status).
5. **La documentación es la fuente de verdad.** Si algo no está en `docs/` ni en el task spec, NO se inventa: se frena y se consulta al humano.
6. **Comunicación entre agentes siempre vía archivos** en `progress/`, `docs/tasks/` y `docs/changes_proposals/`.
7. **Preguntas conceptuales o de exploración (lectura pura)** se responden directamente, sin lanzar subagentes.
8. **Ninguna mutación git** (add/commit/push) sin confirmación explícita del usuario, en ningún repo.
9. **Instalación de skills solo con confirmación del usuario.**

## Mapa del repo

- `template/common/` — agentes (leader, reviewer), skills stub (`.agents/skills/`) y docs comunes (arquitectura, convenciones — incluida `superpowers.md`, TEMPLATE de task spec, changes_proposals/README).
- `template/apps/<app>/` — definición del implementer de cada app.
- `scripts/sync-template.sh` — propagación y chequeo de deriva.
- `progress/orchestrator/` — estado vivo (`current.md`) e histórico (`history.md`) del orchestrator.
- `.agents/agents/orchestrator.md` — único agente de este repo.
