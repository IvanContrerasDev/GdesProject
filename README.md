# GdesProject

Repositorio orquestador del sistema GdeS. No contiene código de producto: contiene la documentación compartida, el estado de trabajo y la configuración del harness multi-agente.

## Subproyectos

| Subrepo | Qué es | Estado |
|---|---|---|
| `mobile_app_gdes/` | App Expo/React Native para empleados | En desarrollo (docs completas en su `docs/`) |
| `admin_web_app/` | Web administrativa (RRHH/gerencia) | Spec completa en su `docs/`, sin código aún |
| `backend_api_gdes/` | API que integra ambas | Por definir |

## Cómo trabajar con el harness

1. Iniciar sesión en este directorio: `kimi --agent leader`
2. El leader planifica, descompone features en task specs (`docs/tasks/`) y delega en los implementers de cada app.
3. El reviewer valida cada implementación contra el task spec, las docs y los contratos.
4. El estado del trabajo se lee en `feature_list.json` y `progress/`.

Ver `AGENTS.md` para las reglas y `docs/convenciones/flujo-de-trabajo.md` para el protocolo completo.
