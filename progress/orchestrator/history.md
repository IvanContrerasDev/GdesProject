# History — orchestrator

Append-only. Una entrada por iniciativa cerrada, más reciente arriba.

## 2026-09-17 — Propuestas P-01..P-05 de admin_web_app (segunda ronda: ratificación completa)

- El humano respondió todas las preguntas pendientes (vía batches de opciones): P-01 (tipos + snapshot TTL 15 min), P-02 (rutas `/auth/web/*`, relogin ante refresh ambiguo), P-03 (ruta ampliada, challenge 10 min/5 intentos/60 s, payload 72 h, links 7 días, password actual para existentes, advertir-y-continuar, cancelación si INACTIVE), P-04 (`expectedVersion`, rechazo de solapamientos, sin WORK sin extremos ni registros vacíos en carga manual, motivo de ausencia opcional siempre, revisión pura vs MANUAL_LOADED, retrospectivas permitidas, 20 MiB ×10 atómico, búsqueda fileName+empleado, dashboard por mes seleccionado) y P-05 (**Geoapify** tras comparación de 7 opciones; Leaflet/MapLibre, clave por dominio, sin proxy).
- Decisiones 8–12 reescritas como ratificadas en `template/common/docs/arquitectura/contratos-api.md`; sync push OK (3 repos, sin deriva).
- Propuestas P-01/P-03/P-04/P-05 → `aplicada`; P-02 sigue `pendiente` (orígenes al deploy; generación de sesión/CSRF/atributos de cookie los propone backend y los ratifica el humano).
- Instrucciones: `backend_api_gdes/progress/leader/inbox/20260917-ratificacion-p01-a-p04.md` (materializar DTOs/ejemplos/errores) y `admin_web_app/progress/leader/inbox/20260917-contratos-ratificados.md` (contratos listos para mocks; P-05 resuelta; operaciones debe crear credencial Geoapify).
- Comparación de mapas entregada al humano en chat (fuentes oficiales de pricing); no se guardó en docs porque la decisión ya quedó registrada.

## 2026-09-17 — Propuestas P-01..P-05 de admin_web_app (aplicación parcial, aprobada por el humano)

- El humano aprobó incorporar **solo las decisiones ya confirmadas** de las 5 propuestas; diseños candidatos y preguntas abiertas quedan pendientes.
- `template/common/docs/arquitectura/contratos-api.md`: nueva sección "Decisiones de integración (2026-09-17)" con ítems 8–12 (matriz mensual, sesión web HttpOnly, verificación previa + 10 campos, completitud/proyección P-04.B, requisito de mapa real) y nuevo pendiente que apunta a las propuestas.
- Cada propuesta quedó con nota de qué se aplicó y qué sigue pendiente (Estado sigue `pendiente`).
- `sync-template.sh push` + `--check`: OK, los 3 repos sincronizados sin deriva.
- Instrucción al leader de backend: `backend_api_gdes/progress/leader/inbox/20260917-p04b-completitud-proyeccion.md` (incorporar P-04.B textualmente en docs de backend).
