---
name: ui-ux-pro-max
description: Diseñar o revisar UI, interacción y accesibilidad móvil de FORJA conservando su tema y navbar, con guía original UI UX Pro Max como referencia.
---

# UI UX Pro Max · FORJA

Aplicar si cambian pantallas/controles/layout/movimiento, no a lógica sin UI. Leer SDD afectado y docs/brand-guidelines.md desde raíz. Identidad aceptada prevalece sobre paletas genéricas.

## Revisión

1. Hoy prioriza rutina/siguiente/progreso; series/técnica/calentar/check-in bajo demanda.
2. Completar/editar rápidos; asa drag con menú arriba/abajo y teclado. Sin hover/color/gesto como única vía.
3. Targets/contraste/semántica/título de sheet/orden y retorno de foco; TalkBack/VoiceOver, texto200% y TESTING.
4. Tema Dart/fuentes locales/radios por rol. No nueva navbar ni halo negro alrededor del droplet; la única variante aceptada es el riel lateral con la misma gota en horizontal (D33).
5. Conservar calendario/drag/navbar animados, interrumpibles y reduced motion. No bloquear taps por animación.
6. Loading/empty/error/disabled/confirmado legibles y recuperación. Gráficas con tabla accesible.
7. Diseño adaptable: usar `ResponsivePage`/`TwoColumns`/`ResponsiveGrid` de `lib/ui/core/responsive.dart`; teléfono vertical idéntico, dos columnas solo cuando caben, cada sección su propio nodo semántico; ampliar `test/responsive_test.dart` con cada pantalla nueva.

Adaptar principios web a constraints/Semantics Flutter, no copiar CSS/ARIA literalmente. No fijar alturas que recorten texto para cumplir sin scroll.

## Recursos y limitación

[Guía original completa](references/original/SKILL.md), frontmatter/atribución preservados. Leer secciones pertinentes, adaptar instrucciones web.

Archivos originales data/scripts solo apuntan a rutas inexistentes: no hay search.py/CSV. No inventar resultados ni ejecutar comandos ausentes. Revisar manualmente guía, SDD y código.

## Cierre

Pruebas widget de interacción, regresiones móviles y lector de pantalla nativo pertinente. Registrar evidencia/ID y docs; no rediseñar decisiones que el usuario pidió conservar.
