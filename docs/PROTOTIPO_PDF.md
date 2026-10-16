# Prototipo PDF de Pasapagina

## Incluido en esta primera base

- Aplicación Flutter con tema crema y acentos naranja/verde agua.
- Selector de documentos para elegir un PDF local.
- Extracción de texto por páginas mediante `pdfrx`.
- Vista de texto redistribuida por Flutter y control de tamaño.
- Toques en los márgenes para avanzar y retroceder.
- Vista PDF original para documentos escaneados o cuya extracción no funcione.

## Ejecutar en Android

Desde la raíz del repositorio, en un entorno con Flutter instalado:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Si el proyecto aún no tiene las carpetas nativas generadas por Flutter, ejecuta `flutter create . --platforms=android` desde la raíz antes de compilar.

## Límites conocidos

Este es un prototipo de interacción, no una versión terminada. La lectura adaptativa inicial concatena el texto extraído de cada página; PDFs con columnas, encabezados, notas o un orden de lectura complejo pueden necesitar un algoritmo de reconstrucción más avanzado. Los PDF escaneados sin capa de texto se envían al modo original; OCR queda fuera de esta fase.

La posición de lectura y los marcadores todavía no se guardan de forma persistente. El cambio de tamaño conserva una aproximación de la posición por desplazamiento, pero aún no usa un ancla semántica de párrafo/caracteres. Eso debe resolverse antes de considerar cumplida la continuidad prometida por Pasapagina.

## Siguiente trabajo técnico

1. Ejecutar análisis, pruebas y compilación en la versión Flutter disponible en el equipo.
2. Probar con una novela PDF real y revisar el orden del texto extraído.
3. Sustituir el desplazamiento aproximado por un ancla de texto estable.
4. Añadir almacenamiento local para biblioteca, reanudación y marcadores independientes.
5. Añadir pruebas con PDFs de varias columnas y escaneados.
