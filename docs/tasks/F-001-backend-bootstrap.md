# F-001 — Bootstrap del backend (NestJS + Prisma + Docker + cross-cutting)

**Estado:** pending
**App(s):** backend
**Creada:** 2026-09-15

## Contexto

`backend_api_gdes/` no tiene código. Es la primera feature: deja el esqueleto sobre el que se implementan todas las demás (F-002 en adelante). El diseño completo está en `backend_api_gdes/docs/`.

## Alcance

**Incluye:**
- Proyecto NestJS nuevo con TypeScript estricto, ESLint/Prettier, estructura de carpetas de `docs/01-arquitectura-y-stack.md`.
- Prisma + PostgreSQL: `schema.prisma` inicial con `User`, `Site` y enums base; `prisma migrate`; seed con las 6 provincias.
- Cross-cutting: filtro global de excepciones (`{ error: { code, message, retryable } }`), interceptor de respuesta (`{ data }`), `ValidationPipe` global, guards `JwtAuthGuard`/`RolesGuard` (esqueleto), `ConfigModule` con validación de env al boot.
- `Dockerfile` multi-stage + `docker-compose.yml` de dev (api + postgres).
- Health check `GET /health`.

**NO incluye:**
- Ningún endpoint de negocio (auth, attendance, etc.) — van en features siguientes.
- Providers de email/WhatsApp/storage (van en F-007/F-008).

## Referencias (fuente de verdad)

- Docs: `backend_api_gdes/docs/01-arquitectura-y-stack.md`, `backend_api_gdes/docs/02-modelo-de-datos.md` (User, Site, enums), `backend_api_gdes/docs/07-convenciones.md`
- Contratos: `docs/arquitectura/contratos-api.md` (decisiones de integración)

## Criterios de aceptación

- [ ] `npm run build` compila y `npm run start:dev` levanta contra postgres de docker-compose.
- [ ] `GET /health` responde `{ "data": { "status": "ok" } }`.
- [ ] Un error lanzado en cualquier controller sale con formato `{ error: { code, message, retryable } }`.
- [ ] Una respuesta exitosa sale envuelta en `{ data: ... }`.
- [ ] Boot falla rápido con mensaje claro si falta una variable de entorno requerida.
- [ ] `docker compose up` levanta api + postgres y corre migraciones + seed.

## Notas de implementación

- Todo el código en inglés; mensajes de error en español (ver `docs/07-convenciones.md`).
- Variables de entorno mínimas listadas en `docs/01-arquitectura-y-stack.md`.
- No agregar dependencias fuera del stack definido sin consultar.

## Registro de implementación

(pendiente)

## Review

(pendiente)
