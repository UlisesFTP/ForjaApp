---
name: forja-ios
description: Integrar y validar FORJA en iOS con notificaciones, accesibilidad y ciclo de vida, y preparar compilación y firma reales en macOS con Xcode.
---

# FORJA iOS

Usar junto a forja-flutter. Leer SDD/TESTING y configuración ios/ antes de cambiar permisos/deployment target.

## Entorno real

Build/run iOS necesita macOS/Xcode compatibles. En Windows preparar fuente/tests Dart y registrar gate nativo pendiente, sin simular build ni inferir éxito de web.

Confirmar doctor/devices, Xcode/simuladores, target, bundle ID y mecanismo nativo presente (CocoaPods/SPM); no migrarlo por iniciativa propia. Base target15.0 aún no validada nativamente; si plugin obliga subirlo registrar impacto.

Firma/team suministrados por usuario fuera del código. No guardar certificados/contraseñas/perfiles. Build de simulador no prueba firma de distribución.

## Integración y UX

- Adapter de notificaciones aislado, autorización al activar recordatorios. Estado observado del SO separado de preferencia deseada; deny/revoke con acceso a ajustes, app utilizable.
- F11 programa horizonte28 días y reconcilia al reanudar/cambiar plan. Revisar límite de solicitudes en SO/plugin; no prometer programación infinita estando app cerrada.
- Payload sesión/fecha, tap con proceso terminado/en marcha y cancelación al completar/desactivar. Sin APNs/push/backend.
- Cardio reconstruye duración persistida: iOS suspende Dart. No habilitar audio/localización/background modes falsos para contar tiempo.
- Sandbox, backup explícito, exclusión de backup automático conforme SDD; export/import sin permisos amplios ni logs personales.
- Dynamic Type200%, VoiceOver, reduced motion, teclado/SafeArea/swipe-back, sheets con cierre/foco; targets44pt y marca FORJA.
- Icono/splash, privacy manifests/usage descriptions para plugins presentes; no inventar permisos/prácticas de datos.

## Gates

Simulador: build/install/integración/datos. Físico: recepción/permiso/cancelación/tap frío-caliente, bloqueo/reapertura, VoiceOver y export/import. Registrar versiones/modelos reales.

Release: archive/IPA firmado y smoke TESTING. Cuenta/team no se resuelve con archivo ficticio. Publicar TestFlight/App Store requiere autorización específica.

Actualizar CONTEXTO/VALIDACION/IMPLEMENTACION. Sin macOS no aprobar gates iOS.

## Referencias

- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios).
- [Apple local notifications](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app).
- [Apple accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- [Flutter iOS integration](https://docs.flutter.dev/platform-integration/ios).

Verificar documentación oficial del SDK/plugin, firma y privacidad al implementar.
