# GdesProject — Template del harness y orquestación global

Este repo **ya no orquesta el trabajo operativo**. Contiene:

1. El **template del conocimiento común** (`template/`) que se propaga a los subrepos.
2. El agente **orchestrator** (`.agents/agents/orchestrator.md`), único agente de este repo.

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
- Cambios: cualquier agente de un subrepo deja una propuesta en `<repo>/docs/changes_proposals/YYYYMMDD-slug.md`; el orchestrator la incorpora al documento canónico de `template/`, propaga, verifica `--check` y elimina la propuesta resuelta actualizando referencias. Las parcialmente resueltas conservan solo puntos abiertos.
- Propagación: `scripts/sync-template.sh push` (aplica) y `scripts/sync-template.sh --check` (detecta deriva, exit 1 si la hay). En un push, los archivos del template **ganan** sobre modificaciones locales.

## Flujo cross-app

1. El humano le trae la iniciativa al **orchestrator**.
2. El orchestrator evalúa, actualiza contratos comunes si hace falta (template + sync) y deja instrucciones en `<repo>/progress/leader/inbox/` de cada repo involucrado.
3. El humano abre cada repo con el leader local procesa su inbox y gestiona el ciclo leader → implementer → reviewer en su propio repo.

## Reglas innegociables

1. **Paralelismo coordinado**: por defecto una sola feature `in_progress` a la vez por repo; el leader local puede despachar varios implementers en paralelo si las tareas son independientes y bien acotadas (cada agente sigue haciendo UNA sola tarea; ver `docs/convenciones/flujo-de-trabajo.md` de cada repo).
2. **Estado actual en disco.** Cada agente actualiza `progress/<rol>/current.md` mientras trabaja; reemplaza estado y pendientes, sin diarios, `history.md` ni reportes por ronda.
3. **Leader-orquestador-trabajador-revisor:** el orchestrator no implementa ni hace de leader local; el leader no implementa; el implementer no se autoaprueba; el reviewer no edita código.
4. **Anti teléfono-descompuesto:** los subagentes escriben resultados en archivos y devuelven solo una referencia ligera (path + status).
5. **Una decisión vigente por tema.** La documentación canónica conserva la definición actual con motivo breve, sin cronología ni decisiones reemplazadas. Para comportamiento real y ambigüedades, contrastar código/esquema/tests; distinguir implementado, mock, acordado pendiente y decisión abierta. El código no ratifica requisitos nuevos ni anula acuerdos pendientes de implementar. Consultar solo lo que siga sin resolver.
6. **Comunicación entre agentes siempre vía archivos** en `progress/`, `docs/tasks/` y `docs/changes_proposals/`.
7. **Preguntas conceptuales o de exploración (lectura pura)** se responden directamente, sin lanzar subagentes.
8. **Ninguna mutación git** (add/commit/push) sin confirmación explícita del usuario, en ningún repo.
9. **Instalación de skills solo con confirmación del usuario.**

## Mapa del repo

- `template/common/` — agentes (leader, reviewer), skills stub (`.agents/skills/`) y docs comunes (arquitectura, convenciones — incluida `superpowers.md`, TEMPLATE de task spec, changes_proposals/README).
- `template/apps/<app>/` — definición del implementer de cada app.
- `scripts/sync-template.sh` — propagación y chequeo de deriva.
- `progress/orchestrator/` — estado actual (`current.md`) del orchestrator; sin historial acumulativo.
- `.agents/agents/orchestrator.md` — único agente de este repo.

## Ciclo de vida de la documentación

La política detallada está en `template/common/docs/convenciones/convenciones-globales.md` y se propaga a los subrepos. El contrato común es dueño de decisiones cross-app; specs locales lo enlazan sin redefinirlo. Tasks, planes, inbox y propuestas son temporales: al cerrar, incorporar contenido útil al documento oficial, actualizar referencias y eliminar artefactos resueltos. No eliminar bloqueos o decisiones abiertas. No guardar propuestas aplicadas/rechazadas, changelogs ni copias de decisiones antiguas.

El orchestrator puede realizar una auditoría documental global cuando el humano la solicita expresamente, editando documentación local y verificando código como evidencia. Esta excepción permite corregir referencias y descripciones documentales del backlog al consolidar archivos; no autoriza código de producto, cambiar estados/aprobaciones/dependencias o alcance funcional del backlog ni asumir funciones de implementación/revisión del leader.
