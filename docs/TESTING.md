# Estrategia de pruebas · FORJA 1.0

Este plan es un gate de implementación. Hay 600+ pruebas en `test/` (dominio, repositorio con SQLite real, migraciones, pantallas, accesibilidad); los casos nativos que solo un dispositivo puede mostrar siguen en la columna «Comprobación móvil» y su estado real está en IMPLEMENTACION y VALIDACION (no se marcan como hechos sin evidencia).

## Niveles

- **Dominio/VM:** reloj inyectado, reglas deterministas, validaciones y máquina de estados. Comprobar resultado observable, no detalles internos.
- **Repositorios/DB:** SQLite real temporal, migraciones/fixtures, FK/transacciones, reinicio, fallos/concurrencia e importación. No reemplazar pruebas de DB por un mapa fake. Arnés: `test/support/sqlite_harness.dart` (archivo temporal, reapertura, `FaultInjector` en la capa SQL y tope de páginas para disco lleno).
- **Widget:** controles, inputs, foco, semántica, formularios/error/loading, navegación y tamaños. Puede usar repositorios fake para aislar UI.
- **Integración:** app real con almacenamiento local y plugins en emulador/simulador; también dispositivos físicos para notificaciones, permisos y lifecycle.
- **Release/smoke:** instalar artefacto, primer inicio, editar/completar/restaurar datos y abrir tutorial; evidencia por plataforma.

## Matriz trazable

| Requisito | Casos automáticos nuevos requeridos | Comprobación móvil |
| --- | --- | --- |
| F00 | Migrar v1 completo/corrupto/futuro; rollback; segunda migración; guardar concurrente/fallido y reinicio | Datos antes/después de update, disco/IO y recuperación |
| F01 | Onboarding saltado/retomado, datos opcionales/invalidos y persistencia | Teclado numérico/decimal, cancelación y accesibilidad |
| F02 | Tres días, borrador/cancelar/aceptar, cambios futuros/históricos, equipo incompatible | Editor pequeño/texto largo, navegación back |
| F03 | Series/reps/RIR, kg/lb, omitir, doble comando, drag/teclado/toque/foco, reabrir | Scroll/drag real, teclado/rotación, término sin métricas |
| F04 | Cada sensación/sin dato, lesión, ajustar solo pendientes, revertir | Sheet, devolución de foco y lectura de recomendación |
| F05 | Colisión, sin hueco, cruce de mes/año, rollback, destino iniciado y deshacer | Preview claro, doble tap sin duplicación |
| F06 | Validar catálogo/referencias/URLs, búsqueda con acentos y fallback | YouTube instalado/no instalado, offline/error y retorno |
| F07 | Fecha exacta/revisión pospuesta, propuesta obsoleta, aceptación/rechazo | Review en fecha, estado persistido tras cerrar |
| F08 | Tabla de decisión de dos exposiciones, falta RIR/técnica, legacy, lesión y carga/variantes | Explicación/aceptación, repetir tap sin sumar peso |
| F09 | Volumen/cumplimiento con fixtures, desconocidos/parciales/reprogramación y rangos | Gráfica/tabla en lector de pantalla |
| F10 | Reloj fake/monotónico, pausas/segmentos/estimaciones y reinicio | Background, bloqueado, terminación por SO/reinicio, corrección de reloj |
| F11 | IDs/jobs, reconciliación con fake, fecha/zona/DST y cancelación | Permitir/denegar/revocar, recibir/tap frío-caliente, reinicio teléfono Android |
| F12 | Porciones/fracciones/recetas, null vs 0, editar/borrar/deshacer y objetivo manual | Formulario rápido offline, teclado y cantidades locales |
| F13 | Export/import idéntico, checksum/referencias/versiones/tamaño, cancelación/rollback/reset | Selector de archivo, compartir explícito, ida/vuelta Android/iOS |
| F15 | Reglas `streak-v1` con fechas fijas, ViewModel, insignia/página/semántica por día, tabla del mapa, contraste del naranja, animación finita, tamaños (`test/streak_test.dart`) | Comprobada en Android real (2026-10-02) |
| F14 (rendimiento) | `integration_test/perf_test.dart` (no forma parte de `flutter test`): `flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test/perf_test.dart -d <dispositivo>` con un teléfono desbloqueado y `FORJA_ALLOW_DEBUG_SIGNING=1`; usa un almacén en memoria y escribe `build/perf/summary.json`. Solo un build profile/release da cifras válidas. Resultados y límites en VALIDACION. |
| F14 | Layout/contraste/foco/semántica/motion y rutas de navegación (`test/accessibility_test.dart`: contraste WCAG de la paleta; guías de Flutter de tamaño de objetivo, etiquetas y contraste de texto en las siete pantallas y en los paneles de series y recordatorios) | TalkBack/VoiceOver, SafeArea, teclado, gestos/back y perfil de rendimiento |

## Regresiones móviles obligatorias al cambiar UI

- 390×844 a escala normal con tres ejercicios base: calendario, resumen, tarjetas y finalizar antes de navbar sin scroll.
- 320 px de ancho con texto 200%: scroll vertical permitido, sin recortes ni scroll horizontal de página.
- Nombres largos; vacío; sesión lista/en curso/todos completos/parcial/ausente; descanso.
- Texto no depende de color; contraste mínimo del SDD, targets 44×44 existentes / nuevos según plataforma.
- Detalles/check-in: título accesible, cierre visible, back, orden de lectura y foco devuelto.
- Reorder conserva identidad/peso/checklist y puede hacerse por asa, toque y teclado. Foco no salta al actualizar datos.
- Movimiento reducido mantiene función con animación discreta o instantánea. Navbar/droplet conserva su geometría y no cubre controles.

- Barra de navegación (`test/navbar_test.dart`): etiquetas en una línea y separadas con cualquier destino seleccionado en 320–600 px y texto 100/130/200 %, reglas puras del reparto (`NavBarLayout`).
- Teléfono y tablet en vertical y horizontal (`test/responsive_test.dart`, 25 tamaños con texto 100/130/200 %): sin excepciones ni texto fuera de la pantalla en las 7 páginas, dos columnas solo cuando caben, riel con los 5 destinos visibles sin desplazarse desde 320 px de alto, paneles ≤ 600 px, cada sección su propio nodo de accesibilidad, recorte de cámara lateral. Revisión visual opcional: `flutter test tool/capture_screens_test.dart` (PNG en `build/screens/`, `--dart-define=SIZES=844x390,1024x768@2`). En dispositivo: girar el teléfono y simular tablet con `adb shell wm density 240` (restaurar con `wm density reset`); no sustituye a una tablet real.

Las dimensiones son píxeles lógicos de Flutter, no pixels físicos de pantalla. La orientación horizontal sigue siendo operable aunque requiera scroll.

## Matriz nativa mínima

- Android: nivel mínimo API 24, un nivel con permiso runtime de notificación y target efectivo actual. Probar dispositivo físico con ahorro de batería y permiso revocado.
- iOS: mínimo configurado 15.0 si las dependencias siguen soportándolo, y versión compatible reciente; un dispositivo físico para notificaciones/VoiceOver.
- Registrar modelos, versión SO, SDK Flutter, modo debug/profile/release. Actualizar mínimos solo por necesidad concreta y documentar impacto.
- No ejecutar iOS en Windows ni declarar equivalencia por compilación web. Sin macOS, registrar iOS pendiente y el gate que falta.

## Comandos

Desde la raíz, ajustando el SDK instalado sin rutas específicas de otra máquina:

```sh
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build apk --debug
```

Release local sin clave de producción (el APK queda firmado con la clave de depuración y **no es distribuible**; sin la variable la compilación se rechaza):

```sh
FORJA_ALLOW_DEBUG_SIGNING=1 flutter build apk --release   # PowerShell: $env:FORJA_ALLOW_DEBUG_SIGNING = "1"
```

Comprobaciones de dispositivo útiles (Android, `adb`): `dumpsys alarm | findstr forja` (alarmas del plugin; contar entradas `Alarm{... origWhen ... com.forja.forja_app}`), `dumpsys notification --noredact`, `pm revoke|grant com.forja.forja_app android.permission.POST_NOTIFICATIONS`, y `run-as com.forja.forja_app cat files/forja.sqlite` para inspeccionar la base de una build de depuración (`PRAGMA user_version/integrity_check/foreign_key_check`). Un teléfono con bloqueo seguro no se puede desbloquear por `adb`: el usuario debe hacerlo.

Una vez que existan pruebas de integración:

```sh
flutter test integration_test -d <device-id>
```

No lanzar ese comando como si el directorio ya existiera. Crear suites pertinentes al implementar plugins/lifecycle. Si se generan archivos Drift, documentar comando de generación real y verificar que no falta código generado para compilar.

Release con firma de producción preparada externamente:

```sh
flutter build appbundle --release
```

En macOS, para comprobar compilación de simulador y archive firmado respectivamente:

```sh
flutter build ios --simulator
flutter build ipa --release
```

Un archive no implica publicación, ni compilación garantiza instalación/uso. Registrar fallos de firma/herramientas como pendientes. El destino web se retiró (2026-10-01): no hay build web.

### Drift (P1)

```sh
dart run build_runner build          # regenera lib/data/database/forja_database.g.dart
dart run drift_dev make-migrations   # vuelca el esquema en drift_schemas/ al versionarlo
dart run drift_dev schema generate drift_schemas/forja test/drift/generated/
```

`forja_database.g.dart` y `test/drift/generated/` se versionan; tras `build_runner` ejecutar `dart format lib test`.

`AppDependencies.dispose()` es asíncrono (espera el cierre del almacén). En `testWidgets`, el `tearDown` no puede esperar ese `Future` (los microtasks no avanzan y la prueba se cuelga): usar `addTearDown(() => unawaited(d.dispose()))`; la parte síncrona ya libera ViewModels y repositorio.

## Evidencia y corrección de bugs

Por feature: ID, fecha, comando/caso, dispositivo/SDK, resultado, criterio cubierto y limitaciones. Adjuntar logs resumidos sin datos personales y screenshots útiles. No presentar los 16 tests históricos como tests de funciones aún no hechas.

Por bug: reproducción mínima → prueba de regresión que fallaba → corrección → prueba verde → ejecutar suite afectada/general según riesgo. No deshabilitar asserts, descartar migraciones o borrar la base del usuario para ocultar fallo.

Medir cobertura de código nuevo y revisar ramas sin cubrir, especialmente fallos/rangos/transacciones. No usar un porcentaje arbitrario como único gate. La calidad requiere que cada criterio tenga evidencia y que los casos relevantes fallen cuando el comportamiento es incorrecto.
