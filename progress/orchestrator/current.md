# Current — orchestrator

## Tarea activa
Ninguna.

## Haciendo ahora
- 2026-09-17 (segunda ronda): el humano ratificó los candidatos de P-01, P-03, P-04 y parte de P-02. Decisiones 8–12 reescritas en `template/common/docs/arquitectura/contratos-api.md` (snapshot TTL 15 min, rutas `/auth/web/*`, relogin ante refresh ambiguo, solicitud admin con password actual para existentes, `expectedVersion`, rechazo de solapamientos, motivo de ausencia opcional siempre, retrospectivas permitidas, 20 MiB ×10 atómico, dashboard por mes seleccionado). Propuestas P-01/P-03/P-04 marcadas `aplicada`; P-02 y P-05 siguen `pendiente` parcialmente. Sync push OK en los 3 repos. Instrucciones en inbox de backend (`20260917-ratificacion-p01-a-p04.md`) y admin (`20260917-contratos-ratificados.md`). Investigación de proveedores de mapas (P-05) en curso con subagente.
- 2026-09-17: procesé las 5 propuestas de `admin_web_app/docs/changes_proposals/` (P-01..P-05). Primera ronda: solo decisiones ya confirmadas.
- 2026-09-16: reestructura del harness a template + subrepos autónomos (leader/reviewer/implementer por repo, sync de commons, changes_proposals).

## Blockers / Preguntas para el humano
- Dominios tentativos del backend registrados (2026-09-17): prod `backend-api-gdes-prod.vercel.app`, test `backend-api-gdes-dev.vercel.app` — a confirmar/cambiar al deploy. Falta: orígenes de la **web admin** (allowlist CORS). Advertencia documentada: vercel.app está en la Public Suffix List → web y API en subdominios distintos = cross-site (evaluar dominio propio o same-site).
- Ratificar cuando backend los proponga: identificador de generación de sesión, mecanismo CSRF exacto y atributos definitivos de cookie (P-02).
- Operaciones: crear cuenta Geoapify + credencial restringida por dominio antes de F-005 (P-05, ya decidido el proveedor).
