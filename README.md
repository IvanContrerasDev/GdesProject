# GdesProject

Template compartido y coordinación global de GdeS. El código de producto vive en tres repos Git independientes:

| Subrepo | Estado real |
|---|---|
| [Mobile](mobile_app_gdes/README.md) | App Expo/React Native navegable con servicios mock y sesión local |
| [Admin](admin_web_app/README.md) | Aplicación React/Vite con módulos operativos sobre mocks; integración HTTP pendiente |
| [Backend](backend_api_gdes/README.md) | Bootstrap NestJS/Prisma, User/Site y health; dominio/auth pendientes |

El orchestrator mantiene acuerdos compartidos e instruye a los leaders locales; cada leader gestiona su backlog y ciclo implementer → reviewer. Reglas de roles: [AGENTS.md](AGENTS.md).

Fuentes oficiales:

- [Visión del sistema](template/common/docs/arquitectura/vision-sistema.md).
- [Contratos de integración y pendientes](template/common/docs/arquitectura/contratos-api.md).
- [Política documental](template/common/docs/convenciones/convenciones-globales.md): decisión vigente y motivo breve en su tema; sin historiales. Propuestas temporales se eliminan al incorporarse y verificarse el sync.
- [Flujo local](template/common/docs/convenciones/flujo-de-trabajo.md).
- [Estado actual del orchestrator](progress/orchestrator/current.md).

Propagar: `scripts/sync-template.sh push`; verificar: `scripts/sync-template.sh --check`. El sync documental no implica disponibilidad de API ni ejecuta operaciones Git.
