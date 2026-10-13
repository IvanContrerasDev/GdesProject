# History — orchestrator

Append-only. Una entrada por iniciativa cerrada, más reciente arriba.

## 2026-10-12 — Aclaración sobre dominios de despliegue

- El humano mantiene web y backend como proyectos Vercel separados, pero difiere la elección de dominios/orígenes hasta más adelante. Es propietario de `prolimpservicios.com` y considera `admin.prolimpservicios.com` para Admin.
- Aclaré que `admin.prolimpservicios.com` + `backend-gdes.vercel.app` sigue siendo cross-site; mapear el API a `api.prolimpservicios.com` daría same-site pero cross-origin. La decisión puede esperar hasta antes de F-010, cuando existan URLs y se pruebe la sesión real.
- Actualicé contrato común y los inboxes locales sin fijar dominio final.

## 2026-10-12 — Seguimiento de decisiones: ventana offline y auth web

- El humano ratificó una ventana máxima de **24 horas** para marcaciones offline. La regla común mide `receivedAt` del servidor menos `occurredAt` del evento; el límite de 24 h es inclusivo y eventos más antiguos se rechazan. Se dejó a backend documentar código de error y pruebas; timestamps futuros/clock skew quedan abiertos.
- El humano expresó preferencia provisional por mantener orígenes separados de Vercel. Verifiqué en la Public Suffix List vigente que `vercel.app` es sufijo público; sus subdominios son sitios distintos. Se documentó que las cookies cross-site requieren `SameSite=None; Secure` pero siguen sujetas a bloqueo/partición del navegador; CORS no puede anularlo. Se detallaron same-site custom domains y proxy/BFF como alternativas si falla la compatibilidad.
- Actualicé el contrato común y los inboxes de backend/mobile con estas decisiones, propagando el template. La elección de hosting queda provisional hasta revisar browsers/fallback.

## 2026-10-12 — Sincronización de propuestas, contratos API y estado del proyecto

- Revisé las propuestas de `admin_web_app`; no encontré propuestas de cambio nuevas en `backend_api_gdes` ni `mobile_app_gdes`.
- Actualicé `template/common/docs/arquitectura/contratos-api.md`: corregí el cambio de Geoapify a Google Maps, retiré `REJECTED` de estados de revisión, añadí aprobación pura y eliminación de intervalos (F-006), registré P-06/P-07 ratificadas y aclaré que F-006 detalle/eventos aún requiere materialización backend. Separé decisiones humanas pendientes de trabajo de documentación/implementación.
- Actualicé el estado de propagación en las propuestas de Google Maps y aprobación/eliminación F-006.
- `scripts/sync-template.sh push` propagó los cambios; `scripts/sync-template.sh --check` terminó OK para los tres subrepos.
- Dejé instrucciones en `admin_web_app/progress/leader/inbox/20261012-estado-y-propuestas-sincronizadas.md`, `backend_api_gdes/progress/leader/inbox/20261012-sincronizar-contratos-ratificados.md` y `mobile_app_gdes/progress/leader/inbox/20261012-alinear-documentacion-de-integracion.md`. Los leaders locales conservan la propiedad de backlog, documentación operativa y features.
- Confirmé que F-011, F-012, F-013 y F-010 ya están como `pending` en el backlog de admin; no cambié estados locales.
- Decisiones solicitadas al humano: ventana máxima para marcaciones offline tardías y preferencia de dominio same-site para web/API. CSRF y generación de sesión quedan a la espera de propuesta backend; los orígenes/cookies reales se resuelven en el despliegue.
- No ejecuté mutaciones git. Se conservaron los cambios locales preexistentes.

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
