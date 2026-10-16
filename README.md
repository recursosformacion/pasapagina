# Pasapagina

**Lee a tu manera.**

Pasapagina es una aplicación de lectura para Android, desarrollada con Flutter, pensada principalmente para novelas y libros de texto corrido. Su objetivo es que cada persona pueda leer cómodamente con el tamaño de letra, la orientación y la distribución que prefiera, sin depender de las páginas fijas de un PDF.

> **Principio central:** el libro debe adaptarse al lector, no el lector al formato de página.

## Estado del proyecto

Este documento recoge la definición funcional y visual inicial del producto. Las pantallas y funciones descritas son especificaciones; no implican que ya estén implementadas.

## 1. Visión del producto

Pasapagina será un lector sencillo, amable y local. Debe permitir abrir un libro y empezar a leer sin cuentas, configuraciones obligatorias ni distracciones.

Prioridades:

- Lectura adaptativa como modo predeterminado.
- Navegación por toques en los márgenes izquierdo y derecho.
- Continuidad del texto entre pantallas.
- Reanudación automática y marcadores manuales independientes.
- Modo alternativo para conservar el diseño original de un PDF.
- Arquitectura preparada para admitir EPUB.
- Archivos y progreso almacenados en el dispositivo, sin necesidad de subir libros a un servidor.

## 2. Identidad visual

### Personalidad

La marca será **alegre, simpática y cercana**, con una pequeña mascota con forma de libro. La mascota dará personalidad a la biblioteca, los estados vacíos y los mensajes puntuales, pero no distraerá durante la lectura.

Lema: **«Lee a tu manera.»**

### Paleta inicial

| Uso | Color | Código |
|---|---|---|
| Fondo principal y lectura | Crema cálido | `#F5EBD8` |
| Acentos y acciones principales | Naranja | `#F3A34B` |
| Acento secundario | Verde agua | `#4F8A7B` |
| Texto principal | Tinta oscura | `#34342F` |

Los colores son una primera propuesta y deberán comprobarse por contraste y accesibilidad en el dispositivo real. También habrá temas blanco y oscuro para leer.

### Mascota

Propuesta inicial: un libro abierto sonriente, con una esquina doblada naranja. El símbolo de esquina doblada se relaciona con los marcadores del lector.

La mascota no aparecerá de forma persistente en la pantalla de lectura.

### Principios de interfaz

- Interfaz clara, cálida y poco recargada.
- Acciones principales fáciles de reconocer.
- Controles de lectura ocultos mientras se lee.
- Iconos y etiquetas comprensibles; evitar menús profundos.
- La decoración nunca debe reducir innecesariamente el espacio disponible para el texto.

## 3. Navegación principal

La aplicación tendrá tres destinos principales:

1. **Biblioteca:** importar, buscar, ordenar y abrir libros.
2. **Marcadores:** consultar los pasajes guardados en los distintos libros.
3. **Ajustes:** configurar la experiencia de lectura y el comportamiento de la aplicación.

Al abrir un libro, la navegación principal desaparecerá y la lectura ocupará la pantalla.

## 4. Biblioteca

La biblioteca debe sentirse como una colección personal, no como un gestor técnico de archivos.

### Contenido

- Sección «Sigue leyendo» con el último libro abierto y su progreso.
- Colección de libros importados, con portada cuando pueda obtenerse, título y autor si están disponibles.
- Búsqueda por título y autor.
- Orden por título, última lectura o fecha de incorporación.
- Acción destacada «Añadir un libro».
- Menú contextual para consultar información, cambiar el título mostrado o retirar un libro de la biblioteca.

### Importación y archivos

- Utilizar el selector de documentos de Android para que el usuario elija sus archivos.
- Empezar por PDF.
- Diseñar la capa de importación para incorporar EPUB posteriormente.
- Explicar los errores de apertura o extracción en lenguaje comprensible.
- Distinguir entre retirar un libro de la biblioteca y borrar el archivo original, evitando eliminaciones accidentales.

La biblioteca y el progreso no exigirán una cuenta de usuario.

## 5. Modos de lectura

### 5.1 Lectura adaptativa — predeterminada

Es el modo principal y está pensado para novelas, ensayos y otros libros de texto corrido.

- Extrae el texto del PDF cuando sea posible.
- Redistribuye el contenido según el tamaño y orientación de la pantalla, la tipografía, el tamaño de letra, los márgenes y el interlineado.
- Permite cambiar estos parámetros sin perder el punto de lectura.
- Conserva, cuando sea posible, capítulos, párrafos y referencias a la página de origen.
- No trata el número de página PDF como la posición principal de lectura.

La lectura adaptativa no equivale a mostrar una página PDF ampliada: reconstruye el texto en un flujo de lectura.

### 5.2 PDF original

Modo alternativo para documentos donde la composición visual es importante.

- Conserva la distribución original de la página.
- Permite zoom y navegación por el documento.
- Es preferible para columnas, ilustraciones, partituras, notas al pie, formularios o diseños complejos.
- Puede intentar una navegación más continua si la extracción de texto y la geometría de las líneas son fiables, pero no debe prometer continuidad perfecta.

El usuario podrá cambiar de modo desde los controles de lectura o la información del libro.

### 5.3 EPUB — objetivo posterior

La arquitectura debe separar el contenido de su presentación para que EPUB pueda usar su estructura propia de capítulos y posiciones. La incorporación completa de EPUB llegará después de validar el motor inicial con PDF.

### Límites de extracción

Los PDF escaneados pueden necesitar OCR. Los documentos con varias columnas, encabezados, notas o un orden de lectura complejo pueden extraerse incorrectamente. Pasapagina debe detectar los casos dudosos cuando sea posible, informar al usuario y recomendar el modo PDF original, en lugar de presentar silenciosamente un texto desordenado.

## 6. Navegación durante la lectura

### Gestos principales

| Acción | Resultado |
|---|---|
| Toque en el margen derecho | Avanzar |
| Toque en el margen izquierdo | Retroceder |
| Toque en la zona central | Mostrar u ocultar los controles |
| Giro del dispositivo | Redistribuir el texto manteniendo el pasaje actual |
| Cambio del tamaño de letra | Recalcular la distribución manteniendo el punto de lectura |
| Pulsación prolongada sobre el texto | Mostrar opciones contextuales, como selección y copia, cuando estén disponibles |

Los márgenes de toque serán zonas invisibles, no botones permanentes. Sus dimensiones deberán probarse en teléfonos de distintos tamaños.

Los gestos deben evitar conflictos con la selección de texto, los enlaces, el zoom y el desplazamiento del modo PDF original. Se podrá ofrecer el desplazamiento vertical como alternativa de navegación si las pruebas de uso lo aconsejan.

### Controles temporales

Al tocar el centro aparecerá una capa discreta con acceso a:

- Volver a la biblioteca.
- Ajustar tipografía y tamaño.
- Añadir un marcador.
- Abrir el índice de capítulos.
- Cambiar el tema.
- Cambiar al modo PDF original, si procede.
- Consultar el progreso.

Los controles se ocultarán automáticamente tras un breve periodo de inactividad o al reanudar la lectura. El texto no debe quedar cubierto innecesariamente.

## 7. Continuidad del texto

La continuidad es el principal reto técnico y la característica que distingue a Pasapagina de un visor PDF convencional.

### Objetivo

Al avanzar, el nuevo contenido debe comenzar cerca del último texto leído, manteniendo el contexto y evitando saltos u omisiones. Puede utilizarse un pequeño solapamiento configurable para ayudar al lector a retomar el hilo.

No se debe implementar como un salto fijo entre páginas PDF ni como un número de pantalla almacenado.

### Posición estable

El motor guardará una referencia al contenido —por ejemplo, un desplazamiento dentro del texto normalizado o un identificador de párrafo y carácter— junto con la información necesaria para reconstruir la vista.

- **Avanzar:** encontrar el siguiente fragmento que debe leerse.
- **Retroceder:** reconstruir el fragmento anterior sin perder ni duplicar contenido de forma significativa.
- **Cambiar orientación o tipografía:** recalcular la distribución desde la referencia estable.
- **Reabrir el libro:** restaurar el punto de lectura guardado.

Para PDF, cuando sea posible se conservarán también la página original y las coordenadas asociadas al fragmento. La estrategia exacta dependerá de la calidad y estructura del texto extraído.

## 8. Posición de lectura y marcadores

Son dos funciones distintas.

### Reanudación automática

Pasapagina recordará dónde dejó el usuario cada libro y lo reabrirá en esa posición. Esta posición se actualizará durante la lectura y se guardará localmente.

### Marcadores manuales

Representan lugares que el usuario quiere recordar explícitamente, aunque continúe leyendo después.

- La esquina doblada será el motivo visual del marcador.
- Cada marcador pertenecerá a un libro y apuntará a un fragmento estable.
- Se podrá asignar una etiqueta opcional.
- El usuario podrá consultar, abrir y eliminar marcadores.
- Crear un marcador no cambiará la posición automática de reanudación.

En lectura adaptativa, el marcador no debe depender del número de pantalla. En PDF original podrá guardar página y coordenadas; en EPUB se aprovechará su mecanismo de localización cuando esté disponible.

## 9. Ajustes de lectura

Ajustes iniciales previstos:

- Tamaño de letra.
- Tipografía: serif y sans serif, como mínimo.
- Interlineado.
- Márgenes.
- Tema crema, blanco y oscuro.
- Orientación automática o preferida, si se decide ofrecer ese control.
- Modo de lectura adaptativa o PDF original cuando el documento lo permita.
- Comportamiento de navegación, si las pruebas justifican opciones adicionales.

La preferencia de apariencia podrá ser predeterminada para nuevos libros y ajustarse por libro cuando resulte útil.

Los controles deben ser fáciles de entender. Se evitarán ajustes avanzados innecesarios en la primera versión.

## 10. Arquitectura funcional propuesta

Separar las responsabilidades para no acoplar la interfaz a un único formato:

- **Biblioteca:** metadatos, archivos importados y ordenación.
- **Importación y formatos:** acceso a documentos y detección del formato.
- **Motor PDF:** renderizado, extracción de texto y, cuando esté disponible, geometría de líneas.
- **Modelo de contenido:** texto normalizado, párrafos, capítulos y referencias a la fuente.
- **Motor de lectura adaptativa:** distribución, avance, retroceso y continuidad.
- **Posición y marcadores:** persistencia de la reanudación y los puntos guardados.
- **Preferencias:** tipografía, tamaños, márgenes, tema y navegación.
- **Interfaz Flutter:** biblioteca, pantalla de lectura, controles temporales y ajustes.

La interfaz no debe calcular por sí sola la posición semántica ni depender directamente de las peculiaridades de un motor PDF. Esta separación facilitará añadir EPUB y otros formatos.

## 11. Privacidad y almacenamiento

- Los libros y el progreso se gestionarán localmente.
- No se necesita cuenta ni servicio remoto para las funciones esenciales.
- Se evitará copiar archivos sin necesidad.
- Se distinguirá entre referencias a documentos seleccionados y copias internas creadas por la aplicación.
- Los errores no deben incluir contenido privado del libro.
- La eliminación de datos debe ser comprensible y no borrar el documento original por accidente.

## 12. Accesibilidad y calidad de uso

- Tamaños de letra amplios y controles táctiles cómodos.
- Contraste suficiente en los tres temas.
- Compatibilidad razonable con lectores de pantalla.
- La información no dependerá exclusivamente del color.
- Los controles podrán descubrirse sin permanecer visibles todo el tiempo.
- La rotación y los cambios de preferencias no deberán expulsar al usuario de su pasaje.

## 13. Plan de desarrollo

### Fase 1 — Prototipo lector PDF

- Crear el proyecto Flutter para Android.
- Importar y abrir PDF locales.
- Implementar extracción de texto para documentos sencillos.
- Construir la primera pantalla adaptativa.
- Añadir avance y retroceso mediante toques laterales.
- Mantener la posición al cambiar tamaño de letra y orientación.

**Criterio de aceptación:** leer una novela PDF con texto extraíble, avanzar y retroceder, girar el dispositivo y cambiar la letra sin perder el pasaje.

### Fase 2 — Biblioteca y persistencia

- Biblioteca local y acción para añadir libros.
- Reanudación automática por libro.
- Preferencias de lectura persistentes.
- Marcadores manuales independientes.
- Gestión clara de errores y documentos no compatibles.

### Fase 3 — Modo PDF original

- Renderizado fiel de la página.
- Zoom y navegación tradicional.
- Cambio de modo desde la interfaz.
- Pruebas con documentos complejos y escaneados.

### Fase 4 — EPUB y mejoras

- Integrar un motor EPUB.
- Mantener posición estable entre sesiones.
- Leer índice y capítulos.
- Revisar calidad de extracción y añadir OCR solo si se justifica.

Las fases son una propuesta de planificación; no indican que estas funciones estén ya implementadas.

## 14. Pruebas esenciales

El motor deberá probarse, al menos, con:

- Novela PDF con texto seleccionable.
- PDF con saltos de página y encabezados.
- PDF con dos columnas.
- PDF escaneado.
- Libro largo.
- Cambios repetidos de orientación y tamaño de letra.
- Avances y retrocesos consecutivos.
- Cierre y reapertura de la aplicación.
- Varios marcadores en un mismo libro.
- Archivos dañados o que no puedan leerse.
- Pantallas pequeñas y grandes.

Se comprobarán especialmente la ausencia de omisiones, las repeticiones excesivas y la recuperación exacta del punto de lectura.

## 15. Criterios de éxito del primer prototipo

El prototipo será satisfactorio si:

1. Se puede importar y abrir un PDF compatible desde Android.
2. La lectura adaptativa funciona con una novela de texto corrido.
3. Los toques laterales permiten avanzar y retroceder de forma predecible.
4. El cambio de orientación y tipografía mantiene el pasaje actual.
5. La posición automática se restaura al reabrir el libro.
6. La interfaz no distrae durante la lectura.
7. Los documentos que no se extraen correctamente no se presentan como si fueran texto fiable.

## 16. Decisiones de producto fijadas

- **Nombre:** Pasapagina.
- **Lema:** «Lee a tu manera».
- **Plataforma inicial:** Android.
- **Tecnología de interfaz:** Flutter.
- **Estilo:** alegre y simpático, con mascota de libro.
- **Tema inicial:** crema cálido.
- **Controles durante la lectura:** ocultos por defecto; visibles temporalmente al tocar el centro.
- **Modo predeterminado:** lectura adaptativa.
- **Modo alternativo:** PDF original.
- **Formatos:** PDF primero; arquitectura preparada para EPUB.
- **Navegación:** toque derecho para avanzar y toque izquierdo para retroceder.
- **Progreso:** posición automática y marcadores manuales separados.
- **Privacidad:** funcionamiento local sin cuenta obligatoria.

---

**Siguiente paso:** implementar la estructura inicial de Flutter y validar la continuidad de lectura con PDF reales antes de ampliar la aplicación.