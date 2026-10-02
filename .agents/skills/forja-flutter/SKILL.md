---
name: forja-flutter
description: Implementar y probar funciones Flutter de FORJA con MVVM y datos locales, incluyendo migraciones, estado de pantalla y regresiones móviles.
---

# FORJA Flutter

Leer AGENTS, CONTEXTO y los Fxx del SDD desde raíz. Revisar pubspec/lockfile y módulo afectado. Baseline Flutter3.47.5/Dart3.13.4; confirmar SDK real sin actualizar a ciegas. Sin backend/login.

## Decisiones de implementación

- Reutilizar ChangeNotifier, constructor injection y lib/app/app_dependencies.dart. Una feature no justifica cambiar todo el gestor de estado.
- ViewModel consume contratos de dominio; SQL/plugins en data. Reglas puras y clock inyectable. Widgets solo presentación/foco/animación.
- Separar catálogo/prescripción del registro real. IDs estables, snapshots históricos, desconocido es null. No identificar logs por índice de lista.
- F00 requiere SQLite/Drift con migración idempotente de forja_flutter_snapshot_v1. No convertir checklist antiguo en series/reps/RIR inventados.
- Operaciones multi-entidad en transacción. Publicar tras commit; fallo conserva estado confirmado. Evitar doble finalize, sobrescrituras concurrentes y observers prematuros.
- Timer refresca UI; cardio/descanso reconstruye segmentos/timestamps. Liberar listeners/timers y comprobar mounted tras awaits que afecten UI.
- Peso/reorder conserva identidad y foco. Series bajo demanda para mantener Hoy compacto. Reutilizar theme y ui/core.

## Verificación y cierre

Pruebas de reglas/VM; SQLite temporal real para migración/transacciones/reinicio; widget para controles/foco/semántica. Tests de conducta nueva, no de detalles internos. Regressions de tamaños/texto y drag/toque/teclado cuando se toca UI.

Ejecutar formato/analyze/tests conforme TESTING. Plugins necesitan además skill Android/iOS y evidencia nativa; mocks/web no la sustituyen. Actualizar IMPLEMENTACION, CONTEXTO, VALIDACION y CHANGELOG; README/arquitectura si cambian contratos/ejecución. Fxx no se cierra con gates pendientes.

## Referencias

- Desde raíz: docs/SDD.md, docs/TESTING.md, docs/ARQUITECTURA_MVVM.md.
- [Flutter architecture](https://docs.flutter.dev/app-architecture/guide).
- [Flutter testing](https://docs.flutter.dev/testing/overview).
- [Drift migrations](https://drift.simonbinder.eu/migrations/).

Verificar documentación oficial del SDK/plugin instalado para detalles que cambien con versión y registrar decisiones reales.
