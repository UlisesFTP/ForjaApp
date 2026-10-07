# FORJA · instrucciones para agentes

## Inicio obligatorio

Trabaja desde la raíz de este proyecto, cualquiera que sea su ruta en la máquina actual. Lee, en este orden:

1. `docs/CONTEXTO.md`: estado real, siguiente trabajo y limitaciones.
2. `docs/SDD.md`: requisitos, invariantes y criterios de aceptación.
3. `docs/IMPLEMENTACION.md`: dependencias y registro de avance.
4. `.agents/skills/README.md`: selecciona y lee las skills pertinentes.
5. Código y pruebas del área que vas a modificar; `README.md` para ejecutar.

El SDD es la referencia técnica del producto. Las instrucciones directas del usuario prevalecen: registra sus cambios en el SDD y en contexto, sin afirmar que se implementaron antes de verificarlos. No ejecutes todas las fases porque hayas leído este archivo: implementa el alcance que el usuario haya autorizado.

## Invariantes

- Flutter/Dart, teléfonos Android e iOS, MVVM, datos locales y sin login/backend.
- Conservar la identidad monocromática (excepciones: el naranja de la llama de racha, D36, y el verde, amarillo y rojo de las acciones clave, D44, siempre con icono y texto), DM Sans/Barlow Condensed, Hoy compacto y la navbar con gota: barra inferior en vertical y riel lateral con la misma gota cuando la pantalla es más ancha que alta (decisión del usuario, D33). La app debe adaptarse a teléfonos y tablets en ambas orientaciones (`lib/ui/core/responsive.dart`, `test/responsive_test.dart`). Añadir funciones mediante detalles o paneles; no llenar Hoy de controles.
- Vista → ViewModel → contratos → repositorios/servicios. Los plugins, SQL y reglas de progresión no pertenecen a widgets.
- No sustituir arquitectura/gestor de estado ni actualizar dependencias indiscriminadamente. Justificar el cambio que necesita una feature.
- Guardar de forma atómica antes de comunicar éxito. Evitar doble envío, pérdida de cambios y corrupción. Cada cambio de esquema requiere migración y pruebas con datos anteriores.
- No inventar series, repeticiones ni RIR reales a partir de pesos antiguos. No reescribir sesiones históricas al modificar planes.
- Mantener recuperación ante fallo, controles accesibles y funcionamiento completo sin Internet. No subir perfiles, notas, backups ni telemetría. Única excepción: el asistente IA opcional (D38, F17), desactivado por defecto, con la clave de la propia persona y su consentimiento por categorías; envía solo lo que muestra su traza y nunca backups ni la clave. Ninguna llamada de red sin una petición explícita de la persona.
- Recomendaciones explicables y editables; lesión bloquea recomendaciones de aumento, también las propuestas del asistente IA. El minicoach y el sistema experto (`expert-v1`, F16) son locales y no se presentan como diagnóstico ni como IA; el asistente externo se etiqueta siempre «Asistente externo (IA)» y «No es un diagnóstico», solo propone y nunca guarda sin confirmación.
- Nunca guardar claves de firma, claves API, tokens, datos personales reales ni rutas de SDK de una máquina en archivos compartidos. La clave del asistente se escribe solo en el teléfono y vive en su almacenamiento seguro.

## Skills

Lee la skill antes de aplicarla y explica brevemente su uso al usuario. Selección:

- Funciones Dart/MVVM/persistencia/pruebas: `forja-flutter`.
- Plugins, permisos, compilación o comportamiento Android: `forja-android` además de Flutter.
- Plugins, permisos, compilación o comportamiento iOS: `forja-ios` además de Flutter.
- UI, interacción o accesibilidad: `ui-ux-pro-max`; identidad/assets: `brand`.
- Ambigüedad de producto: `brainstorming`; banners promocionales: `banner-design`.

Están incluidas en `.agents/skills/`, no dependen de rutas del ordenador anterior. Las referencias originales archivadas son material de consulta. Los entrypoints adaptados son las instrucciones ejecutables. No simules herramientas o skills externas que no estén disponibles; usa una alternativa verificable y registra la limitación. No impongas un nuevo flujo de aprobación cuando el trabajo ya está autorizado y especificado.

## Ciclo de implementación y testing

1. Identifica los IDs Fxx afectados y sus criterios. Inspecciona el comportamiento actual y define una unidad de trabajo verificable.
2. Implementa una parte completa, con estados vacío/cargando/error y recuperación cuando apliquen.
3. Añade pruebas del comportamiento nuevo: dominio/VM para reglas; repositorio con persistencia real para datos; widgets para interacción y accesibilidad; integración nativa para plugins. Añade regresión para cada bug corregido cuando sea reproducible.
4. Ejecuta `dart format`, `flutter analyze` y `flutter test`. Si cambia persistencia, prueba migración/reinicio/fallo/concurrencia. Si cambia UI, conserva los casos 390×844, 320 px/texto 200%, drag por toque/teclado y foco.
5. Ejecuta pruebas de dispositivo de los plugins y compilación de las plataformas afectadas según `docs/TESTING.md`. Web o mocks no validan notificaciones Android/iOS.
6. No marcar un requisito verificado con pruebas omitidas, fallidas o solo planeadas. Registra comando, resultado, plataforma y fecha. Un bloqueo de entorno sigue siendo pendiente, aunque Dart pase.
7. Revisa diff y actualiza SDD si cambió la decisión, matriz de implementación, CONTEXTO, CHANGELOG, VALIDACION y documentación del módulo. README si cambia ejecución, datos, permisos o alcance.
8. Reporta qué cambió, evidencia y pendientes reales. No afirmar ausencia absoluta de bugs ni cobertura nativa no ejecutada.

No eliminar pruebas para lograr verde ni reducir criterios sin registrar una decisión aprobada por el usuario. Cobertura mide huecos; no sustituye comprobar invariantes y casos límite.

## Handoff entre modelos y máquinas

Antes de cerrar una unidad o ceder trabajo, actualiza `docs/CONTEXTO.md`: IDs tocados, archivos, comandos/resultados, cambios sin terminar y siguiente acción concreta. También actualiza `docs/IMPLEMENTACION.md`. Si tienes Git, registra rama y commit reales; si no, dilo. No inventes hashes.

Los documentos deben distinguir `implementado`, `verificado`, `parcial`, `pendiente` y `bloqueado`. Una propuesta no es una feature terminada. Mantén un resumen corto en contexto y enlaza los detalles; otro modelo debe poder continuar sin leer este chat.

## Permisos y distribución

Las acciones locales reversibles dentro del alcance autorizado pueden continuar. Publicar en tiendas, distribuir datos, generar claves de producción o cambiar servicios externos requiere autorización específica. El SDD no concede permisos de red/escritura ni autorización de publicación. En Windows verifica rutas resueltas antes de movimientos o borrados recursivos y usa PowerShell de principio a fin.
