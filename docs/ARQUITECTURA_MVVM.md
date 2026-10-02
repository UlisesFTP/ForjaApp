# Arquitectura MVVM de FORJA

## Recorrido de un cambio

1. La vista recibe una interacción, por ejemplo editar un peso.
2. El ViewModel valida el estado de la operación y llama al contrato del repositorio.
3. El repositorio deriva un nuevo estado inmutable y lo confirma a través de `ForjaStore.commit(previous, next)`.
4. Cuando la transacción termina, el repositorio publica el estado y notifica a los ViewModels.
5. La vista se actualiza y muestra una confirmación accesible. Si falla el guardado, conserva el último estado confirmado y permite reintentar.

## Responsabilidades

| Capa | Ubicación | Responsabilidad |
| --- | --- | --- |
| Vista | `lib/ui/*/widgets/` | Composición visual, formularios, foco, animaciones y paneles |
| ViewModel | `lib/ui/*/view_models/` | Estado de pantalla, comandos y preparación de datos para la vista |
| Dominio | `lib/domain/models/` | Modelos inmutables y estados de sesión |
| Contratos | `lib/domain/repositories/` | Interfaces que consumen los ViewModels |
| Reglas | `lib/domain/services/` | Funciones puras y deterministas: prescripción, generador y validador de planes, planificador de reprogramación, motor de progresión, estadísticas, revisión mensual, matemática de cardio, planificador de recordatorios y contrato `NotificationService` |
| Repositorio local | `lib/data/repositories/` | Fuente de datos y coordinación de escrituras |
| Servicios | `lib/data/services/` | `ForjaStore` (puerto, con `replaceAll`), `DriftForjaStore`, diff de snapshots, apertura de la base, tutoriales, plugin de notificaciones, `ReminderCoordinator` y `BackupService` (archivos y bóveda privada) |
| Copia de seguridad | `lib/data/backup/` | `BackupCodec`: formato versionado con SHA-256 y decodificador estricto |
| Tiempo | `lib/core/` | `ElapsedTimer`/`RestTimer` por marcas de hora, unidades de peso, fechas e identificadores |
| Base de datos | `lib/data/database/` | Tablas Drift, `ForjaDatabase` y la conexión de producción |
| Importación | `lib/data/legacy/` | Lectura, validación estricta e importación única del JSON de la 0.1 |
| Composición | `lib/app/` | Creación e inyección de dependencias y arranque |
| Estilo | `lib/core/theme/` | Paleta, tipografía y controles compartidos |
| Disposición | `lib/ui/core/responsive.dart`, `droplet_navigation.dart` | Umbrales por ancho real, `ResponsivePage`/`TwoColumns`/`ResponsiveGrid`; barra inferior en vertical y `DropletRail` en horizontal. Solo presentación: los ViewModels no saben del tamaño |

Se usa `ChangeNotifier` con inyección por constructor. No hace falta un contenedor global ni un servicio de red para ejecutar el MVP. Los ViewModels no importan el plugin de preferencias ni widgets Material.

## Almacenamiento actual (P1 · F00)

`DriftForjaStore` guarda en SQLite (`forja.sqlite`, directorio de soporte de la app, isolate de fondo). El repositorio sigue manteniendo en memoria un `AppSnapshot` inmutable y sus getters síncronos; así los ViewModels no cambian. Cada comando calcula el estado siguiente, y `commit(previous, next)` escribe **solo lo que cambió** (`diffSnapshots`) dentro de **una** transacción. Si falla, hay rollback y el estado visible no cambia.

Reglas del almacén: sesiones y check-ins con id opaco estable (upsert, nunca REPLACE); ejercicios de sesión actualizados en su sitio por id; descanso explícito como override con `routine_id` nulo; orden de alimentos por `seq`; `PRAGMA foreign_keys = ON`; fechas como texto ISO UTC. Una base con versión de esquema mayor que la de la app lanza `DatabaseNewerThanApp` y no se toca.

El esquema se versiona en `drift_schemas/forja/` y una prueba (`test/drift/schema_test.dart`) falla si las tablas cambian sin versionarse. Catálogo de ejercicios, rutinas y plantilla semanal siguen en código (`lib/data/seed/`) hasta P2; las referencias se validan en Dart.

### Importación de la 0.1

Al abrir, `LocalStoreOpener` migra la base y, si no hay marcador en `legacy_imports`, importa una vez `forja_flutter_snapshot_v1` (leído con `SharedPreferencesAsync`, el mismo backend que lo escribió). `LegacySnapshotV1Decoder` es estricto (tipos, rangos, fechas reales, referencias al catálogo) y devuelve incidencias con ruta, sin valores personales. Datos, verificación (releer y comparar con el original) y marcador van en una sola transacción. El original no se modifica. Fallos tipados (`StorageFailure`) llegan a la pantalla de arranque: reintentar, copiar datos originales o continuar sin importar (marcador `skipped`, con confirmación).

## Reprogramación

El plan en uso es la versión aceptada vigente para cada fecha (o el plan de ejemplo en código: piernas martes, empuje jueves, tirón sábado). Una sesión «No terminé» mueve solo lo no resuelto (ni hecho ni omitido); «Falté» mueve la rutina completa. `ReschedulePlanner` ofrece los días libres de los próximos 14 (preferencia: descanso a ambos lados; si no, el primero con aviso) y una fecha manual hasta 60 días, nunca sobre otra sesión. Aplicar crea en **una transacción** la sesión de destino, la excepción de calendario (descanso en el origen) y un registro `Reschedule` con linaje; deshacer es posible mientras el destino no haya empezado y es idempotente. No se sobrescribe una sesión histórica.

## Esquema y migraciones

Seis versiones del esquema (v1 → v6) con un paso `fromNToN+1` y prueba con datos reales anteriores cada una. Cambiar tablas exige `build_runner`, `make-migrations` y el paso de migración (ver TESTING). Los datos que no existían antes de una versión empiezan desconocidos (null), nunca con un valor inventado.

## Integración posterior
La evolución con series y servicios nativos está en [SDD](SDD.md). SQLite/Drift ya está implementado (P1); el resto es arquitectura objetivo. 1.0 mantiene MVVM sin backend/login; las notas siguientes de servicios remotos quedan fuera de ese alcance.

Los contratos son `WorkoutRepository`, `ExerciseRepository`, `PlanRepository`, `ProfileRepository`, `ProgressionRepository`, `CardioRepository`, `NutritionRepository` y `SettingsRepository`. Implementarlos e inyectarlos en los mismos ViewModels permitiría cambiar de fuente sin convertir las vistas en clientes de red.

La composición actual reutiliza un repositorio local que implementa todos los contratos. No hay backend ni se prevé en 1.0; sincronización y cuentas están fuera de alcance.

Las notificaciones pasan por `NotificationService` (contrato en dominio, plugin en `data/services/local_notification_service.dart`); `ReminderCoordinator` reconcilia la ventana de 28 días con lo que el SO tiene programado. Guardar la preferencia por sí sola no programa nada: lo hace la reconciliación y solo con permiso.

## Referencias técnicas

- [Guía de arquitectura de Flutter](https://docs.flutter.dev/app-architecture/guide).
- [Recomendaciones de arquitectura](https://docs.flutter.dev/app-architecture/recommendations).
- [Shared Preferences](https://pub.dev/packages/shared_preferences).
- [URL Launcher](https://pub.dev/packages/url_launcher).
