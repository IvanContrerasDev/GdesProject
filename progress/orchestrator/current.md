# Estado actual — orchestrator

Sin tarea activa. Documentación consolidada y sincronizada con el código observado al 2026-10-16.

## Fuentes vigentes

- [Contrato común y pendientes de integración](../../template/common/docs/arquitectura/contratos-api.md): distingue diseño aprobado, mocks, disponibilidad real y decisiones abiertas.
- [Política documental](../../template/common/docs/convenciones/convenciones-globales.md): decisión actual y racional breve por tema; propuestas/tareas temporales, sin historiales.
- Brechas locales: [Admin](../../admin_web_app/docs/integracion.md), [Mobile](../../mobile_app_gdes/docs/05-servicios-datos-y-contratos.md), [Backend](../../backend_api_gdes/docs/03-contratos-api.md).

## Pendientes del sistema

Sesión web (CSRF/generación, dominios/cookies y navegadores), contratos de archivos/métricas y coherencia provincial, DTO final detalle/eventos y migración de mocks. El backend solo registra health. La única propuesta abierta de Admin conserva los puntos que requieren ratificación; implementaciones y revisiones locales siguen a cargo de sus leaders, con estados/aprobaciones/dependencias de backlog preservados.

QA Mobile: TypeScript pasa; registro tiene 3 tests exitosos y 4 fallidos por geometría/altura esperada, documentados en [QA](../../mobile_app_gdes/docs/09-verificacion-y-qa.md). No se cambió producto para resolverlos.

Verificación documental: sync sin deriva, enlaces locales y referencias de backlog válidos, diff sin errores de espacios; 95 secciones de requisitos Admin preservadas. Cambios limitados a documentación y metadatos documentales; commits locales autorizados por el humano; publicación remota no solicitada.
