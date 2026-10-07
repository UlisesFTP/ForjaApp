# Alcance de la entrega

FORJA es un organizador móvil de rutinas de gimnasio, sin login y con identidad monocromática principalmente oscura (la llama de racha y los botones de acciones clave tienen color). Flutter, arquitectura MVVM y datos locales en SQLite. Estado a **2026-10-01** (versión `0.9.0+2`): las fases P0–P7 están implementadas y verificadas en host y, donde se indica, en un Android real. **iOS no se ha compilado ni probado** (no hay macOS), por lo que ningún requisito está cerrado. Detalle por requisito en [IMPLEMENTACION](IMPLEMENTACION.md) y evidencia en [VALIDACION](VALIDACION.md).

## Incluido

- **Hoy** compacto: calendario semanal animado, un resumen, checklist con siguiente ejercicio, peso editable (kg o lb), detalles y reorden por asa, menú o teclado.
- **Series reales** (panel por ejercicio): calentamiento y trabajo, carga, repeticiones y RIR opcionales (vacío = «sin registrar», nunca 0), omitir serie o ejercicio con motivo, técnica autoevaluada, descanso opcional por marcas de hora. Completar una sesión exige resolver todo; con omitidos queda parcial. Editar una sesión terminada pide confirmar y deja rastro.
- **Check-in** antes y después; propuesta de sesión más ligera reversible (solo afecta a lo pendiente); una lesión pausa y no ofrece ajustes ni aumentos.
- **Ausencia y sesión incompleta** con vista previa, fecha propuesta (o elegida), aviso de días seguidos, guardar sin mover y deshacer mientras el destino no empiece.
- **Plan** versionado: onboarding, generador local determinista, editor, borrador → aceptar con vigencia (sin tocar sesiones pasadas), planes de 1 a 7 días; sin plan ni rutina de ejemplo al instalar (D45).
- **Biblioteca** de 40 ejercicios con filtros, alternativas y tutorial como búsqueda identificada.
- **Progreso**: cumplimiento con numerador, denominador y política visibles; volumen externo real con cobertura; evolución y marcas observadas con gráfica monocroma y tabla equivalente; historial con series; sugerencias de progresión por ejercicio (reglas `prog-v1`) que nunca se aplican solas.
- **Racha de entrenos** con llama naranja animada en la barra superior, calendario mensual y mapa de calor anual con tabla equivalente (reglas `streak-v1`: cuenta días de entrenamiento del plan; descansos y faltas reprogramadas no la rompen).
- **Minicoach**: revisión mensual cada 30 días (posponer 7), propuesta explicada con comparación de planes, aceptar o rechazar (reglas `review-v1`). Reglas locales y explicables; no es un diagnóstico ni una IA remota.
- **Cardio** persistente por tramos (intensidad y peso por tramo), tiempo reconstruido de marcas de hora UTC, recuperación tras reinicio y detección de reloj incoherente; kcal ≈ MET × kg × horas con tabla `met-v1` (sin peso: solo duración).
- **Nutrición** manual: calorías, porción y macros opcionales, historial por día, edición y deshacer, favoritos, recetas, etiquetas/alérgenos declarados y objetivos opcionales. Lo no registrado nunca se cuenta como 0.
- **Recordatorios locales** con permiso del sistema (estado real separado del deseo), ventana de 28 días, reconciliación, cancelación al completar/mover, tap que abre el día.
- **Copia de seguridad**: exportar JSON versionado con SHA-256, importar reemplazando (vista previa, validación, copia previa privada, transacción) y eliminar todos los datos.
- Unidad kg/lb solo de visualización (se guarda en kg sin redondear), licencias de código abierto, iconos y pantalla de arranque propios.
- Fuentes y logo locales. Navbar oscura con droplet (riel lateral con la misma gota en horizontal). Diseño adaptable a teléfonos y tablets en vertical y horizontal (dos columnas cuando caben). Adaptación móvil, controles táctiles, semántica, paneles con cierre visible y movimiento reducido.
- **Minicoach con sistema experto `expert-v1`** (F16, D37, 2026-10-02): reglas locales y explicables de seguridad, fatiga, progresión, plan, constancia, cardio, nutrición y registro, cada una con su «por qué» y su respaldo; nada se aplica solo. Verificado en host; pendiente en el teléfono.
- **Asistente IA opcional** (F17, D38, 2026-10-02), desactivado por defecto, con la clave de la propia persona: estimar comidas descritas en texto y chat con herramientas internas de FORJA que solo proponen, con traza de lo consultado. Verificado en host sin red; pendiente la prueba en el teléfono con la clave real.

## Fuera de 1.0 (por decisión o por requisito del SDD)

- Notificaciones push o remotas, y alarmas exactas: los avisos locales son inexactos y el sistema puede retrasarlos.
- Sincronización entre dispositivos, cuentas, backend y telemetría. Importar mezcla (merge): solo reemplazo.
- Base de alimentos, escaneo, dietas personalizadas y contenido de recetas con licencia.
- Cardio en segundo plano con servicio continuo: el tiempo se reconstruye de marcas de hora, no se ejecuta Dart en segundo plano.
- Soporte web (retirado el 2026-10-01 por decisión del usuario: SQLite nativo no corre en navegador).
- Publicación en tiendas y claves de producción (requieren autorización específica).

## Pendiente real

- **iOS completo**: compilación, notificaciones (autorización, límite de 64 pendientes), selector de archivos, exclusión de la base de la copia de iCloud, TalkBack/VoiceOver.
- **Pruebas de dispositivo sin hacer**: TalkBack/VoiceOver con una persona escuchando. El reinicio del teléfono (los avisos se reprograman solos) y el cardio con la pantalla bloqueada **sí** se verificaron en un Android real (2026-10-02). Hay una línea base de rendimiento en un teléfono de 120 Hz (2026-10-02) El fotograma de ≈169 ms al cambiar de pestaña se corrigió y se verificó en el teléfono (peor caso 29 ms). Horario de verano (Europe/London, 25 oct) y ahorro de batería sí se verificaron en un Android real. Nutrición, exportar/importar con el selector del sistema, eliminación total, y cardio en segundo plano y tras la muerte del proceso **sí** se verificaron en un Android real (2026-10-01).
- Revisar el contenido de `prog-v1`, `review-v1` y la tabla MET `met-v1` antes de publicar (son heurísticas, la tabla MET no se contrastó con la fuente).
- Comprobar el CI (`.github/workflows/ci.yml`) en GitHub: desde el 2026-10-02 hay repositorio remoto (D42), pero la ejecución no se ha revisado desde aquí.
- Probar en el teléfono el sistema experto (migración v6→v7 con datos reales) y el asistente IA con la clave de la persona.

## Datos y conectividad

No se pide cuenta. Los datos están en una base SQLite privada del dispositivo (no cifrada) y no se envían a ningún servidor, salvo lo que consulta el asistente IA opcional cuando la persona lo activa y le pregunta (va a su propio proveedor, con su clave; cada respuesta muestra qué se consultó). Abrir un tutorial requiere Internet (navegador/YouTube del teléfono). Desinstalar o borrar los datos de la app elimina los registros: la copia de seguridad es explícita y manual (Más → Datos y privacidad). Android no incluye la base en las copias automáticas del sistema.

## Lenguaje de entrenamiento

Se usa **RIR**, repeticiones en reserva, para el esfuerzo. DOMS designa el dolor muscular de aparición tardía. Las calorías de cardio son estimaciones por actividad, intensidad, tiempo y peso corporal, no una medición. Ante una lesión registrada la app recomienda pausar y no sugiere aumentos.

## Plataformas

Android (mínimo API 24) e iOS 15.0 (sin verificar), teléfonos y tablets en vertical y horizontal (tablet comprobada en host y simulada en un teléfono, no en una tablet física). Firma, permisos, iconos y dependencias: [ENTREGA](ENTREGA.md).
