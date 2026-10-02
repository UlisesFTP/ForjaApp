# Entrega móvil: identificadores, firma, permisos y dependencias

Estado a **2026-10-01**. Este documento describe cómo se construye y qué lleva la app; no concede permiso para publicar en tiendas. Nada de lo que sigue se ha subido a ninguna tienda.

## Identificadores y versión

| Campo | Valor |
| --- | --- |
| Nombre visible | FORJA |
| Android | `com.forja.forja_app`, minSdk 24, compile/target según el SDK de Flutter instalado |
| iOS | bundle del proyecto Runner, mínimo 15.0 (sin compilar: no hay macOS) |
| Versión (`pubspec.yaml`) | `0.9.0+2` (candidata: iOS y varias pruebas de dispositivo pendientes; no se declara 1.0) |
| Flutter / Dart usados | 3.47.5 / 3.13.4 |

## Firma de Android (fuera del repositorio)

- Las versiones de distribución se firman con `android/key.properties` (copiar `android/key.properties.example`). El archivo y los `*.jks`/`*.keystore` están en `.gitignore`: **nunca se versionan ni se guardan claves, contraseñas o rutas de una máquina**.
- Sin `key.properties`, `flutter build apk|appbundle --release` **falla con un mensaje** (verificado 2026-10-01). Para probar una versión release en local existe `FORJA_ALLOW_DEBUG_SIGNING=1`, que firma con la clave de depuración: ese archivo **no es distribuible**.
- Verificado: `FORJA_ALLOW_DEBUG_SIGNING=1 flutter build apk --release` genera un APK de 66.3 MB (R8 activo, reglas del plugin de notificaciones en `android/app/proguard-rules.pro`); instalado en un Redmi 2412DPC0AG (Android 16) arrancó 10 s sin excepciones.
- No se ha generado ninguna clave de producción (requiere autorización específica).
- iOS: la firma (equipo de desarrollo, perfiles, certificados) debe prepararse en macOS/Xcode y tampoco se guarda en el repositorio.

## Permisos declarados (Android, manifiesto fusionado)

| Permiso | Para qué | Notas |
| --- | --- | --- |
| `POST_NOTIFICATIONS` | Recordatorios locales | Se pide al activar recordatorios; el estado real del sistema se muestra aparte del deseo |
| `RECEIVE_BOOT_COMPLETED` | Reprogramar recordatorios tras reiniciar o actualizar | Receptor del plugin |
| `VIBRATE` | Notificaciones | Lo añade el plugin |

Sin alarmas exactas, sin Internet declarado explícitamente (abrir un tutorial usa el navegador/YouTube del teléfono), sin ubicación, contactos ni cámara. `android:allowBackup="false"`: los datos no entran en las copias automáticas del sistema; la copia es la exportación explícita (F13).

## Iconos y arranque

- Android: icono adaptativo (marca FORJA sobre `#090909`) y icono clásico; pantalla de arranque oscura con la marca (Android 12+ usa `windowSplashScreen*`); icono monocromo de notificación propio (`ic_stat_forja`, Material «fitness_center», Apache-2.0).
- iOS: conjunto `AppIcon` existente y pantalla de arranque con la marca sobre `#090909` (sin ver en dispositivo).

## Dependencias directas y licencias

| Paquete | Versión | Licencia | Uso |
| --- | --- | --- | --- |
| flutter / flutter_localizations | SDK | BSD-3-Clause | Interfaz, localización |
| drift, drift_flutter | 2.35.1 / 0.3.1 | MIT | Base SQLite |
| path_provider | 2.1.6 | BSD-3-Clause | Carpeta privada de la app |
| shared_preferences | 2.5.5 | BSD-3-Clause | Solo lectura del JSON 0.1 para importarlo una vez |
| url_launcher | 6.3.2 | BSD-3-Clause | Abrir tutoriales |
| flutter_local_notifications | 22.3.1 | BSD-3-Clause | Recordatorios locales |
| timezone, flutter_timezone | 0.11.1 / 5.1.0 | BSD-3-Clause / Apache-2.0 | Hora local y zona |
| crypto | 3.0.7 | BSD-3-Clause | SHA-256 del respaldo |
| file_picker | 13.1.0 | MIT | Elegir/guardar el archivo de respaldo |
| cupertino_icons | 1.0.9 | MIT | Iconos |

Desarrollo: `drift_dev`, `build_runner`, `flutter_lints`, `shared_preferences_platform_interface`. Fuentes: DM Sans y Barlow Condensed (SIL OFL 1.1, licencias en `assets/fonts/`). `sqlite3` llega por Drift con hooks nativos (SQLite de dominio público). Las licencias se comprobaron por la primera cabecera de cada paquete en la caché de pub; antes de publicar hay que generar el aviso de licencias completo (`showLicensePage` de Flutter ya lo expone con las transitivas).

## Integración continua

`.github/workflows/ci.yml` (no ejecutado todavía: no hay repositorio remoto ni runner en esta máquina): formato, análisis, regeneración de código sin diferencias, pruebas con cobertura, compilación Android debug y release (firmada con depuración, no se sube) y comprobación de que un release sin clave falla; compilación iOS sin firma en un runner macOS. Su sintaxis se validó con un analizador YAML.
