# copilot-instructions.md — Instrucciones Maestras del Proyecto (App Decoración Hogar)

> **LEER ESTE ARCHIVO COMPLETO ANTES DE RESPONDER CUALQUIER PROMPT.**
> Este archivo define cómo GitHub Copilot debe comportarse en cada interacción dentro de este repositorio. Es el equivalente funcional de `CLAUDE.md` / `AGENTS.md`; los tres deben mantenerse sincronizados — si editas uno, edita los demás.
>
> *Nombre del proyecto: pendiente de definir por el usuario. Se usa "App Decoración Hogar" como marcador provisional — actualizar aquí y en el resto de la documentación cuando se elija un nombre definitivo.*

---

## ⚠️ PROTOCOLO OBLIGATORIO — Antes de cada respuesta

Cada vez que recibas un prompt relacionado con este proyecto, debes ejecutar este protocolo en orden:

```
1. LEER   → especificaciones técnicas.md   (stack, arquitectura, modelo de datos, estándares)
2. LEER   → plan de implementación.md      (etapa actual, tareas pendientes, MVP)
3. LEER   → errores.md                     (errores abiertos que pueden afectar la tarea)
4. LEER   → arreglos y cambios.md          (decisiones ya tomadas, no revertir)
5. LEER   → avances.md                     (último hito registrado, continuidad de sesión)
6. ACTUAR    → ejecutar la tarea solicitada con el contexto completo
7. ACTUALIZAR → escribir en los archivos correspondientes según lo que ocurrió
```

**No omitas ningún paso.** Si el contexto ya está en la conversación activa, puedes resumir la lectura, pero nunca asumas sin verificar contra estos archivos.

---

## 🧪 Contexto operativo actual (obligatorio)

**La aplicación es 100% local y de uso personal. No hay backend, ni nube, ni multiusuario.**

- Priorizar siempre simplicidad y velocidad de desarrollo por sobre escalabilidad prematura.
- Toda la persistencia es local (SQLite vía Drift). No introducir dependencias de red, sincronización remota o servicios cloud salvo que se solicite explícitamente.
- El usuario tiene **conocimientos básicos** de Flutter/programación: explicar el "por qué" de las decisiones técnicas no triviales, evitar jerga innecesaria.
- Escala actual del negocio: **menos de 50** clientes/productos/encargos. No sobre-diseñar para un volumen que no existe todavía, pero dejar puntos de extensión documentados en `especificaciones técnicas.md` (sección 6).

---

## 🧠 Identidad del Proyecto

**Nombre:** App Decoración Hogar (provisional)
**Tipo:** Aplicación móvil de gestión para un emprendimiento de venta y encargo de artículos de decoración para el hogar (cortinas, manteles, adornos, etc.)
**Plataforma:** Flutter — un solo código base para Android e iOS
**Arquitectura:** Clean Architecture simplificada por *feature*, sin backend, base de datos local
**Usuario:** una sola persona (dueño/a del negocio), sin perfil técnico en el uso diario

### Módulos de negocio (equivalentes a "features" en `lib/features/`)

| Código           | Módulo                       | Responsabilidad                                                   |
| ---------------- | ----------------------------- | ------------------------------------------------------------------ |
| `clientes`      | Clientes                      | Ficha de cliente, historial de compras/pagos, deudas               |
| `productos`     | Productos y categorías       | Catálogo interno, márgenes, stock, etiquetas                       |
| `encargos`      | Encargos                      | Registro de encargos, detalle de productos, estados                |
| `pagos`         | Pagos                         | Abonos, cuotas, saldo pendiente, historial                          |
| `gastos`        | Gastos y viajes               | Gastos de viaje de compra y distribución hacia productos           |
| `reportes`      | Reportes                      | Ventas, ganancias, deudas, productos más/menos vendidos             |
| `catalogo`      | Catálogo compartible          | Vista visual, filtros, generación de PDF/imagen, compartir          |
| `recordatorios` | Recordatorios                 | Notificaciones locales (cuotas, entregas, encargos pendientes)      |
| `backup`        | Copias de seguridad            | Exportar/importar JSON                                              |

> No existen microservicios ni gateway: todos los módulos viven dentro de la misma app Flutter, en `lib/features/{modulo}/`.

---

## 📁 Archivos de Control del Proyecto

Estos archivos, dentro de `documentación/`, son la memoria viva del proyecto. Claude los lee al inicio y los actualiza al final de cada sesión:

### `plan de implementación.md`
- Contiene las etapas del proyecto (1–11) con checklists de tareas.
- **Claude debe:** marcar tareas como completadas (`- [x]`) cuando se terminen.
- **Claude debe:** actualizar el estado de la etapa en curso y mover preguntas resueltas fuera de "pendientes".

### `errores.md`
- Registro de bugs y problemas técnicos detectados.
- **Claude debe:** agregar un nuevo registro con fecha, módulo afectado y estado (`🔴 Abierto` / `🟡 En revisión` / `🟢 Resuelto`).
- **Claude debe:** actualizar el estado a `🟢 Resuelto` con referencia al arreglo correspondiente en `arreglos y cambios.md`.

### `arreglos y cambios.md`
- Registro de decisiones técnicas, arreglos de bugs y cambios de requisitos/arquitectura.
- **Claude debe:** agregar un registro cuando resuelva un error o tome una decisión relevante.
- **Claude nunca debe:** revertir una decisión ya documentada aquí sin justificación explícita y sin registrar el cambio.

### `avances.md`
- Bitácora de progreso del proyecto.
- **Claude debe:** agregar una entrada con fecha y resumen de lo completado al cerrar cada sesión o bloque de trabajo.

### `especificaciones técnicas.md`
- Fuente de verdad de requisitos, arquitectura y modelo de datos. Se actualiza cuando cambian requisitos o decisiones técnicas (en conjunto con `arreglos y cambios.md`).

---

## 🏗️ Estándares de Código — SIEMPRE aplicar

### Estructura de carpetas obligatoria (Flutter — por feature)

```
lib/
├── core/
│   ├── database/         ← configuración Drift, tablas, DAOs compartidos
│   ├── router/            ← configuración go_router
│   ├── theme/             ← tema, colores, tipografía
│   ├── errors/             ← clases Failure / Exception compartidas
│   └── utils/              ← formatters (moneda CLP, fechas), extensiones
├── features/
│   └── {modulo}/                          ← ej. clientes, productos, encargos...
│       ├── data/
│       │   ├── datasources/               ← acceso a Drift (local_datasource)
│       │   ├── models/                    ← mapeo entidad ↔ tabla Drift
│       │   └── repositories/              ← implementación de repositorio
│       ├── domain/
│       │   ├── entities/                  ← entidades puras del negocio
│       │   ├── repositories/              ← contratos abstractos
│       │   └── usecases/                  ← una clase por caso de uso
│       └── presentation/
│           ├── screens/                   ← pantallas (Scaffold)
│           ├── widgets/                   ← widgets reutilizables del módulo
│           └── providers/                 ← Riverpod providers/notifiers
└── main.dart
```

**Reglas de código obligatorias:**

- Arquitectura en capas siempre: `presentation → domain (usecase) → data (repository) → Drift (datasource)`.
- Nunca lógica de negocio dentro de widgets/screens (cálculo de márgenes, distribución de gastos, estado de deuda, etc. van en `domain/usecases`).
- Nunca acceso directo a Drift desde `presentation`; siempre pasar por `repository`/`usecase`.
- Todo caso de uso que reciba datos de un formulario debe validar antes de llegar a `data` (ej. cantidades > 0, montos no negativos).
- Todo error debe representarse con clases `Failure` tipadas (ej. `ValidationFailure`, `DatabaseFailure`, `NotFoundFailure`), nunca `Exception` genérica propagada a la UI.
- La UI nunca debe mostrar un error técnico crudo (stack trace, mensaje de Drift); siempre un mensaje entendible mapeado desde el `Failure`.

### Convención de nombres (idioma según capa)

| Elemento | Idioma | Ejemplo |
|---|---|---|
| Entidades de dominio (negocio) | Español | `Cliente`, `Producto`, `Encargo`, `Pago`, `Gasto`, `Viaje` |
| Tablas Drift | Español (igual a la entidad) | `clientes`, `productos`, `encargos`, `pagos` |
| Clases arquitectónicas (capas técnicas) | Inglés + sufijo de capa | `ClienteRepository`, `ClienteLocalDataSource`, `GetClientesUseCase`, `RegistrarPagoUseCase` |
| Providers Riverpod | Inglés, sufijo `Provider` | `clienteListProvider`, `encargoDetalleProvider` |
| Pantallas / widgets | Inglés | `ClienteListScreen`, `ClienteDetailScreen`, `EncargoFormScreen` |
| Enums de dominio | Español | `EstadoEncargo`, `TipoPago`, `TipoGasto` |
| Archivos | snake_case | `cliente_repository.dart`, `registrar_pago_usecase.dart` |

*Justificación:* el dueño del negocio (usuario) razona en español sobre sus entidades (Cliente, Encargo, Pago); mantener esos nombres en español facilita futuras conversaciones sobre el negocio. Las clases puramente técnicas siguen la convención estándar de Flutter/Dart en inglés, que es lo que la comunidad y los paquetes usan.

---

## 🗄️ Base de Datos — Reglas Drift

- Cada tabla Drift vive en `core/database/tables/` y se declara con `Table` de Drift; los DAOs específicos de un módulo pueden vivir en `features/{modulo}/data/datasources/`.
- **Nunca modificar** una migración ya aplicada. Crear una nueva migración de corrección (Drift maneja versiones de esquema; incrementar `schemaVersion` y agregar el paso de migración correspondiente).
- Toda relación 1-N o N-M debe declarar claves foráneas explícitas (`references`) para mantener integridad (ej. no permitir eliminar un `Producto` con `EncargoDetalle` asociados sin antes resolverlo explícitamente).
- Los queries que alimenten `reportes` deben construirse como *streams* reactivos (`.watch()`) cuando el reporte deba reflejar cambios en vivo (ej. saldo pendiente de un cliente mientras se registra un pago).
- Formato de dinero: almacenar montos como enteros (CLP, sin decimales) para evitar errores de punto flotante; formatear a moneda solo en la capa de `presentation`.

### Tablas principales (ver modelo completo en `especificaciones técnicas.md` §5)

```
clientes, categorias, productos, viajes, gastos, encargos, encargo_detalle, pagos
```

---

## 🔔 Recordatorios y notificaciones locales — reglas

- Todo recordatorio (cuota por vencer, pago atrasado, encargo pendiente, producto listo) se programa con `flutter_local_notifications`, nunca con lógica de polling en segundo plano que consuma batería innecesariamente.
- Las notificaciones deben poder desactivarse por tipo (el usuario podría no querer todas), aunque el MVP puede lanzarlas todas activadas por defecto.
- No depender de internet para ningún recordatorio.

---

## 📄 Generación de PDF / Catálogo — reglas

- Toda generación de PDF/imagen para compartir vive en `features/catalogo/` y usa `pdf` + `printing` (PDF) y `share_plus` (compartir).
- El catálogo compartido nunca debe incluir el precio de compra ni el margen, solo precio de venta, nombre, foto, categoría y stock (a menos que el usuario pida lo contrario explícitamente).
- Generar el PDF/imagen de forma asíncrona con indicador de carga; no bloquear la UI principal.

---

## 🧪 Testing — Estándares Mínimos

| Tipo | Herramienta | Qué cubrir |
|---|---|---|
| Unitario | `flutter_test` + `mocktail` | Casos de uso (`usecases`): cálculo de margen, distribución de gastos, cálculo de saldo pendiente |
| Repositorio / DB | `flutter_test` con base Drift en memoria | Operaciones CRUD y migraciones |
| Widget | `flutter_test` (`WidgetTester`) | Formularios críticos (registrar encargo, registrar pago) |
| Golden (opcional) | `golden_toolkit` | Pantallas clave del catálogo |

**Tests obligatorios antes de marcar un módulo como completado en `plan de implementación.md`:**
- Caso de uso feliz (happy path) de cada operación crítica del módulo.
- Caso de error/validación (ej. abonar más de lo que se debe, cantidad negativa).
- Si el módulo toca cálculos de dinero: al menos un test que reproduzca un caso real tomado del cuaderno físico del usuario.

---

## 📋 Flujo de Trabajo por Tarea

Cuando el usuario pida implementar algo, Claude debe seguir este flujo exacto:

### Paso 1 — Verificar contexto
```
¿En qué etapa estoy según plan de implementación.md?
¿Hay errores abiertos en errores.md que afecten esta tarea?
¿Hay decisiones en arreglos y cambios.md que deba respetar?
```

### Paso 2 — Planificar antes de codificar
Antes de escribir código, mostrar:
```
📍 Etapa: X — Nombre de la etapa
📦 Módulo: nombre (clientes/productos/encargos/...)
🎯 Tarea: descripción de lo que se va a implementar
📐 Archivos a crear/modificar: lista
⚠️ Dependencias: qué debe estar funcionando antes
```

### Paso 3 — Implementar
- Respetar la estructura de carpetas y convenciones de nombres de este archivo.
- Generar código completo y funcional (no pseudocódigo ni fragmentos incompletos), con imports y configuración necesaria.
- Incluir tests para lo implementado.
- Si el módulo tiene una regla de negocio no confirmada (ver "preguntas pendientes" en `plan de implementación.md`), preguntar antes de asumir.

### Paso 4 — Actualizar archivos de control
Al terminar, Claude DEBE actualizar automáticamente:

**En `plan de implementación.md`:**
```markdown
- [x] Tarea completada
```

**En `avances.md`:**
```markdown
| Fecha | Hito / Avance | Etapa relacionada |
|---|---|---|
| YYYY-MM-DD | Resumen breve de lo completado | Etapa X — Nombre |
```

**En `errores.md`** (si se encontró un error):
```markdown
| # | Fecha | Descripción del error | Módulo afectado | Estado | Notas |
```

**En `arreglos y cambios.md`** (si se aplicó un arreglo o se tomó una decisión):
```markdown
| # | Fecha | Tipo (Arreglo/Cambio) | Descripción | Motivo | Documento(s) afectado(s) |
```

---

## 🚦 Reglas de Comportamiento de Claude

### SIEMPRE hacer:
- ✅ Leer los archivos de control al inicio de cada sesión (protocolo de la sección superior).
- ✅ Respetar las decisiones técnicas documentadas en `arreglos y cambios.md` y en la sección 3 de `especificaciones técnicas.md`.
- ✅ Generar código completo y funcional, con imports y configuración necesaria.
- ✅ Aplicar la convención de nombres por capa (español/inglés) definida en este archivo.
- ✅ Actualizar los archivos de control al finalizar la tarea.
- ✅ Preguntar si hay ambigüedad en una regla de negocio ANTES de implementar (no asumir, ej. cómo se distribuyen los gastos de un viaje).
- ✅ Indicar explícitamente qué archivos se crean, modifican o eliminan.
- ✅ Explicar alternativas técnicas razonables con ventajas/desventajas cuando exista más de una opción válida, y recomendar una.
- ✅ Ser crítico: si hay una mejor solución a lo que el usuario propone, explicarla y justificar por qué sería superior.
- ✅ Pensar como consultor de digitalización de pequeños comercios: proponer mejoras/automatizaciones cuando se detecten oportunidades, aunque no se pidan explícitamente.
- ✅ Priorizar simplicidad de uso para una sola persona sin perfil técnico en el día a día de uso de la app.

### NUNCA hacer:
- ❌ Introducir backend, nube o sincronización remota sin que el usuario lo pida explícitamente.
- ❌ Poner lógica de negocio (cálculos de margen, deuda, distribución de gastos) dentro de widgets/screens.
- ❌ Acceder a Drift directamente desde `presentation`, saltándose `domain`/`data`.
- ❌ Modificar una migración de Drift ya aplicada — crear una nueva.
- ❌ Revertir decisiones de `arreglos y cambios.md` sin justificación explícita y sin documentar el cambio.
- ❌ Omitir tests en un módulo marcado como completado.
- ❌ Incluir precio de compra o margen en el catálogo compartido con clientes.
- ❌ Asumir una regla de negocio no confirmada (preguntar primero).
- ❌ Avanzar a una etapa futura del `plan de implementación.md` sin cerrar la etapa actual, salvo que el usuario lo pida explícitamente.
- ❌ Sobre-diseñar para un volumen de datos que el negocio no tiene (recordar: <50 clientes/productos hoy).

---

## 🔄 Secuencia de Etapas — Referencia rápida

```
Etapa 1  → Análisis del negocio
Etapa 2  → Requisitos funcionales y no funcionales
Etapa 3  → Casos de uso
Etapa 4  → Modelo de datos
Etapa 5  → Arquitectura técnica
Etapa 6  → Diseño de pantallas (wireframes)
Etapa 7  → Experiencia de usuario (UX)
Etapa 8  → Desarrollo (MVP), módulo por módulo
Etapa 9  → Pruebas
Etapa 10 → Lanzamiento personal y adopción
Etapa 11 → Roadmap futuro (no MVP)
```

**Regla:** no avanzar a la siguiente etapa sin que los entregables de la actual estén completos (ver detalle y checklists en `plan de implementación.md`).

---

## 🧩 Cheatsheet de Decisiones Técnicas

| Pregunta | Respuesta correcta |
|---|---|
| ¿La app usa internet? | No. 100% offline. |
| ¿Dónde se guardan los datos? | SQLite local, a través de Drift. |
| ¿Cómo se maneja el estado? | Riverpod. |
| ¿Cómo se navega entre pantallas? | go_router. |
| ¿Cómo genero el catálogo en PDF? | Paquetes `pdf` + `printing`. |
| ¿Cómo comparto contenido a WhatsApp? | `share_plus`. |
| ¿Cómo guardo fotos de productos? | `image_picker` para capturar/seleccionar, `path_provider` para guardar localmente; se guarda el `path` en la tabla `productos`. |
| ¿Cómo programo recordatorios? | `flutter_local_notifications`, sin depender de internet. |
| ¿Cómo hago el backup? | Exportar/importar JSON manual (`dart:convert` + `file_picker`). |
| ¿Cómo calculo el costo real de un producto? | Precio de compra + parte proporcional de los gastos del viaje asociado (regla exacta de distribución: ver pregunta pendiente en `plan de implementación.md` §3). |
| ¿Puedo editar un pago ya registrado? | Pendiente de confirmar con el usuario (ver `plan de implementación.md` §3). No asumir; preguntar antes de implementar esa función. |
| ¿En qué idioma van las entidades de dominio? | Español: `Cliente`, `Producto`, `Encargo`, `Pago`. |
| ¿En qué idioma van las clases técnicas (repository, datasource, usecase)? | Inglés: `ClienteRepository`, `ClienteLocalDataSource`, `RegistrarPagoUseCase`. |
| ¿Quién puede cambiar reglas de negocio sensibles (ej. cómo se calculan las deudas)? | Solo el usuario dueño de la app decide; Claude no cambia reglas de negocio por su cuenta. |
| ¿Qué hago si el usuario pide algo que no está en el MVP? | Registrar la idea en el roadmap futuro (`plan de implementación.md` §Etapa 11) y confirmar si se prioriza ahora o después. |

---

## 📝 Convenciones de Commits

```
feat(clientes): agregar ficha de cliente con historial de pagos
fix(pagos): corregir cálculo de saldo pendiente con abonos parciales
refactor(encargos): extraer cálculo de estado a EncargoStatusUseCase
test(gastos): agregar tests de distribución de gastos por viaje
docs(especificaciones): actualizar modelo de datos con tabla viajes
chore(deps): actualizar Drift a última versión estable
```

Formato: `tipo(módulo): descripción en presente, minúscula, sin punto final`

---

## 🆘 Cómo reportar un bloqueador

Si Claude encuentra un problema que impide continuar:

1. Crear entrada en `errores.md` con estado `🔴 Abierto`.
2. Actualizar `avances.md` con la entrada de la sesión, señalando el bloqueador.
3. Describir exactamente qué se intentó, qué falló y qué información falta.
4. Sugerir 2–3 alternativas de solución para que el usuario decida.

---

## 🗃️ Referencia de Tablas — Nombres Exactos BD (Drift)

| Tabla | Módulo | Entidad Dart |
|---|---|---|
| `clientes` | clientes | `Cliente` |
| `categorias` | productos | `Categoria` |
| `productos` | productos | `Producto` |
| `viajes` | gastos | `Viaje` |
| `gastos` | gastos | `Gasto` |
| `encargos` | encargos | `Encargo` |
| `encargo_detalle` | encargos | `EncargoDetalle` |
| `pagos` | pagos | `Pago` |

*(Esta tabla se ampliará conforme se confirme el modelo de datos definitivo en la Etapa 4 del plan de implementación.)*

---

*Este archivo es la fuente de verdad del comportamiento de GitHub Copilot en este repositorio (equivalente a `CLAUDE.md` / `AGENTS.md`).*
*Versión: 1.0 | Última actualización: 2026-07-20 | Cambio: creación inicial, copia sincronizada de `CLAUDE.md` para GitHub Copilot.*
