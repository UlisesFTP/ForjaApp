# Contexto de continuidad · FORJA

**Actualizado:** 2026-10-02 · **Último trabajo:** diseño adaptable a teléfonos y tablets en ambas orientaciones, con riel lateral en horizontal (D33); iOS y TalkBack aplazados por el usuario (D34). **Estado:** las fases P0–P7 del plan se ejecutaron en una sola sesión por autorización del usuario (D13: «termina todas las fases… testing… si sale bien, siguiente fase»). **Implementado y verificado en host (Windows): F00–F14.** Verificado además en un Android real (Redmi 2412DPC0AG, Android 16): migraciones v1→v6, panel de series, recordatorios completos (permiso, programación, entrega del aviso programado, toque en caliente y en frío, revocación) y arranque de la versión release. **Ningún requisito está cerrado**: falta iOS (no hay macOS) y varias pruebas de dispositivo (ver «Pendiente real»).

Este archivo permite cambiar de modelo o máquina sin depender del chat. Lee también `../AGENTS.md`, `SDD.md`, `IMPLEMENTACION.md` (matriz y decisiones D01–D36), `VALIDACION.md` (evidencia por fase) y `ENTREGA.md`. Las instrucciones actuales del usuario prevalecen sobre este resumen.

## Estado en una mirada

| Fase | IDs | Estado |
| --- | --- | --- |
| P0 | línea base | hecha (APK debug; baseline de pruebas) |
| P1 | F00 | SQLite/Drift, importación única del JSON 0.1, arranque con recuperación |
| P2 | F01, F02, F06 | perfil/onboarding, planes versionados y generador local, biblioteca de 39 ejercicios |
| P3 | F03, F04, F05 | series reales, omisiones, reapertura auditada, check-in antes/después, ajuste reversible, reprogramación con vista previa/deshacer/linaje, kg/lb |
| P4 | F07, F08, F09 | revisión mensual (`review-v1`), progresión (`prog-v1`), estadísticas reales con tabla accesible |
| P5 | F10, F11 | cardio por tramos con tiempo reconstruible, recordatorios locales nativos con ventana de 28 días |
| P6 | F12, F13 | nutrición (macros, favoritos, recetas, objetivos), copia de seguridad/importar/eliminar |
| P7 | F14 | accesibilidad probada, iconos/arranque/notificación, licencias, firma de release fuera del repo, CI definido, documentación |
| F15 | racha | racha de entrenos con llama naranja, calendario mensual y mapa anual (2026-10-02) |
| F14+ | diseño adaptable | teléfono/tablet en vertical y horizontal: dos columnas cuando caben, riel con gota en horizontal (2026-10-02) |

Pruebas: **712/712** (2026-10-02, host Windows; la cobertura 91.0 % es de 624, no se volvió a medir); `flutter analyze` sin incidencias; format sin cambios; cobertura de líneas 91.0 % sobre código no generado (0 % en `tables.dart`, declarativo, y en `local_notification_service.dart`, que solo ejercita un dispositivo y se comprobó en el teléfono). APK debug 164.8 MB y release (firmado con depuración, solo prueba) 66.8 MB.

## Identidad y decisiones aceptadas

- FORJA, app local Android/iOS en Flutter. **Sin web** (D08). Sin backend/login/telemetría. Coach por reglas locales, explicables, no diagnóstico ni IA remota.
- Tema oscuro monocromático; DM Sans + Barlow Condensed locales. Hoy compacto: el detalle va en paneles. Navbar oscura con droplet (no rediseñarla): barra inferior en vertical, riel lateral con la misma gota cuando la pantalla es más ancha que alta (D33).
- Arquitectura: Vista → ViewModel → contratos → `LocalForjaRepository` (estado en memoria + cola de escrituras + `ForjaStore.commit(previous, next)`) → Drift/SQLite. Guardar antes de publicar. Plugins, SQL y reglas fuera de widgets.
- Decisiones del usuario: sin soporte web (D08), «Continuar sin importar» (D10), sin commits de Git (D12), ejecutar todas las fases con pruebas como puerta (D13), app adaptable a teléfonos y tablets con riel en horizontal (D33), iOS y TalkBack para después (D34). Sin publicar en tiendas ni claves de producción.

## Mapa del código

```text
lib/app/                      composición (AppDependencies) y arranque
lib/core/                     fechas, ids, ElapsedTimer/RestTimer, unidades, tema
lib/domain/models/            modelos inmutables (models.dart, plan.dart, exercise.dart, storage_failure.dart)
lib/domain/repositories/      contratos
lib/domain/services/          reglas puras: training_rules, plan_generator/validator, reschedule_planner,
                              progression_engine, progress_stats, review_service, cardio_math,
                              reminder_planner, notification_service (contrato)
lib/data/repositories/        local_forja_repository.dart (todo el dominio de datos)
lib/data/database/            tablas Drift, ForjaDatabase (schemaVersion = currentSchemaVersion = 6), pasos de migración
lib/data/services/            drift_forja_store, snapshot_diff, local_store_opener, local_notification_service,
                              reminder_coordinator, backup_service
lib/data/backup/              backup_codec.dart (formato forja-backup v1, SHA-256, decodificador estricto)
lib/data/legacy/              importación única del JSON 0.1
lib/data/seed/                catálogo (39 ejercicios) y plan de ejemplo (en código)
lib/ui/<pantalla>/            view_models/ y widgets/ (today, plan, progress, exercises, coach, cardio, nutrition, settings, shell, startup)
drift_schemas/forja/          volcados v1–v6; test/drift/forja/generated/ (generado)
test/                         ver TESTING.md; test/support/{sqlite_harness,fake_notifications}.dart
android/ ios/ assets/ docs/ .github/workflows/ci.yml .agents/skills/
```

## Cómo trabajar aquí

- Ejecutar (PowerShell, sin rutas de SDK en archivos compartidos; `flutter.sdk` sale de `android/local.properties`): `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `flutter build apk --debug`. Tras cambiar tablas: `dart run build_runner build`, `dart run drift_dev make-migrations`, escribir el paso `fromNToN+1`, prueba de migración con datos y `dart format lib test` (ver TESTING y README).
- Trampas conocidas: `AppDependencies.dispose()` es async y el `tearDown` de `testWidgets` no puede esperarlo → `addTearDown(() => unawaited(d.dispose()))`; un `Timer.periodic` vivo al terminar un `testWidgets` falla la prueba (el cardio en ejecución se pausa al final); `LicensePage`/`rootBundle` dentro de `runAsync` puede colgar la prueba; las pruebas aleatorias deben calcular los valores aleatorios **fuera** de las clausuras que se ejecutan en memoria y en SQLite; los índices `@TableIndex` se crean con `m.createIndex`; sin Pillow en la máquina (los iconos se generaron con un test temporal de `dart:ui`); `flutter pub add` por `.bat` puede perder el `^`; los scripts de edición con comillas raras en Bash fallan: escribir un `.py` con la herramienta de archivos.
- No editar archivos con `Get-Content/Set-Content` de PowerShell (corrompe UTF-8); usar las herramientas de edición.

## Pendiente real (no marcar como hecho sin evidencia)

1. **iOS entero**: compilación, firma, notificaciones (autorización, 64 pendientes), selector de archivos, exclusión de la base de iCloud, VoiceOver. Hay un job de CI para macOS definido y sin ejecutar. El emulador Android tampoco arranca en esta máquina (reintentado).
2. **Pruebas de dispositivo sin hacer**: tablet física (el diseño adaptable se comprobó en host con 25 tamaños, en el teléfono girado y con una tablet simulada por `wm density`); TalkBack con una persona escuchando (se activó por `adb` pero no se puede leer lo que anuncia). **Hechas el 2026-10-02:** reinicio del teléfono con recordatorios (12 alarmas reprogramadas sin abrir la app) y cardio con la pantalla bloqueada (02:19 correcto); cambio de pestaña ya corregido y medido en el teléfono (peor fotograma 169 → 29 ms; `test/shell_rebuild_test.dart`). **Hechas en el teléfono desbloqueado (2026-10-01 tarde, ver VALIDACION):** formularios de nutrición, exportar/importar con el selector del sistema (incluida una copia alterada), eliminación total (0 alarmas) y restauración con 11 recordatorios, cardio en segundo plano y tras muerte del proceso, ahorro de batería (entrega ≈5 min tarde) y horario de verano con `Europe/London` (15:00Z → 16:00Z el 25 oct).
3. **Revisar contenido antes de publicar**: reglas `prog-v1` y `review-v1`, tabla MET `met-v1` (valores redondeados sin contrastar con la fuente), explicación de progresión siempre en kg.
4. **CI sin ejecutar** (no hay repositorio remoto), firma de producción sin generar (requiere autorización), avisos de Flutter por `flutter_timezone` aplicando KGP.
5. Git: rama `master` **sin commits** por decisión del usuario (D12); todo está sin versionar. No inventar hashes.

## Próxima acción recomendada

Lo pedido por el usuario está hecho hasta donde permite este entorno. Pendiente cuando haya medios (aplazado por el usuario, D34): iOS/iPad con macOS (compilar, notificaciones, archivos, VoiceOver, CI), TalkBack con una persona escuchando, y una tablet física para confirmar el diseño adaptable fuera de la simulación. Antes de publicar: revisar `prog-v1`, `review-v1` y la tabla MET (D26). Para publicar en tiendas o crear claves de producción hace falta una instrucción específica del usuario.

## Recursos y skills

Se incluyen versiones adaptadas y copias originales de banner-design, brainstorming, brand y ui-ux-pro-max en `.agents/skills/`, más forja-flutter, forja-android y forja-ios. Son instrucciones del proyecto, no certificaciones. Los scripts originales archivados no se ejecutan para cambiar Flutter.

## Portar a otra máquina

Copiar/clonar **toda la carpeta**, incluidos `.agents`, assets, docs, lockfile y plataformas; excluir build/cachés, claves, `android/local.properties` y datos reales. Instalar SDK compatible, Android SDK/JDK 21 y, para iOS, macOS/Xcode. Ejecutar doctor/pub get/analyze/test. El código no transporta los datos del teléfono: usar la copia de seguridad de la app (F13).

## Cómo mantener este contexto

Al finalizar cada unidad actualizar: fecha, alcance/IDs, estado real, archivos, comandos y resultados, entorno/commit reales, bloqueos y siguiente paso. Detalles en IMPLEMENTACION/VALIDACION; aquí solo el resumen. No copiar conversaciones ni afirmar trabajo sin evidencia.

## Último handoff

- **Unidad:** P7 · F14 (2026-10-01), cierre de la secuencia P0–P7. Estado: **implementado y verificado en host; no cerrado**.
- **Archivos de P7:** `android/app/build.gradle.kts` (firma, R8), `android/app/proguard-rules.pro`, `android/key.properties.example`, recursos de Android (icono adaptativo, `launch_background`, `values-v31`, `ic_stat_forja`, `keep.xml`), `ios/Runner/Assets.xcassets/LaunchImage.imageset` y `LaunchScreen.storyboard`, `.github/workflows/ci.yml`, `lib/main.dart` (licencias de fuentes), `lib/core/theme/forja_theme.dart` (color de iconos), `lib/ui/shell/widgets/shell_view.dart` (Licencias), `test/accessibility_test.dart`, `test/delivery_test.dart`, `docs/ENTREGA.md`, README/ALCANCE/ARQUITECTURA/TESTING/SDD actualizados.
- **Comandos/resultados:** format sin cambios; analyze limpio; `flutter test --coverage` 624/624 (626/626 tras las correcciones del recorrido en teléfono y del shell); `flutter build apk --debug` y `--release` (con `FORJA_ALLOW_DEBUG_SIGNING=1`) correctos; release sin clave rechazado; release instalado en el Redmi y arrancado 10 s sin excepciones.
- **Cambios de entorno:** dependencias nuevas a lo largo de la sesión: `flutter_local_notifications`, `timezone`, `flutter_timezone`, `crypto`, `file_picker`. Gradle instaló CMake y plataforma 35 en el SDK local. El teléfono tiene instalada la versión release (firmada con depuración) con datos de prueba.
- **Git:** rama `master` sin commits (D12). **Siguiente paso:** «Próxima acción recomendada».
- **Recorrido en teléfono (2026-10-01 tarde):** archivos tocados `lib/data/services/backup_service.dart` (nombre de exportación en hora local), `lib/ui/settings/{view_models/data_view_model,widgets/data_sheet}.dart` (avisos visibles, singular/plural), `lib/ui/nutrition/widgets/{food_form,recipes_sheet}.dart` (autovalidación de kcal, campos más anchos), `test/{backup_test,nutrition_test}.dart`. Comandos: format sin cambios, analyze limpio, `flutter test` 625/625, `flutter build apk --release` (flag de depuración) instalado sobre la versión previa con los datos intactos. Sin commits (D12). El teléfono tiene instalado el release con las correcciones (la persona aceptó el aviso «Instalar vía USB»; `flutter drive` desinstala la app al terminar, así que reinstalar exige aceptarlo a mano) con datos de prueba nuevos (onboarding omitido, recordatorios 18:00, un cardio).
- **Diseño adaptable (2026-10-02, F14, D33/D34):** archivos `lib/ui/core/responsive.dart` (nuevo), `lib/ui/core/droplet_navigation.dart` (`DropletRail`), `lib/ui/shell/widgets/shell_view.dart` (sin columna de 480 px, barra o riel según orientación, recorte lateral, barra de estado), `lib/ui/today/widgets/today_view.dart` (dos columnas, semana centrada), `plan_view`, `progress_view` (barras de ancho máximo), `cardio_view`, `nutrition_view`, `exercises_view` (cuadrícula), `lib/ui/core/widgets.dart` (paneles 600 px), `plan_editor_page` (760 px); pruebas `test/responsive_test.dart`; herramienta `tool/capture_screens_test.dart`. Comandos: format sin cambios, analyze limpio, `flutter test` 672/672, release instalado en el teléfono (la persona acepta el aviso «Instalar vía USB»). Teléfono restaurado (densidad, rotación, `stayon`). Sin commits (D12). Siguiente: tablet física o iPad cuando haya, TalkBack con el lector real, iOS con macOS.
- **Barra de navegación (2026-10-02, F14, D35):** `lib/ui/core/droplet_navigation.dart` (`NavBarLayout`, pintor con centros reales, riel a 140 %), `test/navbar_test.dart`. Format/analyze limpios, 689/689. TalkBack comprobado desactivado en el teléfono. Separación de etiquetas 18 px (mín. 12) tras verlo en el teléfono; versión final comprobada en el teléfono (≈18–19 dp entre etiquetas). Sin commits (D12).
- **Racha (2026-10-02, F15, D36):** `lib/domain/services/streak_rules.dart`, `lib/ui/streak/{view_models/streak_view_model,widgets/streak_flame,streak_badge,streak_page}.dart`, `lib/core/theme/forja_theme.dart` (colores de la llama), `lib/core/date_utils.dart` (`fullMonthNames`), `lib/app/app_dependencies.dart`, `lib/ui/shell/widgets/shell_view.dart` (insignia en la barra superior), `test/streak_test.dart`, `tool/capture_screens_test.dart`. Format/analyze limpios, 712/712. Sin esquema nuevo. Comprobada en el teléfono (corregido el inicio del conteo y el mensaje con racha 0). Sin commits (D12).
