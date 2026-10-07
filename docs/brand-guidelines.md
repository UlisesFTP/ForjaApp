# Identidad de FORJA

Mantiene diseño existente, no propone rediseño. Actualizado: 2026-09-30.

| Rol | Token |
| --- | --- |
| Fondo | #090909 |
| Superficie | #191919 |
| Papel/acción clara | #F4F4F1 |
| Texto principal oscuro | #F5F5F3 |
| Texto secundario oscuro | #C4C4C0 |
| Tinta sobre papel | #111111 |
| Borde base | #494949 |

Tema canónico: lib/core/theme/forja_theme.dart. Medir pares reales: texto 4.5:1, indicadores 3:1. Estado también con texto/símbolo; los errores llevan texto y símbolo, y el rojo se reserva a acciones destructivas (D44).

DM Sans cuerpo/controles, Barlow Condensed títulos; fuentes/OFL locales. Informativo mínimo 14 px, nuevos párrafos suelen usar 16 px, texto al 200% operable.

Radios actuales por rol: inputs 12 / botones 14; mantener geometría de tarjetas/paneles/navbar. Centralizar tokens al ampliar sin imponer mismo radio a toda función. Espaciado coherente, SafeArea y controles utilizables.

## Racha (excepción de color)

La llama de racha es el único elemento con color propio de la marca (D36); además, las acciones clave usan verde `#15803D`, amarillo oscuro `#A16207` y rojo `#DC2626` sólidos, con icono y texto blancos (contraste ≥ 4,5:1), compactos (40 px visibles, zona táctil de 48 px), y hover y foco más oscuros con contorno claro y pulsado aún más oscuro (D44); el color nunca va solo. Llama: naranja `#FF9600` con núcleo `#FFC800` sobre fondos oscuros, naranja profundo `#E65100` sobre el papel de la barra superior y gris `#757570` apagada. No usar el naranja en ningún otro control, texto o gráfica salvo el mapa de calor de la racha. La llama parpadea solo un momento y respeta el movimiento reducido.

## Navbar y Hoy

Navbar oscura existente, droplet blanco con borde negro grueso, hundidura real animada y edge blanco parcial tenue. Sin halo/fade negro ni cambio de forma no solicitado. En horizontal (pantalla más ancha que alta) la misma barra se pone de pie a la izquierda: riel con la muesca en el borde derecho y la gota asomando hacia el contenido (D33, decisión del usuario). En tablet vertical la barra inferior conserva un ancho de teléfono (máx. 640 px), centrada. Los elementos parten con el mismo ancho y solo se ensancha el que lo necesita; etiquetas en una sola línea, nunca partidas, con 18 px entre ellas cuando hay sitio y nunca menos de 12 (D35).

Hoy fecha/calendario/resumen únicos, siguiente/checklist/peso rápidos; técnica/calentar/check-in/series bajo demanda. Tres tarjetas base y finalizar en 390 × 844 antes de navbar. Texto grande puede crecer y permitir scroll.

## Logo y voz

Logo assets/images/forja-icon.png, marca geométrica monocromática del encargo. No deformar proporciones; revisar iconos nativos pequeños.

Español directo y breve, sin culpa por faltar ni promesas. RIR = repeticiones en reserva; DOMS explicado cuando sea útil. Estimaciones no se presentan como medición. Errores indican siguiente acción recuperable.

Datos desconocidos explícitos, sin progreso inventado. Licencias OFL en assets/fonts; conservar procedencia nueva.
