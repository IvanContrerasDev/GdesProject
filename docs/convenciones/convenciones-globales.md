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
