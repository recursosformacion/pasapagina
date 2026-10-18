# Prototipo PDF de Pasapagina

## Incluido actualmente

- Aplicación Flutter con tema crema y acentos naranja/verde agua.
- Selector de documentos para elegir un PDF local.
- Extracción de texto por páginas mediante `pdfrx`.
- Vista de texto redistribuida por Flutter y control de tamaño.
- Toques en los márgenes para avanzar y retroceder.
- Vista PDF original para documentos escaneados o cuya extracción no funcione.
- Biblioteca local, ajustes de lectura, posiciones de reanudación y marcadores guardados en el dispositivo.
- Índice de capítulos cuando se pueden detectar títulos.

## Validación

Los cambios deben comprobarse con `flutter analyze`, `flutter test` y una compilación Android en el entorno de destino. La existencia de estas instrucciones no implica que la última configuración Gradle esté validada.

## Límites conocidos

La lectura adaptable concatena el texto extraído de cada página. PDFs con columnas, encabezados, notas o un orden de lectura complejo pueden necesitar un algoritmo de reconstrucción más avanzado. Los PDF escaneados sin capa de texto se abren en modo original; OCR no está implementado.

La posición guardada sigue siendo una estimación basada en la proporción del desplazamiento y la longitud total del texto, no un ancla semántica estable de párrafo y carácter. Por eso, cambiar el tamaño, la orientación o la distribución del texto puede no conservar exactamente el mismo pasaje. La clave de posición se basa en la ruta completa para evitar colisiones entre archivos con el mismo nombre; se conserva una migración desde las claves antiguas por nombre.

La persistencia se realiza localmente mediante `shared_preferences`; no hay sincronización entre dispositivos ni copia en la nube.

## Próximas mejoras

1. Probar con novelas PDF reales y revisar el orden del texto extraído.
2. Diseñar un ancla semántica estable para restaurar el pasaje exacto tras cambios de tamaño u orientación.
3. Añadir pruebas de regresión para reanudación, marcadores y cambios de tamaño.
4. Evaluar PDFs de varias columnas y documentos escaneados.
5. Validar la configuración Android/Gradle actual en una compilación limpia.
