> Documento de producto del prototipo original. Para el estado de la entrega Flutter, consultar README.md, ALCANCE.md y VALIDACION.md.

# FORJA — Descripción del proyecto

## 1. Resumen

**FORJA** es una app móvil para organizar rutinas de gimnasio, seguir la sesión del día y registrar el progreso sin crear una cuenta. Su objetivo es facilitar el entrenamiento: saber qué toca, registrar pesos y completar ejercicios con pocas interacciones.

La experiencia debe permitir cambiar rápidamente el orden de los ejercicios cuando una máquina esté ocupada. También debe recoger cómo se siente la persona y usar ese feedback para ajustar las recomendaciones y reorganizar sesiones pendientes.

La aplicación final se desarrollará en **Flutter con Dart** y utilizará **almacenamiento local persistente en el dispositivo**. El trabajo realizado hasta ahora es un prototipo web funcional de la UI y los flujos del MVP; sirve como referencia para la implementación en Flutter.

## 2. Principios del producto

- Uso exclusivamente móvil, pensado para consultarse mientras se entrena.
- Sin login, registro obligatorio ni dependencia de un backend para las funciones principales.
- Datos personales y registros guardados localmente.
- Información esencial visible primero y acciones frecuentes al alcance de pocos toques.
- Rutinas flexibles: cambiar el orden debe ser sencillo y conservar el registro de cada ejercicio.
- Recomendaciones orientativas y transparentes sobre su alcance.
- Estética monocromática, principalmente negra, con superficies blancas para destacar información y acciones.

## 3. Diseño e identidad que desarrollamos

### Identidad visual

- Nombre del proyecto: **FORJA**.
- Logo e icono propios con una marca geométrica abstracta inspirada en una letra F, formada por bloques blancos sobre un fondo oscuro.
- Paleta de negro, blanco y grises; el contraste debe facilitar la lectura durante el entrenamiento.
- Tipografía **Barlow Condensed** para títulos y **DM Sans** para contenido y controles.
- Radios coherentes: tarjetas de 16 px, controles de 12 px y paneles de 24 px como referencia visual.
- Cabecera clara, contenido principalmente oscuro y ejercicio siguiente destacado con una tarjeta clara.

### Navegación

La barra inferior contiene **Hoy, Plan, Progreso y Ejercicios**, más un acceso **Más** para Cardio, Nutrición, Minicoach y Recordatorios.

Se diseñó una navbar oscura con un indicador blanco tipo *droplet*. La selección se mueve con animación sobre una hendidura real de la barra. El droplet tiene un contorno negro marcado y la hendidura conserva un brillo blanco muy tenue en sus bordes, sin el degradado negro alrededor.

## 4. Pantallas y funciones

### Hoy: sesión del día

Es la pantalla principal y prioriza la interacción rápida.

- Cabecera compacta con el día y la fecha, seguida del calendario semanal.
- Calendario que distingue días de gimnasio y días libres mediante texto, además del estado visual.
- Transición animada al seleccionar otra fecha.
- Un único resumen con nombre de rutina, cantidad de ejercicios, duración estimada y progreso.
- Checklist de ejercicios con nombre, series, repeticiones, RIR y peso editable.
- Indicaciones explícitas de **Siguiente** y **Completado**.
- Reordenamiento animado: la tarjeta sigue el arrastre y las demás se acomodan para dejarle espacio.
- Alternativa al drag: tocar el asa y elegir **Mover arriba** o **Mover abajo**. El prototipo también admite flechas del teclado.
- Botón **Completar sesión** después de la lista.
- **No terminé** y **Falté hoy** agrupados en las opciones de sesión.
- Calentamiento y check-in disponibles en paneles, sin ocupar una tarjeta extensa en la pantalla principal.
- Accesos compactos a Progreso y Minicoach.

En un día de descanso se muestra una sola tarjeta con la próxima rutina y el acceso a cardio.

### Plan y calendario

- Organización semanal de tres días de entrenamiento, con días de recuperación entre sesiones.
- La plantilla actual contiene **Pierna & fuerza**, **Empuje** y **Tirón**; utiliza martes, jueves y sábado como días de ejemplo.
- Consulta de la rutina correspondiente a cada fecha.
- Registro de sesiones completadas, incompletas y ausencias.
- Reprogramación de una sesión pendiente al siguiente día de descanso.
- En una sesión incompleta, traslado de los ejercicios que quedaron pendientes.

La elección de otros días y la generación de nuevas rutinas completas forman parte de la evolución prevista, no de la capacidad actual del generador.

### Biblioteca de ejercicios

- Catálogo organizado por categorías musculares, con búsqueda y filtros.
- Descripción del ejercicio y explicación de su técnica.
- Músculos que trabaja, calentamiento específico y recomendaciones de ejecución.
- Consulta de series, repeticiones e intensidad sugerida.
- Acceso a tutoriales de YouTube Shorts.

Actualmente el tutorial abre una **búsqueda externa en YouTube**; todavía no existe un catálogo de videos específicos seleccionados para cada ejercicio.

### Check-in y recomendaciones

La persona puede registrar cómo se siente:

- Cansado.
- Normal.
- Con energía.
- Con DOMS o molestias musculares posteriores al entrenamiento.
- Lesionado.
- Nota opcional sobre la sesión.

El feedback se guarda por fecha. Algunas respuestas ajustan las series y las repeticiones en reserva; las recomendaciones que afectan la sesión aparecen junto al resumen. Ante lesión o dolor, la interfaz recomienda pausar la sesión y buscar valoración profesional.

El término utilizado es **RIR**, entendido como repeticiones en reserva. La solicitud inicial mencionaba “RIG”; en este proyecto se interpreta como RIR. Las indicaciones sobre acercarse al fallo deben mostrarse por ejercicio y de forma comprensible.

### Minicoach

Al inicio solicita experiencia, objetivo, peso corporal, edad, energía de la semana y una nota opcional. Permite revisar esos datos posteriormente y registrar cómo fue el mes.

El prototipo adapta las prescripciones y recomendaciones mediante reglas sencillas. La visión del producto es que este feedback permita crear o modificar una rutina semanal y orientar la progresión mensual.

**Estado actual:** no es un entrenador basado en IA ni un generador completo de rutinas personalizadas. La revisión mensual es un flujo disponible para actualizar el perfil; todavía no se automatiza como seguimiento mensual.

### Progreso y estadísticas

- Sesiones completadas esta semana e historial total de entrenamientos.
- Resumen de sesiones completas, parciales y ausencias.
- Visualización de la constancia semanal.
- Indicador aproximado de carga registrada.
- Orientación general sobre cuándo considerar aumentar peso o intensidad.

El indicador de volumen actual es una aproximación del prototipo, no un cálculo detallado de series × repeticiones × carga realmente realizadas. Tampoco se calcula todavía una predicción personalizada de aumento de peso.

La evolución prevista debe registrar resultados reales por serie para fundamentar las sugerencias de progresión.

### Cardio

- Cronómetro con inicio, pausa y reinicio.
- Selección de caminata, caminadora, bicicleta o elíptica.
- Estimación de calorías a partir de actividad, tiempo y peso corporal registrado.

Las calorías se presentan como aproximadas. El prototipo no incluye seguimiento con sensores ni historial persistente de sesiones de cardio.

### Recordatorios

- Configuración de una hora para recordar el entrenamiento.
- Activación o desactivación de avisos.

En el prototipo web, los recordatorios dependen de que la página permanezca abierta. La versión Flutter debe utilizar **notificaciones locales programadas** para los días de entrenamiento y actualizar su programación cuando cambie el calendario, según las capacidades y permisos del sistema operativo.

### Nutrición: módulo opcional

Actualmente permite registrar alimentos o comidas y sus calorías estimadas por día.

La planificación de dietas, recomendaciones de comidas, objetivos nutricionales y seguimiento de macronutrientes quedan como posibles ampliaciones. El MVP actual no genera dietas personalizadas.

## 5. Flutter y almacenamiento local

### Plataforma objetivo

- Desarrollar la aplicación móvil en **Flutter y Dart**.
- Usar el prototipo como referencia de identidad, jerarquía visual, animaciones y comportamiento.
- Mantener la experiencia móvil; el prototipo web no constituye una implementación Flutter ya realizada.

### Persistencia

Utilizar una base de datos local para información estructurada y persistencia local de preferencias. Guardar, como mínimo:

- Perfil y respuestas del minicoach.
- Plan semanal y cambios de fechas.
- Ejercicios de cada sesión y su orden personalizado.
- Checklist, pesos y estado de cada sesión.
- Check-ins y notas por fecha.
- Historial necesario para estadísticas y progresión.
- Registros de alimentos y calorías.
- Configuración de recordatorios y preferencias de la aplicación.

Los datos deben mantenerse después de cerrar y volver a abrir la app. El orden y los registros deben vincularse al identificador del ejercicio y a la sesión, no a la posición visual de la tarjeta.

En el prototipo actual, la persistencia utiliza el almacenamiento del navegador. En Flutter debe sustituirse por almacenamiento propio de la aplicación. La tecnología concreta de base de datos local se elegirá al iniciar esa implementación.

### Funcionamiento sin conexión

Consultar la rutina, completar ejercicios, editar pesos, registrar feedback y consultar estadísticas debe funcionar sin conexión. Los tutoriales de YouTube requieren acceso a Internet.

No se requiere autenticación ni sincronización en la nube para el MVP. Una función de exportación e importación de respaldo puede añadirse después para facilitar la conservación y el traslado de datos entre dispositivos.

## 6. UX y accesibilidad

- Controles táctiles de al menos 44 × 44 como referencia del diseño; en Flutter respetar también las convenciones de cada plataforma.
- Texto informativo de al menos 14 en la escala base, con soporte de ampliación al 200%.
- Contraste de referencia de 4,5:1 para texto normal y 3:1 para indicadores necesarios.
- Estados identificables por texto o símbolos, además del color.
- Etiquetas accesibles para completar, reordenar, editar peso y abrir detalles.
- Anuncios breves al guardar o cambiar el orden.
- Paneles con título, cierre visible, foco contenido y retorno al control de origen.
- Respeto de la preferencia de movimiento reducido.
- Compatibilidad de la versión Flutter con lectores de pantalla y escalado de texto del sistema.

La vista compacta del prototipo se comprobó en **390 × 844**, mostrando tres ejercicios y el botón para completar sin scroll. También se revisó en **320 px de ancho** y con texto al **200%**, permitiendo scroll vertical y evitando desbordamiento horizontal de la página. Estas comprobaciones deben repetirse en Flutter y en dispositivos reales.

## 7. Estado del proyecto y siguiente etapa

| Área | Estado actual | Objetivo en Flutter |
| --- | --- | --- |
| Identidad y UI móvil | Prototipo diseñado y funcional | Reproducir el sistema visual y sus interacciones |
| Rutina y checklist | Plantilla de tres días, pesos y orden persistentes | Persistencia local propia de la app |
| Feedback y minicoach | Perfil y ajustes por reglas | Evolucionar hacia planificación semanal y revisión mensual |
| Reprogramación | Traslado de sesiones ausentes o pendientes | Conservar el flujo y contemplar cambios del calendario |
| Progreso | Estadísticas y orientación general | Registrar resultados por serie y mejorar las recomendaciones |
| Tutoriales | Búsqueda externa en YouTube | Incorporar enlaces específicos por ejercicio |
| Recordatorios | Avisos con la página abierta | Notificaciones locales programadas |
| Cardio | Cronómetro y estimación de calorías | Mantener el cálculo orientativo y evaluar historial local |
| Nutrición | Registro básico de comidas y calorías | Mantenerlo opcional; ampliar después si se decide |

La siguiente etapa es construir el MVP móvil en Flutter, conservar los flujos ya definidos y sustituir la persistencia del navegador por almacenamiento local. La generación avanzada de rutinas, la progresión personalizada y la planificación nutricional deben tratarse como ampliaciones explícitas.

## 8. Descripción breve para compartir

> FORJA es una app móvil de rutinas de gimnasio desarrollada en Flutter, sin login y con almacenamiento local. Su interfaz monocromática, principalmente oscura, permite consultar un plan semanal de tres días, completar y reordenar ejercicios con drag & drop, registrar pesos y sensaciones, y reorganizar sesiones pendientes. Incluye biblioteca de ejercicios, calentamientos, acceso a tutoriales de YouTube Shorts, estadísticas, minicoach, cardio y recordatorios locales. El producto busca evolucionar hacia ajustes de rutina y progresión basados en el feedback del usuario. El diseño y los flujos están definidos en un prototipo web; la implementación Flutter es la siguiente etapa.
