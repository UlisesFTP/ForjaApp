# Cambios

## 2026-10-07 · sin rutina de ejemplo; planes de 1 a 7 días (D45)

- **Una instalación nueva ya no trae rutina:** Hoy y Plan dicen «Aún no tienes un plan» con «Crear mi plan». Saltar el perfil ya no da un plan de ejemplo. Quien ya entrenó con la plantilla antigua la conserva solo en esos días pasados.
- **Planes de 1 a 7 días** (antes exactamente tres): el editor añade y quita días. El generador sigue proponiendo tres.
- Nuevo ejercicio: **Remo con apoyo en el pecho**.
- Plan sin empezar: Plan muestra cuándo empieza y Hoy el siguiente entrenamiento.
- Pruebas: 895 → 904.

## 2026-10-07 · recordatorios verificados en segundo plano (F11)

- **Corregido:** en un teléfono con formato de 12 horas, escribir «08» en «Hora preferida» guardaba 20:00 si la hora anterior era de tarde (el selector se ve en 24 horas). Ahora se interpreta como se ve.
- Verificado en el teléfono: el aviso llega con la app cerrada, sobrevive a una actualización sin abrirla y al tocarlo abre el día.

## 2026-10-07 · botones con icono y color de acción (D44)

- **Colores de acción** en los botones clave, siempre con icono y texto (el color nunca va solo): **verde** para confirmar (completar sesión, guardar serie/alimento/receta/objetivos/check-in, aceptar aumento o plan, aceptar y activar, guardar clave, iniciar cardio), **amarillo** para precaución (omitir serie o ejercicio, «ahora no», posponer, rechazar, salir sin guardar, «No terminé» y «Falté») y **rojo** para destructivas (eliminar clave, borrar todo y todos mis datos, reemplazar mis datos, eliminar receta, descartar borrador o sesión de cardio y las papeleras). Botones **compactos** (40 px visibles, zona táctil de 48 px) de **color sólido** con icono y texto **blancos**: verde `#15803D`, amarillo oscuro `#A16207` (el texto blanco no se lee sobre un amarillo brillante) y rojo `#DC2626`, iguales en tarjetas oscuras y claras.
- **Hover, foco y pulsado:** el relleno se oscurece al pasar el ratón o enfocar con teclado, con un contorno claro (más grueso con el foco), y más al pulsar; cursor de mano. Los botones sin color también reaccionan (tema). En el teléfono no hay hover: se nota el pulsado y el foco.
- Los demás botones (Cancelar, Atrás, Por qué, Probar conexión, exportar…) siguen en blanco y negro. Claves, etiquetas y tipos de botón no cambian.
- Pruebas: 870 → 894. Contraste medido: texto blanco ≥ 4,5:1 sobre el relleno en reposo, hover, foco y pulsado, y relleno ≥ 3:1 frente al fondo, las tarjetas y el papel. «Omitir serie» comparte la fila con «Guardar serie» para que el texto grande no desborde.

## 2026-10-07 · ajustes del asistente IA más accesibles y con más proveedores (F17)

- **Pantalla del asistente rehecha:** el estado y el interruptor arriba con una frase que dice el siguiente paso; después, «Paso 1 · Proveedor y modelo», «Paso 2 · Tu clave» y «Paso 3 · Probar la conexión». Funciones, datos que puede consultar, tope diario y dirección quedan en «Más opciones». Cada error aparece justo debajo de la acción que lo causó, y «Probar conexión» dice por qué está desactivado.
- **Menús de proveedor y modelo:** filas grandes que abren una lista de opciones con nombre, descripción y una nota («Rápido y barato · recomendado»); «Otro modelo…» deja escribir cualquier identificador. Elegir otro modelo no pide volver a consentir; otro proveedor o dirección, sí.
- **Más proveedores:** OpenCode Go (por defecto), OpenCode Zen, OpenAI, Google Gemini, DeepSeek, Mistral, Groq, OpenRouter, Xiaomi MiMo y «Otro (compatible con OpenAI)». Cada uno trae su dirección, sus modelos populares, dónde conseguir la clave y lo que dice sobre alojamiento y retención (los niveles gratuitos que pueden entrenar con tus datos se avisan). Los modelos «-free» y «:free» siguen rechazados.
- El cliente adapta la petición al proveedor: `max_tokens` o `max_completion_tokens` según el que lo pida, sin `temperature` en OpenAI, y la cabecera de sesión solo en OpenCode.
- Pruebas: 858 → 870. Corregidos dos fallos vistos en el teléfono: la fila de Más decía «Desactivado» tras un arranque en frío y «Describir comida (IA)» fallaba con OpenCode por no enviar una sesión. Los identificadores de modelo se tomaron de las listas públicas de OpenCode y OpenRouter; no se probaron con una clave de cada proveedor.

## 2026-10-02 · asistente IA opcional con herramientas internas (F17)

- **Asistente IA opcional** (Más → Asistente IA), desactivado por defecto y con **tu propia clave**: OpenCode Go con `mimo-v2.6-flash` por defecto, la API directa de Xiaomi MiMo o cualquier proveedor compatible con OpenAI por `https`. La clave solo se guarda en el almacenamiento seguro del teléfono. Antes de activarlo, un consentimiento explica a quién se envía, qué puede consultar (con un interruptor por categoría) y el riesgo de usar Go fuera de la programación.
- **Describir comida (IA):** en «Añadir alimento», describe lo que comiste y el asistente estima calorías y macros; revisas los valores y los guardas como «kcal estimadas (IA)». Solo se envía lo que escribes.
- **Chat del minicoach:** «Preguntar al asistente (IA)» en la página del minicoach. Consulta tus datos con herramientas internas de FORJA (con forma MCP, sin servidores externos), dice qué miró y cuántos tokens usó, y solo propone (una comida que revisas en el formulario, o un consejo del minicoach). Con una lesión registrada, avisa «Sin aumento». La conversación se borra al cerrar.
- **Sin el asistente, la app no usa Internet.** El permiso INTERNET existe solo para él; Android 12+ excluye además los datos de las copias y transferencias del sistema. Borrar todo elimina también la clave.
- Corregido: una clave guardada justo al abrir el asistente podía borrarse sola; el selector del tope diario se desbordaba con texto grande; en todas las páginas, un título de una sola palabra («EJERCICIOS») se partía a mitad de palabra en pantallas estrechas con texto grande.
- Pruebas: 802 → 858 (ninguna usa la red).

## 2026-10-02 · sistema experto local en el minicoach (F16)

- **Minicoach con sistema experto `expert-v1`:** 30 reglas locales y explicables (seguridad, preparación, progresión, plan y volumen, constancia, cardio, nutrición y registro). Cada consejo dice en qué datos se basa, con qué regla, versión y respaldo (alta, media o heurística). Nada se aplica solo. La página se abre desde «Minicoach» en Hoy y en Más; Plan tiene «Revisión del plan». «Ahora no» oculta un consejo unos días; cada tipo (salvo seguridad) se puede ocultar.
- **Seguridad:** una lesión o dolor de los últimos 14 días, o una pausa de 3 semanas sin hacer un ejercicio, bloquean cualquier aumento, también en Progreso, donde ahora sale «Sin aumento: …» sin botón de aceptar.
- **Comportamiento por defecto:** el plan de ejemplo compara la progresión con lo que muestra Hoy (`prog-v2`); un plan generado ya ligero no se aligera otra vez por la energía habitual; Hoy muestra la duración estimada de la rutina y avisa al volver tras una pausa.
- **Nutrición:** sin objetivos, una referencia general de proteína (no una dieta); una estimación del futuro asistente IA sigue marcada como «kcal estimadas (IA)» aunque se cambie el nombre o se guarde como favorito.
- **Datos:** esquema 7 (decisiones del coach, tipos ocultos, origen de las kcal de los favoritos) con migración probada; copias de seguridad versión 2 (se siguen leyendo las de versión 1).
- **Corregido:** a 320 px con el texto al 200 % la marca de la barra superior se desbordaba cuando la racha mostraba un número.
- Pruebas: 712 → 802.

## 2026-10-02 · racha de entrenos (F15)

- **Racha** con llama naranja animada en la barra superior (gris si hoy toca entrenar o aún no hay racha). Cuenta los días de entrenamiento del plan: completos, parciales o con algo hecho; los descansos no la rompen y una falta reprogramada tampoco (reglas `streak-v1`, explicadas en la propia página).
- **Página de racha**: racha actual y mejor, calendario mensual con una llama por día entrenado, mapa de calor anual (53 semanas) y tabla por mes para lectores de pantalla. En tablet, dos columnas.
- El naranja es la única excepción al monocromo y solo vive en la llama y el mapa. La llama parpadea al aparecer, al crecer la racha y al tocarla; con movimiento reducido no se mueve.
- Comprobada en el teléfono; corregido allí que un día guardado sin nada hecho (un peso editado) contara como la primera falta, y el mensaje de descanso con racha 0.
- Pruebas: 689 → 712 (`test/streak_test.dart`).

## 2026-10-02 · barra de navegación mejor repartida

- Los elementos de la barra ya no ocupan un quinto fijo: «Progreso» y «Ejercicios» tienen el sitio que necesitan y los iconos siguen casi equidistantes. Las etiquetas nunca se parten («Progres/o», «Pro/gres/o» a 320 px) y con texto grande la barra ya no ocupa un tercio de la pantalla. La gota sigue el centro real del elemento. El riel limita sus etiquetas a 140 %.
- TalkBack: comprobado desactivado en el teléfono.
- Pruebas: 672 → 689 (`test/navbar_test.dart`).

## 2026-10-02 · diseño adaptable a teléfonos y tablets (F14)

- La app ya no es una columna de 480 px en pantallas grandes. Teléfono vertical: igual que antes. Desde 640 px de contenido (más con texto grande): Hoy con resumen y check-in junto a los ejercicios; Plan, Progreso, Cardio y Nutrición en dos columnas; Ejercicios en cuadrícula de hasta 3; Más en una columna centrada; paneles hasta 600 px y editor de plan hasta 760 px.
- **Riel lateral con la gota** cuando la pantalla es más ancha que alta (decisión del usuario): misma forma y animación de pie a la izquierda; cabe entero desde 320 px de alto. En tablet vertical la barra inferior queda centrada con ancho de teléfono.
- Corregido al probar en el teléfono: en dos columnas una columna entera era un solo nodo para el lector de pantalla; el recorte de la cámara en horizontal desplazaba cada `ListTile`; la hora de la barra de estado no se leía en horizontal; el riel no cabía en 640×360.
- Barras de Progreso con ancho máximo (una sola sesión ya no es una barra de toda la tarjeta); semana de Hoy centrada en pantallas anchas.
- Pruebas: 626 → 672 (`test/responsive_test.dart`). Herramienta de capturas `tool/capture_screens_test.dart`. iOS/iPad, tablet física y TalkBack siguen pendientes (aplazados por el usuario).

## 2026-10-01 (tarde) · recorrido en teléfono real y correcciones

- Recorrido en un Android real desbloqueado de nutrición, exportar/importar con el selector del sistema (copia alterada rechazada), eliminar todo (0 alarmas) con restauración (11 recordatorios) y cardio en segundo plano y tras la muerte del proceso. Detalle en `docs/VALIDACION.md`.
- Corregido: error de calorías obsoleto en «Añadir alimento»; etiquetas truncadas en alimentos y recetas; exportar/importar no mostraban confirmación visible (el aviso quedaba bajo la hoja): ahora se escribe en el panel; «1 sesiones» → singular; el nombre del archivo exportado usa la fecha local y no la UTC.
- Recordatorios verificados en el teléfono con ahorro de batería (entrega con ≈5 min de retraso) y con un cambio de horario de verano real simulado por zona (`Europe/London`).
- Perfil de rendimiento en un teléfono de 120 Hz (`integration_test/perf_test.dart`, build profile, almacén en memoria): desplazamientos sin fotogramas de más de 33 ms; hallazgo abierto de un fotograma de ≈169 ms al cambiar de pestaña. Dependencia de desarrollo `integration_test` (SDK).
- Cambio de pestaña: las siete pantallas del `IndexedStack` se reconstruían en cada cambio; ahora se crean una vez (`test/shell_rebuild_test.dart`). Medido en el teléfono: peor fotograma al cambiar de pestaña 168,7 → 29,2 ms.
- La app quedó desinstalada del teléfono de pruebas tras `flutter drive` (datos de prueba perdidos); pasos de reinstalación en VALIDACION.
- Verificado en el teléfono (2026-10-02): reinicio con recordatorios (12 alarmas reprogramadas sin abrir la app) y cardio con la pantalla bloqueada (02:19 correcto). TalkBack se activó por `adb` pero no se puede leer lo que anuncia.
- Pruebas: 624 → 626. iOS y TalkBack con una persona escuchando siguen pendientes.

## 2026-10-01 · P7 · entrega móvil y cierre de la secuencia (F14)

- **Accesibilidad probada**: contraste WCAG de la paleta; las guías de Flutter de tamaño de objetivo (44 pt), etiquetas y contraste de texto se ejecutan en las siete pantallas y en los paneles de series y recordatorios. Hallazgo corregido: los iconos de los botones usaban un color por defecto demasiado tenue sobre el fondo oscuro (ahora el color de texto del tema) y la fecha de semana del Plan usa el estilo de título.
- **Android**: icono adaptativo, pantalla de arranque con la marca (Android 12+ incluido) e icono monocromático de notificación; `allowBackup=false`.
- **Firma de release**: se retira la firma con la clave de depuración. Sin `android/key.properties` (fuera del repositorio, con `key.properties.example`) un release se **rechaza**; `FORJA_ALLOW_DEBUG_SIGNING=1` permite una prueba local no distribuible. R8 activo con reglas para el plugin de notificaciones; el release (66.8 MB) se instaló y arrancó 10 s en un teléfono sin excepciones.
- **iOS**: imagen y fondo de arranque con la marca (sin ver en dispositivo).
- **Licencias** (Más → Licencias): paquetes y texto OFL de las fuentes. Documento nuevo `docs/ENTREGA.md` (identificadores, firma, permisos, dependencias y licencias, CI).
- **CI** (`.github/workflows/ci.yml`, sin ejecutar): format, analyze, código generado sin diferencias, pruebas, Android debug/release (compilación, no se sube) y comprobación de release sin clave, iOS en macOS sin firma. Nunca publica.
- **Barrido de documentación**: README, ALCANCE, ARQUITECTURA_MVVM, TESTING, CONTEXTO, IMPLEMENTACION y SDD reflejan lo real (incluida la lista de pendientes). Versión `0.9.0+2`: candidata, no 1.0.
- Pruebas: 599 → 624 (accesibilidad, entrega y secretos).

## 2026-10-01 · P6 · nutrición y respaldo (F12, F13)

- **Esquema v6** con migración verificada (también en el teléfono): porción y macros por alimento, favoritos, recetas con ingredientes y objetivos. Los alimentos existentes conservan sus calorías como número manual; porción y macros quedan **desconocidos (null), nunca 0**.
- **Nutrición (F12)**: alimento rápido (nombre + kcal) o con porción/unidad y macros opcionales; las calorías escritas a mano mandan y no se cambian solas; «Calcular kcal desde macros» (4·P + 4·C + 9·G, solo con los tres) las rellena de forma visible y la entrada lo indica. Historial por día (anterior/siguiente), editar de forma atómica, eliminar con **Deshacer**, favoritos de un toque, recetas propias (ingredientes, porciones fraccionarias, totales solo si todos los ingredientes tienen el dato), etiquetas y alérgenos declarados (sin declarar ≠ ninguno; el filtro «sin X» deja fuera lo no declarado), registrar porciones de una receta, objetivos manuales opcionales (sin objetivo no hay comparación ni consejo), totales de macros con cobertura («de 1 de 2 alimentos con dato»). Nada se deduce del cardio.
- **Copia de seguridad (F13)**: JSON versionado (`forja-backup` v1) con recuento y SHA-256 (detecta daños, no cifra), generado desde una lectura consistente; el usuario elige dónde se guarda y se le avisa de que contiene datos personales. Importar **reemplaza** todo: valida tamaño (20 MiB), versión, checksum, estructura, rangos, referencias y conteos (los mensajes nombran la ruta, nunca el valor), muestra una vista previa, guarda antes una copia previa privada (últimas 3; si falla, no se cambia nada) y reemplaza en una transacción con comprobación de lectura; cualquier fallo revierte. **Eliminar todos los datos** exige escribir BORRAR, vacía la base, borra las copias previas, cancela los recordatorios y reabre el onboarding (el marcador de importación 0.1 se conserva). `allowBackup=false` en Android.
- Se corrige un fallo real hallado por la prueba aleatoria: al cambiar una serie de trabajo a calentamiento no se guardaba su tipo.
- Dependencias nuevas: `crypto` (SHA-256), `file_picker` (elegir/guardar archivo; Android compiló sin cambios).
- Pruebas: 481 → 599.

## 2026-10-01 · P5 · tiempo y notificaciones (F10, F11)

- **Esquema v5** con migración verificada (también en el teléfono): sesiones de cardio y sus tramos.
- **Cardio persistente (F10)**: iniciar, pausar, continuar, cambiar de intensidad, finalizar (una sola vez) y descartar con confirmación; objetivo opcional con cuenta atrás; historial con tramos, sensación y nota. El tiempo se **reconstruye de marcas de hora UTC** (suma de tramos); `Timer.periodic` solo refresca la pantalla. Reloj monotónico mientras la app vive (un cambio de hora del teléfono no altera la sesión); tras un reinicio, un reloj retrocedido o una sesión de más de 12 h se detectan y piden la duración real. Peso e intensidad se guardan por tramo (editar el perfil no cambia sesiones terminadas); kcal ≈ MET × kg × horas con tabla `met-v1` (sin peso: solo duración). Se elimina "Reiniciar" y el cronómetro volátil.
- **Temporizador reutilizable**: `lib/core/elapsed_timer.dart` (marcas de hora) se usa también en el descanso entre series.
- **Recordatorios nativos (F11)**: `flutter_local_notifications` detrás de `NotificationService`; avisos locales sin push, programación inexacta (sin permiso de alarma exacta). Ventana móvil de 28 días recalculada al abrir/reanudar y al cambiar plan, sesiones, reprogramaciones u hora; solo se aplica la diferencia (ids = fecha, sin duplicados). Se cancela al completar/quitar/mover la sesión. Estado real del sistema (permiso, programados, próximo) separado del deseo guardado; pedir permiso, abrir ajustes y aviso de prueba. Tocar un aviso abre ese día en Hoy, también desde arranque en frío. Android: receptor de arranque y desugaring; iOS: delegado preparado, sin compilar.
- Pruebas: 401 → 481.

## 2026-10-01 · P4 · progresión y coach (F07, F08, F09)

- **Esquema v4** con migración verificada (datos reales de la v3): técnica autoevaluada por ejercicio, decisiones de progresión (clave única por sugerencia), revisiones mensuales (solo se añaden), aplazamiento de la revisión y versión de reglas en el historial del perfil. Nada del pasado se inventa: la técnica empieza sin valorar.
- **Progresión (F08, reglas `prog-v1`)**: por ejercicio y solo con series de trabajo reales (repeticiones, RIR, carga y técnica). Dos sesiones seguidas en el extremo superior con el RIR previsto o más → sugerir el incremento del plan; faltan datos → mantener y listar lo que falta; lesión, cansancio/DOMS o técnica inestable → sin aumento; dos sesiones bajo el mínimo → revisar carga y técnica (sin calcular una bajada). Nunca se aplica sola: aceptar/rechazar queda registrado una vez; aceptar fija la carga de las sesiones que aún no existen sin tocar las pasadas ni el plan. La explicación muestra sesiones, regla, incremento y datos que faltan.
- **Revisión mensual (F07, reglas `review-v1`)**: se ofrece a los 30 días de la última (reloj inyectable), se puede posponer 7 días y no bloquea Hoy. Resumen del mes, respuestas (energía, dolor, dificultad, objetivo, días, equipo, tiempo), propuesta explicada con comparación del plan, aceptar (perfil + borrador, en una transacción) o rechazar sin cambios. Datos insuficientes → sin propuesta de volumen o carga. Dolor, lesión, fatiga o "difícil" → ningún aumento.
- **Progreso (F09)**: rango semana/mes/todo; cumplimiento = completas ÷ planificadas vencidas con numerador, denominador y política visibles (parciales, ausencias, sin registro y movidas aparte; sin fechas futuras; una sesión movida cuenta una vez); volumen externo real (kg × repeticiones de series de trabajo con carga externa, con cobertura; sin datos ≠ 0); evolución y marcas observadas por ejercicio con gráfica monocroma y tabla equivalente; historial expandible con series. Se elimina la "suma de pesos" anterior.
- Pruebas: 314 → 401.

## 2026-10-01 · P3 · entrenamiento real (F03, F04, F05)

- **Esquema v3** con migración verificada (datos reales de la v2): series (`set_logs`), omisión de ejercicios, auditoría de reaperturas, reprogramaciones con linaje, check-in antes/después (clave única fecha+fase), decisión de ajuste por fecha y unidad de peso. Los check-ins existentes pasan a "antes"; ninguna serie ni omisión se inventa para sesiones antiguas.
- **Panel de series** (hoja desde cada tarjeta, Hoy sigue compacto): calentamiento/trabajo, carga, repeticiones y RIR opcionales (vacío = "sin registrar", nunca 0), editar/eliminar/omitir serie, omitir ejercicio con motivo, descanso opcional (iniciar/pausar/reanudar/cancelar) calculado por marcas de tiempo. Reordenar no mueve registros.
- **Completar sesión** exige todo resuelto (hecho u omitido); con omitidos el resultado es parcial y no se mueve nada. Editar una sesión terminada pide confirmar la reapertura y la anota en el historial.
- **Check-in antes y después**; el ajuste "sesión más ligera" (cansancio/DOMS/energía baja) es una propuesta reversible por día que solo afecta a ejercicios pendientes; una lesión pausa y ofrece nota o terminar, sin ajuste.
- **Reprogramación**: vista previa (pendientes, fecha propuesta con avisos de días seguidos, elegir fecha a mano sin desplazar otra sesión, guardar sin mover), aplicar en una transacción, deshacer mientras el destino no empiece (idempotente), linaje sin ciclos.
- **Unidad kg/lb** (Más → Unidad de peso): solo cambia la visualización; se guarda en kg sin redondear.
- Cambio visible: "Completar sesión" ya no exige marcar todo como hecho, sino resolver todo.
- Pruebas: 229 → 314. Teléfono real (Redmi, Android 16): migración v2→v3 con datos, panel de series y serie guardada con repeticiones desconocidas (NULL). iOS sin verificar.

## 2026-10-01 · P2 · plan, biblioteca y perfil (F01, F02, F06)

- **Esquema v2** con migración verificada (datos reales de la v1): perfil con peso/edad opcionales, días, equipo, duración y retomar; historial de respuestas; versiones de plan con rutinas y ejercicios. Los valores por defecto de la 0.1 (70 kg / 28 años) en perfiles sin completar pasan a "desconocido".
- **Planes versionados**: borrador → aceptar con vigencia (hoy o próximo lunes). Una versión aceptada es inmutable; las sesiones guardadas conservan su rutina; "ayer" no cambia. El plan de ejemplo (0.1) queda identificado como tal.
- **Generador local determinista** (principiantes: cuerpo completo; resto: empuje/tirón/pierna) según experiencia, objetivo, equipo y tiempo; explica cuando no puede producir un plan.
- **Editor de plan**: nombre, días (tres, distintos), orden, series/reps/RIR/descanso/incremento/peso de referencia, alternativas compatibles, añadir/quitar, validación visible y confirmación al salir con cambios.
- **Onboarding por pasos** (7), con progreso guardado, saltar (plan de ejemplo) y sin permisos del teléfono; perfil editable con historial.
- **Biblioteca**: 39 ejercicios (equipo, patrón, calentamiento, técnica), búsqueda sin acentos, filtros por músculo/equipo/"solo mi equipo", alternativas y tutorial como búsqueda identificada con reintentar/copiar. Ningún enlace de Short se incluye sin verificarlo.
- Cambio visible: el catálogo original muestra RIR único (p. ej. "RIR 2" donde antes "RIR 1–2").
- Pruebas: 110 → 229.

## 2026-10-01 · P1 · F00 persistencia SQLite/Drift

- Datos en SQLite (Drift 2.35.1, `sqlite3` 3.5.2 por build hooks) con una transacción por comando; el repositorio mantiene el estado en memoria y `ForjaStore.commit(previous, next)` escribe solo el diff. ViewModels y pantallas sin cambios.
- Importación única y verificada del snapshot 0.1 (`forja_flutter_snapshot_v1`): decoder estricto, marcador idempotente, original intacto. Pantalla de arranque con reintentar, copiar datos originales y continuar sin importar (con confirmación).
- Esquema versionado en `drift_schemas/` y prueba que falla si las tablas cambian sin versionar.
- Se elimina el soporte web (decisión del usuario) y las `fromJson` permisivas de los modelos; `SnapshotStore`/`PreferencesSnapshotStore` sustituidos.
- `AppDependencies.dispose()` pasa a ser asíncrono (cierra el almacén tras las escrituras pendientes).
- Dependencias nuevas: drift, drift_flutter, path_provider; dev: drift_dev, build_runner, shared_preferences_platform_interface. Gradle instaló en el SDK local Android SDK Platform 35 y CMake 3.22.1 (los exige `jni`, dependencia de path_provider_android).
- Pruebas: 16 → 107 (ver VALIDACION). Actualización 0.1 → P1 verificada en un Redmi 2412DPC0AG (Android 16): datos y perfil migrados, persistencia tras cierre forzado. iOS sin verificar. Sin commits de Git (decisión del usuario).

## 2026-09-30 · P0 línea base ejecutada

- Baseline desde la raíz actual: `pub get` sin cambios de lockfile; format de 40 archivos sin cambios; analyze limpio; 16/16 pruebas.
- `flutter build apk --debug` correcto en 778.5 s; APK debug de 155.5 MB confirmada. El fallo histórico de caché de Gradle no se reprodujo en esta máquina.
- Emulador Pixel 9a no llegó a estado `device` en adb (>18 min, qemu casi inactivo): instalación/smoke en dispositivo queda pendiente.
- Entorno: Flutter 3.47.5/Dart 3.13.4 fuera del PATH (ejecutado con wrapper local, sin modificar configuración global); JAVA_HOME JDK21; doctor sin cmdline-tools; Git en rama master sin commits.
- Sin cambios de código funcional; documentación de evidencia actualizada.

## 2026-09-30 · Especificación para completar1.0

- SDD F00–F14: alcance Flutter local, arquitectura/migración, criterios y gates nativos.
- Plan de implementación, testing y contexto de continuidad con estado real.
- AGENTS: cumplir especificación/skills, probar nuevas features y actualizar docs/contexto.
- Siete skills portables: Flutter/Android/iOS y cuatro adaptaciones de diseño con originales archivados y limitaciones documentadas.
- Lineamientos de identidad y enlaces desde README/alcance/arquitectura.
- Sin cambios de comportamiento a la app ni ejecución de tests/builds de aplicación en esta entrega documental.

Validación documental: siete entrypoints/frontmatter, enlaces locales operativos y coherencia F00–F14/estados. Comprobados 20 Markdown, 35 enlaces locales y 23 recursos originales idénticos por SHA256. quick_validate.py no se ejecutó por falta de PyYAML; se verificó localmente el formato simple de dos campos, nombres y archivos. Scripts originales no ejecutados. Evidencia de app histórica en docs/VALIDACION.md.

## 2026-09-30 · Base Flutter0.1

MVP MVVM y SharedPreferencesAsync; analyze limpio,16 tests y build web históricos. Android sin APK confirmada por acceso Gradle; iOS no probado. Código/assets/plataformas/docs movidos a appGym; cachés generadas fuera.
