# FORJA · Flutter MVVM

Organizador móvil de rutinas de gimnasio con interfaz monocromática oscura, datos locales en SQLite y sin cuenta ni servidor. Versión `0.9.0+2` (candidata: iOS y varias pruebas de dispositivo siguen pendientes; ver [Alcance](docs/ALCANCE.md)).

## Ejecutar

Creado con **Flutter 3.47.5 / Dart 3.13.4**. Usa esta versión estable o una compatible con `pubspec.yaml`. Android mínimo API 24. El destino iOS del proyecto es 15.0 (sin compilar: no hay macOS en el entorno de desarrollo). Solo Android e iOS: el soporte web se retiró (decisión del usuario, 2026-10-01). Incluye racha de entrenos con llama animada y calendarios mensual y anual. Se adapta a teléfonos y tablets en vertical y horizontal: barra inferior en vertical, riel lateral con la misma gota en horizontal, dos columnas cuando caben.

```sh
flutter pub get
flutter run
```

Selecciona emulador o teléfono con `flutter devices`. La primera compilación Android necesita Internet: el hook de `sqlite3` descarga la biblioteca nativa y Gradle puede instalar CMake y una plataforma del SDK.

Si cambias las tablas de `lib/data/database/`, regenera el código de Drift (los archivos generados y `drift_schemas/` están en el repositorio) y escribe el paso de migración:

```sh
dart run build_runner build
dart run drift_dev make-migrations
dart format lib test
```

Compilar:

```sh
flutter build apk --debug
# Prueba local de release (firmado con la clave de depuración, NO distribuible):
FORJA_ALLOW_DEBUG_SIGNING=1 flutter build apk --release
```

Un release sin `android/key.properties` se rechaza a propósito. La firma de producción, los permisos y las dependencias están en [ENTREGA](docs/ENTREGA.md); no se guardan claves ni rutas de SDK en el repositorio. iOS requiere macOS, Xcode y firma.

## Pantallas

- **Hoy:** rutina, calendario, siguiente ejercicio, checklist, peso editable (kg/lb), panel de series, drag y menú de orden, calentamiento, check-in antes/después, reprogramación y reapertura.
- **Plan:** versiones del plan (borrador → aceptar con vigencia), generador local, editor y acceso a cada fecha.
- **Progreso:** cumplimiento, volumen real, evolución con tabla accesible, historial con series y sugerencias de progresión.
- **Ejercicios:** 39 ejercicios, búsqueda sin acentos, filtros, alternativas y tutorial externo.
- **Más:** cardio, nutrición, minicoach (perfil y revisión mensual), recordatorios, unidad de peso, licencias y datos y privacidad.

El primer arranque ofrece completar el perfil sin pedir cuenta (se puede saltar y retomar). La plantilla inicial es piernas martes, empuje jueves y tirón sábado; sus pesos son valores de ejemplo.

## Datos y privacidad

Todo se guarda en una base **SQLite** privada de la app (Drift, `forja.sqlite` en el directorio de soporte); cada cambio se confirma en una transacción antes de mostrarse. No hay backend, login, sincronización ni telemetría, y la base no está cifrada. Android no la incluye en las copias automáticas del sistema.

- **Copia de seguridad:** Más → Datos y privacidad. Exporta un JSON versionado con SHA-256 (detecta daños, no cifra) y contiene datos personales. Importar **reemplaza** todo: valida el archivo, muestra una vista previa, guarda antes una copia previa privada y reemplaza en una transacción. Eliminar todos los datos exige escribir BORRAR.
- **Actualización desde la 0.1:** el primer arranque importa una sola vez el JSON antiguo (`forja_flutter_snapshot_v1`); el original nunca se modifica. Si no se puede validar, la app lo explica y ofrece reintentar, copiar los datos originales o continuar sin importar (con confirmación). Los datos del prototipo web no se migran.
- **Recordatorios:** notificaciones locales con permiso del sistema; el sistema puede retrasarlas unos minutos.

## MVVM

```text
lib/
  app/                 dependencias y arranque
  core/                fechas, identificadores, tiempo por marcas de hora, unidades y tema
  domain/
    models/            modelos y enumeraciones
    repositories/      contratos
    services/          reglas puras: planes, progresión, estadísticas, revisión, cardio, recordatorios
  data/
    repositories/      repositorio local
    services/          almacén SQLite, notificaciones, copia de seguridad, tutoriales
    database/          tablas Drift y migraciones
    backup/            formato de copia con checksum
    legacy/            importación única del JSON 0.1
    seed/              catálogo y plan de ejemplo
  ui/
    core/              controles y navbar
    [pantalla]/
      view_models/     estado y comandos
      widgets/         vistas y formularios
```

Las vistas llaman a los ViewModels, que usan contratos de repositorio. El repositorio guarda primero y publica después. `AppDependencies` concentra la creación de dependencias. Detalle en [Arquitectura MVVM](docs/ARQUITECTURA_MVVM.md).

## Verificar

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

La suite (2026-10-01, host Windows) cubre SQLite real con reinicio, fallos de disco, concurrencia y migraciones desde datos de cada versión anterior; dominio y reglas con fixtures; repositorio y ViewModels; pantallas a 390×844 y 320 px/texto 200 % y una matriz de 25 tamaños de teléfono y tablet en ambas orientaciones; accesibilidad (contraste y guías de objetivos táctiles); y verificaciones de entrega (firma, permisos, secretos). Las migraciones, los recordatorios (permiso, programación, entrega y toque) y el arranque de la versión release se comprobaron además en un teléfono Android real. Consultar [Validación y limitaciones](docs/VALIDACION.md) y [Testing](docs/TESTING.md).

## Documentación

- [SDD](docs/SDD.md): requisitos, invariantes y criterios de aceptación.
- [Alcance](docs/ALCANCE.md) y [Plan y estado por requisito](docs/IMPLEMENTACION.md).
- [Entrega móvil](docs/ENTREGA.md): firma, permisos, dependencias, CI.
- [Contexto para otro modelo o máquina](docs/CONTEXTO.md) y [registro de cambios](CHANGELOG.md).
- [Reglas para agentes](AGENTS.md) y [skills incluidas](.agents/skills/README.md).
- [Identidad visual](docs/brand-guidelines.md).

Al continuar, leer AGENTS y CONTEXTO primero. Cada feature requiere implementación, pruebas y documentación actualizada.

## Assets

DM Sans y Barlow Condensed incluyen sus licencias OFL en `assets/fonts/` y aparecen en Más → Licencias. El logo es el del proyecto FORJA original; el icono de notificación es Material «fitness_center» (Apache-2.0).
