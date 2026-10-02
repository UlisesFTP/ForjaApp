# FORJA · SDD para la versión móvil 1.0

**Versión:** 1.0 de la especificación · **Fecha:** 2026-09-30.

SDD significa aquí **Software Design Document**: especificación funcional, diseño técnico y criterios verificables para completar FORJA mediante desarrollo guiado por especificaciones. Este documento describe el destino; no declara implementadas las funciones pendientes. Estado de ejecución: [IMPLEMENTACION.md](IMPLEMENTACION.md). Evidencia histórica: [VALIDACION.md](VALIDACION.md).

## 1. Producto y definición de terminado

Organizador personal de gimnasio para teléfono, hecho en Flutter para Android e iOS. Permite saber qué toca, registrar lo realizado, adaptar un plan y consultar progreso. El núcleo funciona sin cuenta, servidor ni Internet. Los datos permanecen en el dispositivo. YouTube necesita conexión; exportar un backup es una acción explícita del usuario.

**100%** significa que todos los requisitos F00–F14 definidos aquí están implementados y verificados, con los gates de release satisfechos en ambas plataformas. No significa ausencia matemática de bugs ni publicación automática en tiendas. La publicación comercial es un paso autorizado por separado. No se asigna un porcentaje ficticio a la base actual.

Alcance 1.0: entrenamiento/series, calendario de tres días configurable, biblioteca, feedback y reprogramación, coach por reglas con revisión mensual, progresión explicable, estadísticas, notificaciones, cardio, nutrición manual con macros/recetas, respaldo y accesibilidad. Dieta significa planificación manual inspiracional, no prescripción médica. Los objetivos calóricos los elige el usuario; no inventar un cálculo clínico.

Fuera de 1.0: login, backend, sincronización automática/cloud, coach con LLM, wearables/HealthKit/Health Connect, pagos, red social, escáner de alimentos o base nutricional externa, recomendaciones médicas, publicación en tiendas. No añadirlos para cerrar requisitos.

## 2. Base comprobada y decisiones de producto

La entrega 0.1 tiene Hoy/checklist/peso/drag, Plan, Progreso, nueve ejercicios, perfil/coach sencillo, cardio sin historial, alimentación por calorías y preferencias de recordatorio. Persistencia JSON v1 en SharedPreferencesAsync. Las 16 pruebas y build web son evidencia histórica de esa base. Android falló por acceso a caché Gradle en esa entrega (en P0, 2026-09-30, el APK debug compiló); iOS no se ejecutó. No deducir que los plugins móviles funcionan por tener build web.

Decisiones para 1.0:

- MVVM con ChangeNotifier e inyección por constructor; conservar estructura existente.
- SQLite con Drift como almacenamiento objetivo de historiales y series. SharedPreferences se mantiene únicamente para importar el snapshot antiguo y, si hace falta, preferencias no críticas; una única fuente canónica para cada dato.
- Coach/progresión son motores locales deterministas con versión de reglas. Una explicación acompaña cada sugerencia. El usuario confirma cambios de plan/carga.
- Tres entrenamientos por semana por defecto; selecciona días y edita rutinas. No prometer frecuencia adaptativa ilimitada en esta versión.
- Unidades internas kg, gramos, segundos y kcal. Entrada/presentación kg o lb, conversión al guardar sin redondear repetidamente; incremento mínimo configurable por ejercicio.
- La identidad visual actual y la navbar se conservan; en horizontal la misma gota se presenta como riel lateral (D33). El formulario de series se abre bajo demanda; Hoy no se convierte en una tabla extensa.
- Los valores iniciales de peso son ejemplos, nunca cargas prescritas para una persona nueva.

## 3. Arquitectura objetivo

```text
widgets → ViewModels → contratos de repositorio / casos de uso
                              ↓
                     dominio puro (reglas/modelos)
                              ↓
              repositorios locales → Drift / servicios de plataforma
```

Vistas: presentación, foco, formularios, navegación y animación. ViewModels: estados y comandos, validación de entrada, bloqueo de envíos duplicados y explicación de errores. Dominio: modelos inmutables, motor de plan, reprogramación, progresión y métricas. Repositorios: lectura/escritura y transacciones. Adaptadores: base de datos, reloj, zona horaria, archivos, tutoriales y notificaciones.

Ampliar los cinco contratos actuales, añadiendo `CardioRepository`, `PlanRepository`, `BackupService`, `NotificationService` y reloj inyectable. Nombres orientativos; documentar sus firmas reales al implementarlos. Los efectos de plataforma se simulan en pruebas unitarias y se verifican también en dispositivo.

Para calendario + sesión + historial, usar una transacción del almacenamiento compartido; coordinar desde caso de uso, no enlazar repositorios entre sí ni encadenar escrituras independientes. Publicar estado confirmado tras commit. Las notificaciones son efectos posteriores: guardar el cambio y una solicitud de reconciliación atómicamente; si el plugin falla, mostrar pendiente y reintentar sin deshacer datos válidos.

### 3.1 Entidades persistentes

IDs opacos estables; referencias por ID, no por nombre ni posición. Timestamps UTC, fecha de calendario local `YYYY-MM-DD` y zona IANA al planificar. `createdAt`, `updatedAt` donde haya edición. PK/FK, índices por fecha/ejercicio y restricciones de unicidad en esquema versionado.

| Entidad | Campos esenciales e invariantes |
| --- | --- |
| Profile | experiencia, objetivo, edad opcional, peso corporal y fecha, equipo disponible, días elegidos, duración objetivo, restricciones declaradas, onboarding/revisión |
| Exercise | nombre, categoría, músculos, equipo, tipo de carga (externa/corporal/tiempo), técnica, calentamiento, alternativas, tutorial verificable y procedencia |
| Routine / RoutineExercise | versión, nombre, posición estable, series, rango de reps, RIR objetivo, descanso, incremento disponible; catálogo separado de prescripción |
| PlanVersion / PlannedSession | inicio de vigencia, tres días, rutina/versiones, excepciones, plan confirmado o borrador; no modificar historial |
| WorkoutSession | ID, fecha, rutina y prescripción congeladas, estado, inicio/fin, origen/reprogramación, nota; legacy sin series reales identificado |
| SessionExercise / SetLog | posición, peso/unidad normalizados, número de serie, reps reales, RIR real nullable 0–10, calentamiento/trabajo, completada/omitida y razón |
| CheckIn | sesión/fecha, cansado/normal/con energía/DOMS/lesionado, nota, área afectada opcional; registrar antes/después por separado |
| Review / Recommendation | período, respuesta, evidencia/razón, versión de regla, propuesta, aceptada/rechazada; una decisión por ID |
| CardioSession / CardioSegment | actividad, intensidad, peso capturado, tiempos/pausas, MET/origen, estimación congelada, estado activo/pausado/completado/descartado |
| Food / FoodEntry / Recipe | cantidad, unidad/base, kcal, macros nullable, fecha, fuente manual, porciones e ingredientes; no confundir desconocido con cero |
| Reminder / NotificationJob | enabled deseado, permiso observado, hora/zona, ID nativo, fecha/sesión, estado programado/pendiente/error; payload sin notas sensibles |
| Migration / BackupMetadata | versión de DB/formato, versión app, fecha, conteos y checksum; no guardar secretos |

Conservar nombre/prescripción congelados al registrar sesiones para que renombrar/borrar un ejercicio del catálogo no rompa historial. Archivar ejercicios/rutinas usados en vez de borrarlos en cascada.

### 3.2 Migración del MVP

1. Detectar `forja_flutter_snapshot_v1`; validar JSON, versión, tipos, rangos y relaciones antes de escribir.
2. Crear esquema/catálogo y traducir snapshot en una transacción: perfil, sesiones, pesos, orden, checklist, check-ins, overrides, alimentos y preferencias.
3. Conservar el estado `completed` antiguo como cumplimiento legacy. Reps/RIR/series reales quedan desconocidos; excluirlos de volumen/progresión. Los pesos de ejemplo no se convierten en rendimientos reales.
4. Confirmar conteos/valores y marcar importación exitosa en DB. Mantener snapshot original para recuperación; siguiente arranque no duplica registros.
5. Una interrupción revierte la transacción. JSON corrupto/versión futura permite error y exportación del original, nunca reset silencioso. Decisión del usuario (2026-10-01): además se ofrece "Continuar sin importar", con confirmación explícita, que deja el original intacto y marca la fuente como omitida. Revisar preferencias de backup de SO por plataforma.

La primera versión de DB y la versión del formato backup son independientes del JSON v1. Cada evolución conserva fixtures del esquema anterior y tests de migración. No usar `dropAll` para una actualización de usuario.

## 4. Requisitos funcionales y aceptación

Cada sección es una unidad trazable. Para cerrarla hacen falta pruebas y evidencia de comportamiento, no solo controles visibles.

### F00 · Persistencia local y recuperación

Implementar la migración y DB anteriores, autosave tras cambios válidos, transacciones y errores recuperables. Comandos idempotentes para finalizar/reprogramar/importar. Guardado fallido conserva último estado confirmado y permite reintentar. Datos con referencias inválidas se rechazan con explicación; no se descartan silenciosamente.

**Aceptación:** snapshot v1 completo → DB sin pérdida; reinicio restaura todo; doble importación no duplica; disco sin espacio/IO fallido no comunica éxito; concurrencia de peso/checklist/reordenamiento no pierde cambios. Tests de migración real SQLite, rollback y nueva apertura.

### F01 · Onboarding y perfil

Preguntas breves en pasos: experiencia, objetivo, días (exactamente tres), equipo, duración disponible y sensación actual. Edad/peso opcionales; explicar por qué se pide peso para cardio. Permitir saltar con plan de ejemplo identificado y completar luego. Sin permiso de notificación hasta que el usuario active recordatorios. Edición validada y revisión mensual conservan historial de respuestas.

**Aceptación:** primer inicio, salto, retomar y editar; límites inválidos y campos vacíos no crashean; peso desconocido → cardio sin kcal estimadas; valores no determinan una carga inicial automática. Cambiar perfil propone un borrador de plan, no borra sesiones.

### F02 · Plan semanal editable

Elegir tres días, generar borrador a partir de experiencia/objetivo/equipo/duración y aceptar. Editor permite nombres, ejercicios, orden, series/reps/RIR/descansos y pesos de referencia. Guardar una versión de plan con vigencia futura; historial conserva snapshots. Biblioteca filtra equipo y sugiere alternativas compatibles con músculos y tipo de movimiento.

Generador 1.0: utiliza plantillas locales versionadas, variantes y tiempos estimados documentados. Reutilizar prescripciones básicas existentes donde corresponda; no afirmar personalización avanzada solo por cambiar rangos. Si no hay equipo/tiempo compatible, devolver una explicación y editor, nunca plan vacío presentado como exitoso.

**Aceptación:** días duplicados rechazados; crear/editar/restaurar borrador; plan confirmado sobrevive reinicio; editar futuro no cambia ayer ni sesión activa; tres sesiones inequívocas por semana y descansos visibles; ejercicios archivados conservan sesiones anteriores.

### F03 · Hoy y registro por serie

Mantener cabecera corta + calendario animado + un resumen + checklist con siguiente ejercicio. Peso/series/reps/RIR visibles, edición rápida, drag desde asa y alternativa mover arriba/abajo por toque y teclado. Panel de series registra repeticiones reales, carga, esfuerzo informado y series de calentamiento/trabajo; datos opcionales desconocidos son explícitos.

Un toque puede marcar ejercicio completado aunque falten métricas: se registra cumplimiento pero no inventa reps ni elegibilidad de progresión. Series explícitamente omitidas se diferencian de realizadas. Completar sesión exige todo ejercicio resuelto (completado u omitido con razón); si hay omitidos el resultado es parcial. Desmarcar sesión completada exige confirmar reapertura; mantiene auditoría y recalcula métricas.

Temporizador de descanso opcional en el panel de series; accesos visibles iniciar/pausar/cancelar, usa mismo servicio de tiempo robusto de F10. Añadir una serie no rompe el layout compacto.

**Aceptación:** guardar serie/editar/omitir/reordenar/desmarcar, unidades/decimales, doble toque y fallos; ningún log cambia de ejercicio al reordenar. En 390×844, tres tarjetas base + finalizar visibles sin scroll y sin quedar cubiertos por navbar; 320 px/texto 200% permite scroll vertical sin recorte ni desplazamiento horizontal global. Nombres largos accesibles completos.

### F04 · Check-in y adaptación de sesión

Fila compacta abre selector y nota y luego muestra respuesta. Distinguir sin respuesta de normal. Antes de empezar: mostrar recomendación junto al resumen; para una sesión activa, proponer ajuste solo a series pendientes, no editar lo ya realizado.

Política de producto inicial: lesión pausa la recomendación de entrenamiento/aumento y ofrece guardar feedback o finalizar. Cansancio/DOMS mantiene lógica conservadora existente (menos series cuando hay más de dos y RIR 3) como propuesta reversible. Energía alta no implica aumentar automáticamente. Nota no se interpreta como diagnóstico.

**Aceptación:** cinco respuestas + sin dato, nota persistida, cancelar/reabrir con foco, revertir propuesta y lesión sin aumento. Pruebas verifican que series ya guardadas y plan histórico no cambian.

### F05 · Ausencia, sesión parcial y reprogramación

`Más opciones` agrupa Falté/No terminé, confirmación con resumen de pendientes y fecha destino. Ausencia reprograma rutina completa; parcial mueve solo pendientes conservando origen y resultado. Buscar fecha libre en próximos 14 días, sin ocupar descanso bloqueado por el usuario ni pisar otra sesión. Propuesta visible antes de aplicar; mover, cancelar y deshacer disponibles mientras destino no iniciado.

Preferir huecos que mantengan descanso entre días de entrenamiento; si no hay hueco compatible, dejar pendientes explícitos y ofrecer elección manual con aviso de conflicto, sin desplazar otra sesión. No penalizar estadísticas contando doble origen/destino. Cadenas de cambios guardan parentesco y no permiten ciclos.

**Aceptación:** completo/parcial/ausente, hueco inexistente, colisión, nueva pulsación idempotente, cruce de mes/año, destino iniciado y deshacer. Una transacción crea excepción y destino; fallo no deja media reprogramación.

### F06 · Biblioteca, calentamientos y tutoriales

Categorías por músculo/equipo, búsqueda tolerante a acentos, filtros, descripción/técnica, calentamiento específico y alternativas. La búsqueda YouTube actual se mantiene como fallback identificado. Incorporar `tutorialUrl` opcional a Short real solo tras verificar contenido, autor y pertinencia; enlace normal HTTPS de YouTube. No inventar IDs ni descargar/copiar vídeos. Catálogo y licencias versionados localmente; funciona sin conexión excepto vídeo.

**Aceptación:** búsqueda vacía/sin resultado, catálogo completo, alternativas compatibles, enlace válido abre externamente, fallo ofrece copiar/reintentar y búsqueda fallback. Todos los ejercicios utilizables tienen descripción, músculos y calentamiento; ninguna tarjeta promete un Short específico sin URL comprobada.

### F07 · Minicoach y revisión mensual

Onboarding y revisión cada 30 días desde última revisión aceptada; mostrar acceso discreto, posponer siete días y sin bloquear Hoy. Recoger adherencia, energía, dolor/DOMS, dificultad, objetivo y cambios de equipo/días. Presentar explicación con comparación plan actual/propuesto y aceptar/rechazar. Cambios afectan solo fechas futuras no iniciadas. Mantener historial y versión de reglas. Funciona offline, sin llamadas a IA.

**Aceptación:** reloj inyectado prueba vencimiento/posponer/cambio de mes, datos insuficientes, rechazo sin cambios, aceptación idempotente, review persistida, historial inmutable. Lesión y fatiga no producen propuestas de incremento.

### F08 · Progresión de peso e intensidad

Motor por ejercicio, exclusivamente series de trabajo completas con reps/RIR reales y técnica autoevaluada, misma variante/equipo y esquema comparable. Algoritmo v1 de producto: dos exposiciones elegibles consecutivas alcanzan extremo superior del rango en todas las series con RIR al menos objetivo → sugerir un incremento mínimo configurado. Si falta incremento o esfuerzo/datos, sugerir mantener y completar datos. No aplicar automáticamente.

No recomendar aumento con lesión, DOMS/cansancio registrados o técnica marcada inestable en cualquiera de las exposiciones. Dos exposiciones por debajo del mínimo muestran revisar carga/técnica; no calcular una reducción prescrita automáticamente. Fallo/RIR 0 es registro de esfuerzo, no objetivo obligatorio para principiantes ni motivo de aumento.

Para cardio, sugerir revisar duración/intensidad solo cuando haya historial comparable y feedback normal; el usuario elige el cambio en editor. Sin porcentaje fisiológico automático ni fecha garantizada para progresar.

**Aceptación:** tabla de decisiones y fixtures de datos completos/incompletos/legacy, unidades y variaciones. Explicación muestra sesiones, regla, incremento y dato faltante. Rechazar/aceptar persiste, doble aceptación no suma otra vez, no altera sesiones pasadas. Reglas son heurísticas de organización y deben revisar su contenido antes de release.

### F09 · Progreso y estadísticas

Historial por fecha/ejercicio con estados completo/parcial/ausente y filtros semana/mes/rango. Cumplimiento: sesiones completas / sesiones planificadas ya vencidas; parciales y ausencias separadas, sin contar fechas futuras ni duplicar reprogramadas. Mostrar numerador/denominador y política. Recalcular tras editar/reabrir/importar.

Volumen externo: suma kg × reps reales de series de trabajo completas con carga externa; excluir calentamiento, corporal/tiempo, datos desconocidos y registros legacy. No denominar volumen a la suma simple actual. Mostrar kg·reps y porcentaje de registros con datos suficientes. Evolución de cargas/reps por variante, marcas personales observadas y cardio/nutrición en vistas separadas; sin predicción de fuerza máxima necesaria para 1.0.

**Aceptación:** fórmulas con fixtures auditables, rangos/zonas/ausencias/parciales/reprogramación, carga corporal/legacy excluidas y sin datos distinto de cero. Gráficas monocromáticas con etiquetas y alternativa de tabla accesible; todas las métricas derivan de registros reales.

### F10 · Cardio y temporizadores resistentes al ciclo de vida

Actividad/intensidad, iniciar/pausar/continuar/finalizar/descartar, duración objetivo opcional, calorías aproximadas y feedback posterior. Persistir sesión activa y segmentos; al navegar/background no depender de `Timer.periodic` para contar tiempo. Timer solo refresca UI. Guardar inicio UTC y duración acumulada; usar reloj monotónico durante proceso; ante reinicio reconstruir desde timestamps, detectar reloj regresivo/salto y pedir corregir duración si es incoherente. No prometer ejecución continua de Dart en background.

Capturar peso e intensidad en cada segmento; editar perfil no cambia kcal de sesiones terminadas. MET por actividad/intensidad en tabla versionada con procedencia revisada. Fórmula conservada: kcal ≈ MET × kg × horas, redondear solo presentación y explicar aproximación. Sin peso → duración registrada y kcal no disponibles. Finalizar guarda historial una sola vez; discard requiere confirmación.

**Aceptación:** restart/background/pausa larga/pantalla bloqueada/cambio de reloj, finalización doble, intensidad segmentada, peso desconocido y estimación fixture. Prueba nativa ciclo de vida y duración; no exigir permisos/background service para un contador reconstruible. Se puede reutilizar en descanso de series.

### F11 · Notificaciones locales nativas

Solicitar permiso al activar recordatorios y mostrar estado real del SO separado del deseo guardado. Hora configurable; programar próximas sesiones en un horizonte móvil de 28 días, reconciliar al abrir/reanudar y al modificar plan/reprogramar/horario/zona. Cancelar al desactivar, completar o quitar sesión. IDs estables sin colisiones, payload sesión/fecha; tocar abre la sesión correcta aun desde arranque frío.

Android: canal de entrenamiento, permiso runtime donde corresponda, reinicio del teléfono y restricciones del SO. iOS: autorización, solicitudes futuras y permisos revocados. Planificar notificaciones locales sin push/backend; no exigir alarmas exactas para un recordatorio no crítico. El SO puede retrasarlas y la UI no garantiza puntualidad absoluta. Revisar capacidades del plugin elegido y límites nativos antes de implementarlo; no asumir que background repuebla calendario indefinidamente.

**Aceptación:** permitir/denegar/revocar, editar hora/fecha, DST/zona, no duplicados, cancelación, restart/arranque frío y tap destino en ambas plataformas. Mock demuestra intención, dispositivo demuestra programación/recepción según condiciones y límites registrados.

### F12 · Nutrición y recetas locales

Mantener registro manual rápido de kcal; extender alimentos con porción/unidad y macros opcionales. Historial diario, editar/borrar/deshacer, favoritos y recetas con ingredientes y porciones. Objetivos kcal/macros manuales opcionales, comparación de consumo registrado y objetivo. No presentar alimentos faltantes como cero consumo ni macros faltantes como 0 g. No deducir déficit real de una estimación de cardio.

Recetas propias o contenido con licencia/procedencia, filtros por preferencia declarada y alérgenos etiquetados cuando conocidos; desconocido se muestra, no se garantiza seguridad clínica. Inspirarse en patrones de interacción de otras apps sin copiar sus contenidos protegidos ni APIs privadas. Calorías de una entrada manual prevalecen como dato explícito; si se deriva de macros, indicar fórmula/origen, no sobrescribirlas silenciosamente.

**Aceptación:** porciones fraccionarias, kcal sin macros, suma de receta/porción, cambio de fecha, favoritos/reinicio, edición atómica y entrada inválida. Objetivo ausente no genera consejo automático. Tests del formulario y de cálculos con datos conocidos/desconocidos.

### F13 · Backup, importación y privacidad

Exportar JSON versionado completo desde una lectura consistente; metadatos/checksum para detectar corrupción, aviso de que contiene datos personales y selección explícita de archivo/destino. Checksum no es cifrado. No enviar por red ni activar copia automática. Formato interoperable Android/iOS con IDs, unidades y fechas estables, sin caches/rutas/IDs nativos de notificación.

Importar 1.0 en modo reemplazo (merge no requerido): límite 20 MiB, validar versión/checksum/estructura/rangos/referencias/conteos, preview y confirmación. Exportar respaldo previo recuperable antes de reemplazar; si falla respaldo, detener. Reemplazo en transacción, sin modificar DB ante archivo inválido o fallo IO. Reconciliar notificaciones usando ajustes/permisos del dispositivo actual; no trasladar permisos del otro teléfono. JSON legacy del prototipo web no se importa; snapshot Flutter v1 tiene importador propio F00.

Eliminar todos los datos desde ajustes requiere confirmación clara, cancela recordatorios y devuelve onboarding. La DB no se anuncia como cifrada: archivos en sandbox privado; excluir datos sensibles de backups automáticos del SO según política local elegida y documentada, mantener exportación explícita. No registrar notas/perfiles en logs.

**Aceptación:** ida/vuelta completa entre plataformas, versión futura/corrupción/archivo enorme/cancelación, fallo después de preview, rollback y reinicio; reset elimina datos y jobs reales. No import/export silencioso.

### F14 · UI, accesibilidad y entrega móvil

Conservar tema actual: fondo `#090909`, superficie `#191919`, papel `#F4F4F1`, texto `#F5F5F3`, secundario `#C4C4C0`, tinta `#111111`. Tipografías/assets locales. Radios coherentes por rol (inputs 12, botones 14; conservar geometría actual de tarjetas/paneles/navbar y centralizar cuando se toque). Errores/estados también monocromáticos con texto/símbolo.

Contraste texto normal ≥4.5:1, componentes/indicadores necesarios ≥3:1. Texto informativo ≥14 px lógicos y control táctil mínimo actual 44×44; para nuevos controles usar 48×48 dp en Android/44×44 pt en iOS sin reducir los existentes. SafeArea/teclado/system back, orden de foco y devolución al abrir/cerrar paneles, semántica, TalkBack/VoiceOver y movimiento reducido. No fijar alturas que recorten texto al 200%; scroll vertical cuando sea necesario.

Build/debug y release verificables en Android/iOS, iconos/splash nativos de FORJA, identifiers/versiones documentados, firma release correcta fuera del repo, sin claves debug como distribución productiva. CI para analyze/tests, compilación Android y job macOS para iOS; si no hay runner macOS dejar gate pendiente. Revisar dependencias/licencias y permisos declarados. El soporte web se retiró el 2026-10-01 por decisión del usuario (D08 en IMPLEMENTACION): no hay build web ni preview.

Diseño adaptable (D33, 2026-10-02): teléfonos y tablets en vertical y horizontal, sin desplazamiento lateral ni texto recortado; dos columnas cuando caben (640 px de contenido × tamaño de texto, hasta ×1,6), contenido centrado con máximo 1200 px, columnas legibles; barra inferior en vertical y riel lateral con la gota cuando la pantalla es más ancha que alta, con los cinco destinos visibles a texto normal desde 320 px de alto; las etiquetas de navegación nunca se parten y no se tocan (D35); cada sección conserva su propio nodo de accesibilidad.

**Aceptación:** matriz de tamaños/estados de TESTING (incluida la de teléfono/tablet en vertical y horizontal), perfil de rendimiento en dispositivo documentado y sin regresión visible de scroll/drag/navbar; navegación/teclado/lifecycle accesibles. Instalar y recorrer flujos críticos en Android e iOS. AAB/archivo iOS de release con evidencia de firma preparada, sin subirlos a tiendas automáticamente.

### F15 · Racha de entrenos

Pedida por el usuario el 2026-10-02 (D36). Racha de días de entrenamiento del plan con reglas locales y explicables `streak-v1`: suma cada día planificado en el que se entrena (sesión completa, parcial o con algún ejercicio marcado o serie hecha); los descansos son neutros; un día planificado que termina sin actividad la rompe, salvo que se haya reprogramado (cuenta el día destino); el día de hoy no cuenta en contra hasta que acaba; solo se juzga desde el primer entreno o la primera falta marcada (un día guardado sin nada hecho, como un peso editado, no inicia el conteo). Se calcula de los datos existentes, sin esquema nuevo. Llama naranja con el número en la barra superior (gris si hoy toca entrenar o no hay racha); al tocarla, página con la racha actual y la mejor, calendario mensual (llama por día entrenado, ✕ falta, reprogramado, planificado, hoy marcado), mapa de calor anual (53 semanas × 7 días, en dos bloques en teléfono) y tabla equivalente por mes. La llama parpadea al aparecer, al crecer la racha y al tocarla, y luego reposa; con movimiento reducido no se mueve. El naranja es la única excepción al monocromo y solo se usa en la llama y el mapa.

**Aceptación:** reglas probadas con fechas fijas (descanso, falta, parcial, actividad, reprogramado y deshecho, hoy, futuro, antes de empezar, conteo por periodo); ViewModel (semana desde lunes, semanas del año, celebración al crecer); insignia y página con semántica por día, tabla accesible del mapa, guías de objetivo/etiqueta/contraste, contraste ≥ 3:1 del naranja donde se dibuja, animación finita y movimiento reducido; teléfono, horizontal y tablet sin desbordes.

## 5. Estados e invariantes compartidos

- Datos: loading → ready/empty/error; error incluye reintentar y nunca reset implícito.
- Sesión: scheduled → inProgress → completed/partial/missed; missed solo sin actividad real. Reapertura explícita genera cambio auditado; repetir finalize con mismo ID no duplica historial/destino.
- Borrador de plan: draft → accepted/rejected. El aceptado crea versión, no muta anterior.
- Cardio: idle → running ↔ paused → completed/discarded; un único registro activo; cero duración no se guarda como realizado.
- Recomendación: proposed → accepted/rejected/superseded. No aplicar propuesta obsoleta sobre plan cambiado.
- Las fechas semanales son civiles locales: no calcular siguiente día sumando ciegamente 24 horas UTC. DST y cambio de zona tienen política explícita. Histórico conserva fecha de entrenamiento registrada.
- Cantidades finitas y no negativas; reps enteras positivas cuando realizadas, peso 0 permitido para corporal/sin carga. Campo vacío es null, no 0. Validaciones en UI y dominio/DB.
- Cierre de app tras commit no pierde datos; cierre antes de terminar formulario conserva solo lo confirmado y comunica borrador recuperable si lo implementa.

## 6. Secuencia de entrega y trazabilidad

Orden recomendado: F00 → F01/F02 → F03/F04/F05/F06 → F07/F08/F09 → F10/F11 → F12/F13 → cierre F14. F14 y regresiones acompañan todas las fases. Detalle de paquetes y evidencias en [IMPLEMENTACION.md](IMPLEMENTACION.md).

Una feature pasa de pendiente a en curso, implementada, verificada y cerrada. `Bloqueada` registra condición externa y siguiente acción, sin falsear éxito. Cierre requiere criterios, pruebas del nuevo comportamiento, regresiones relevantes y docs actualizadas. Esta entrega documental no inicia automáticamente la implementación de estas fases.

## 7. Calidad, riesgos y gates de release

[TESTING.md](TESTING.md) define escenarios y comandos. Gates: analyze limpio; suite unitaria/widget verde; DB/migración/backup reales; integración nativa de notificaciones/lifecycle; accesibilidad manual TalkBack/VoiceOver; builds Android/iOS y smoke instalados; ningún bug abierto que impida flujos principales, corrompa datos o incumpla requisitos; limitaciones menores documentadas.

Riesgos prioritarios: pérdida de datos al migrar/importar (transacciones/fixtures); duplicación al reprogramar (idempotencia/parentesco); sugerencias con datos insuficientes (eligibilidad explícita); timer dependiente de proceso (timestamps/reconstrucción); recordatorio con permiso revocado (estado observado/reconciliación); web verde pero móvil roto (gates nativos); nuevo modelo confundiendo objetivo/estado (contexto y matriz con evidencia).

Los algoritmos de entrenamiento, estimaciones y recetas necesitan revisar contenido y procedencia antes de distribuir; documentar supuestos y límites dentro del producto cuando afectan la decisión del usuario. No introducir permisos ni infraestructuras que el alcance no necesita.

## 8. Fuentes técnicas y decisiones

Consultadas para esta especificación el 2026-09-30; confirmar versión y documentación del SDK/plugin real al implementar. Las reglas específicas de FORJA son decisiones de producto, no recomendaciones atribuidas a estos proveedores.

- Separación Vista/VM/repositorios: [Flutter architecture](https://docs.flutter.dev/app-architecture/guide).
- Pruebas por nivel: [Flutter testing](https://docs.flutter.dev/testing/overview).
- Esquema y migraciones verificables: [Drift migrations](https://drift.simonbinder.eu/migrations/).
- Permisos de notificación: [Android notification permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission).
- Solicitudes locales: [Apple UserNotifications](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app).
- Entrega: [Flutter Android release](https://docs.flutter.dev/deployment/android), [Flutter iOS release](https://docs.flutter.dev/deployment/ios).
- Accesibilidad: [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility), [WCAG 2.2](https://www.w3.org/TR/WCAG22/).

### Desviaciones y decisiones registradas durante la implementación (2026-10-01)

El SDD es la referencia técnica; estas decisiones del usuario o de implementación lo matizan y están razonadas en [IMPLEMENTACION](IMPLEMENTACION.md) (D08–D32): sin soporte web (D08); catálogo y plan de ejemplo en código, no en tablas (D09/D14); «Continuar sin importar» al fallar la importación 0.1 (D10); sin commits de Git (D12); aceptar una progresión crea una carga de trabajo para sesiones futuras en lugar de editar versiones de plan (D21); técnica autoevaluada como dato nuevo (D22); tabla MET `met-v1` sin contrastar con la fuente (D26); respaldo solo en modo reemplazo con copia previa privada (D29); versión `0.9.0` y release de Android sin clave rechazado (D31); riel lateral en horizontal (D33); iOS y TalkBack aplazados por el usuario (D34); racha de entrenos con llama naranja como única excepción de color (D36, F15). Las reglas `prog-v1` y `review-v1` y la tabla MET son heurísticas de organización que deben revisarse antes de publicar (F07, F08, F10).

