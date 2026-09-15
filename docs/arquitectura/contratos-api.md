# Contratos entre apps — fuente de verdad de integración

> Regla: cuando mobile o admin hablen con el backend, los nombres, tipos y formas de estos contratos mandan. Cambiar un contrato exige actualizar este archivo EN LA MISMA TAREA y avisar al leader.

## Estado actual

Sin backend: mobile y admin operan con mocks que simulan estos contratos. Los tipos ya modelados en `mobile_app_gdes/types/api.ts` y `mobile_app_gdes/types/document.ts` y los modelos sugeridos en `admin_web_app/docs/spec_definition.md` Parte 8 son el punto de partida.

Los tipos TypeScript de las secciones siguientes están **copiados textualmente** de su fuente, con nota de qué app lo produce y cuál lo consume.

## Contratos relevados

### Sesión / usuario autenticado (mobile)

Fuente: `mobile_app_gdes/stores/authStore.ts`. Produce y consume: mobile (hoy solo local, persistido en AsyncStorage; no existe token). Es lo que el backend deberá devolver al autenticar.

```ts
export interface AuthUser {
  id: string;
  nombre: string;
  apellido: string;
  email: string;
  legajo: string;
}
```

### Marcación / registro horario (mobile)

Fuente: `mobile_app_gdes/types/api.ts`. Produce: mobile (empleado). Consumirá: backend → admin (revisión de registros).

```ts
export type RegisterAction = "entrada" | "salida" | "ausencia";

export interface RegisterRequest {
  workplaceId: string;
  action: RegisterAction;
  observation?: string;
  timestamp: string;
  // Location data
  latitude: number;
  longitude: number;
  accuracy: number;
  locationTimestamp: string;
}

export interface RegisterResponse {
  success: boolean;
  message: string;
  registrationId?: string;
}

// Error types
export interface ApiError {
  code: string;
  message: string;
}
```

Nota relevada (`mobile_app_gdes/docs/05`): `observation` viaja, pero el motivo de ausencia (enfermedad/franco/otros) queda en estado local y **no** se incorpora al request.

### Lugares de trabajo (mobile)

Fuente: `mobile_app_gdes/types/workplace.ts`. Producirá: backend (gestionado desde admin). Consume: mobile.

```ts
export interface Workplace {
  id: string;
  name: string;
  siteId: string;
  siteName: string;
  active: boolean;
}
```

### Planillas (mobile)

Fuente: `mobile_app_gdes/types/document.ts`. Produce: mobile (empleado). Consumirá: backend → admin (procesamiento de planillas).

```ts
export interface DocumentUploadRequest {
  workplace: string;
  months: string[];
  files: string[]; // Array of file URIs
  uploadedAt: string;
}

export interface DocumentUploadResponse {
  success: boolean;
  message: string;
  documentId?: string;
}
```

Nota relevada (`mobile_app_gdes/docs/02` y `05`): la UI envía `months: []` fijo y URIs locales de imagen; el lugar se muestra pero no es obligatorio para habilitar el envío.

### Documentos de contingencia / legajo (mobile)

Fuente: `mobile_app_gdes/types/document.ts`. Produce: mobile (empleado). Consumirá: backend → admin (legajo digital del empleado).

```ts
// Allowed file extensions for contingency documentation
export const ALLOWED_EXTENSIONS = [
  "pdf",
  "jpg",
  "jpeg",
  "png",
  "docx",
  "doc",
  "txt",
] as const;

// A single attached file selected by the user
export interface SelectedFile {
  uri: string;
  name: string;
  type: string; // extension, e.g. "pdf"
  size: number; // bytes
}

export interface ContingencyUploadRequest {
  workplaceId: string | null;
  files: SelectedFile[];
  uploadedAt: string;
}

export interface ContingencyUploadResponse {
  success: boolean;
  message: string;
}
```

Nota relevada (`mobile_app_gdes/docs/02`): la UI envía `workplaceId: null` y no valida tamaño, duplicados ni cantidad.

### Modelos y convenciones sugeridos por la spec de admin

Fuente: `admin_web_app/docs/spec_definition.md` Parte 8. Son **sugerencias de la spec**, no contratos vigentes: la spec repite que "el formato final dependerá del backend".

DTO de API vs modelo de dominio (sección 88):

```ts
interface UserResponseDto {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
}
```

```ts
interface User {
  id: string;
  fullName: string;
  email: string;
}
```

Enums centralizados (sección 89, copiados tal como aparecen en la spec):

```ts
enum UserRole {
  EMPLOYEE,
  ADMIN,
  SUPER_ADMIN
}

enum RecordStatus {
  COMPLETE,
  INCOMPLETE
}

enum ReviewStatus {
  NONE,
  PENDING,
  APPROVED,
  REJECTED,
  MANUAL_LOADED
}
```

La spec indica que también deben existir: `IntervalStatus`, `IntervalType`, `AccountStatus`, `TimesheetStatus`, `DocumentType`, `RecordOrigin`, `Site` (sin definición en la fuente — pendiente).

Convenciones REST sugeridas (secciones 81-86):

- Recursos: `/users`, `/records`, `/clients`, `/sites`, `/workplaces`, `/timesheets`, `/documents`, `/auth`.
- Paginación server-side: `?page=1&pageSize=25`, respuesta `{ items, pagination: { page, pageSize, totalItems, totalPages } }`.
- Filtros explícitos en la URL (ej. `GET /records?month=5&year=2026&siteId=123&employeeId=456&status=INCOMPLETE`); ordenamiento `?sortBy=lastName&order=asc`.
- El módulo de registros usa infinite scroll: paginación interna con `useInfiniteQuery()`, sin paginación visual.
- Respuesta exitosa sugerida: `{ "data": {...} }`; listados: `{ "data": [], "pagination": {} }`.
- Error uniforme sugerido: `{ "error": { "code": "USER_ALREADY_EXISTS", "message": "El usuario ya existe", "retryable": false } }`. El frontend no debe depender únicamente de `retryable`.

## Divergencias detectadas

Comparación mobile (tipos reales) vs admin (spec). Todas requieren **CONSULTAR AL HUMANO antes de unificar**; no se decide unilateralmente.

1. **Campos del usuario/empleado**: mobile usa español — `AuthUser { nombre; apellido; legajo }` — mientras la spec de admin sugiere inglés — `UserResponseDto { firstName; lastName }` — y nombra el legajo como `employee_id` (Parte 1, sección 7).
2. **Modelo del registro horario**: mobile modela eventos atómicos (`RegisterRequest` con `action: "entrada" | "salida" | "ausencia"` y un `timestamp` por evento), mientras la spec de admin modela un **registro diario** por `(user_id, workplace_id, date)` que contiene múltiples **intervalos** (Parte 1, sección 8). No es solo un renombre: son dos formas distintas del mismo concepto.
3. **Formato de respuesta**: mobile usa `{ success, message, registrationId? }` / `{ success, message, documentId? }`, mientras la spec de admin sugiere envoltorio `{ "data": ... }`.
4. **Formato de error**: mobile `ApiError { code; message }` vs sugerencia admin `{ error: { code, message, retryable } }`.
5. **Referencia al lugar en cargas documentales** (divergencia interna de mobile que impacta el contrato): `DocumentUploadRequest.workplace: string` (sin indicar si es id o nombre) vs `ContingencyUploadRequest.workplaceId: string | null`.
6. **Roles**: la spec de admin define `UserRole { EMPLOYEE, ADMIN, SUPER_ADMIN }` más el estado temporal `toBeAdmin`; mobile no modela roles en absoluto (`AuthUser` no tiene campo de rol).

## Pendiente de definir con el humano

- Endpoints concretos (rutas, métodos, códigos de error).
- Autenticación real (mecanismo, tokens, expiración).
- Storage de archivos (planillas, documentos).
- Resolución de las divergencias listadas arriba (idioma de campos, modelo evento vs registro diario con intervalos, envoltorio de respuestas/errores).
- Definición de los enums que la spec de admin menciona sin definir (`IntervalStatus`, `IntervalType`, `AccountStatus`, `TimesheetStatus`, `DocumentType`, `RecordOrigin`, `Site`).
- Contratos de entidades que solo existen del lado admin (empleados gestionados, clientes, sites, estados de planilla): la spec los describe funcionalmente pero no fija tipos.
