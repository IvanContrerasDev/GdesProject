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
9. **Instalación de skills solo con confirmación del usuario.** La skill `find-skills` instala paquetes de terceros (`npx skills add -g -y`, con `-y` que saltea confirmaciones). Ningún agente instala skills sin confirmación explícita del humano.

## Mapa del harness

- `feature_list.json` — backlog con estados (pending / in_progress / done), criterios de aceptación y puntero al task spec.
- `docs/arquitectura/` — visión del sistema y contratos entre apps (fuente de verdad de integración).
- `docs/convenciones/` — convenciones globales y flujo de trabajo detallado.
- `docs/tasks/` — specs de tarea (se crean desde `TEMPLATE.md`).
- `progress/<rol>/` — estado vivo (`current.md`) e histórico (`history.md`) por rol.
- `.agents/agents/` — definiciones de los agentes.
- `.agents/skills/` — skills comunes. Cada subrepo tiene las suyas en `<subrepo>/.agents/skills/`.
