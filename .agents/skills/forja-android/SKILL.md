---
name: forja-android
description: Integrar y validar FORJA en Android con permisos, notificaciones, ciclo de vida, configuración Gradle y artefactos firmados sin exponer claves.
---

# FORJA Android

Usar junto a forja-flutter. Leer SDD F10/F11/F13/F14 y TESTING pertinentes; no añadir permisos innecesarios.

## Entorno

Inspeccionar flutter doctor/devices, SDK/Java/AGP/Gradle reales y android/. Baseline minSdk24, namespace/applicationId com.forja.forja_app, AGP9/Kotlin integrado y Gradle9.3.1. compileSdk/targetSdk provienen de Flutter: registrar valores efectivos. Comprobar plugins antes de subir mínimos/cambiar Kotlin.

local.properties es de máquina; corregir rutas sin compartirlas como configuración portable. Fallo histórico AccessDenied en caché core-ktx durante url_launcher: reproducir con primer error real, no borrar caches globales ni rebajar dependencias a ciegas. Caché aislada en workspace autorizado puede ayudar a diagnosticar.

## Integración

- Plugin detrás de servicio/contrato, no en widget.
- F11: canal, permiso runtime donde corresponda, hora/zona, IDs estables, cancelar/reprogramar y payload a sesión. Preferencia activada no prueba permiso o programación.
- Pedir permiso al activar; denial/revoke no bloquea entrenar. No exigir alarmas exactas para recordatorios ordinarios.
- Reconciliar al reanudar/cambiar plan. Revisar soporte de reinicio/receivers/exported en plugin real, no copiar manifest sin comprobar versión.
- F10 reconstruye tiempo; no necesita servicio foreground para ticks. Justificar si otra necesidad pide background service.
- DB/archivos privados, selección explícita para backup, sin permiso amplio de almacenamiento. Excluir datos sensibles de backup automático según política SDD.
- Back/gestos/teclado/SafeArea/TalkBack; nuevos targets48dp.

## Gates

APK debug compilado e instalado, integración con API mínima y nivel con permiso notificaciones, físico para recepción/batería/lifecycle. Probar permiso revocado, cancelación, reinicio y tap frío/caliente.

Release: AAB firmado con configuración externa. Baseline firma release con clave debug: no presentarlo como producción. No generar/exponer keystore/contraseñas sin autorización ni guardarlos en repo. Compilar no autoriza publicar Play Store.

Registrar comandos, SDK/OS/modelo y resultados en VALIDACION/IMPLEMENTACION/CONTEXTO. Bloqueo de entorno queda pendiente.

## Referencias

- [Flutter Android deployment](https://docs.flutter.dev/deployment/android).
- [Android notification permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission).
- [Android notifications](https://developer.android.com/develop/ui/views/notifications).
- [Flutter Android integration](https://docs.flutter.dev/platform-integration/android).

Consultar documentación del plugin elegido y reglas vigentes de release.
