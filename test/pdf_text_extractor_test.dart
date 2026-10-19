import 'package:flutter_test/flutter_test.dart';
import 'package:pasapagina/services/pdf_text_extractor.dart';

void main() {
  group('PdfTextExtractor.normalizePageText', () {
    test('preserves line breaks needed for paragraphs and chapter headings', () {
      const raw = 'La primera línea del párrafo\n'
          'continúa aquí.\n\n'
          'Capítulo 2. El siguiente tema\n'
          'Contenido del capítulo.';
      expect(
        PdfTextExtractor.normalizePageText(raw),
        'La primera línea del párrafo\ncontinúa aquí.\n\n'
        'Capítulo 2. El siguiente tema\nContenido del capítulo.',
      );
    });
  });

  group('PdfTextExtractor.detectChapters', () {
    test('detects explicit and numbered chapters without treating body text as a chapter', () {
      const text = 'Introducción\n\nCapítulo 11. La música\n\n'
          'Este es un párrafo normal que explica el tema.\n'
          'UNA FRASE EN MAYÚSCULAS QUE NO ES UN CAPÍTULO\n'
          'Y un bloque de texto que antes se confundía con un título.\n\n'
          '14. La siguiente parte\n\nContenido final';
      final chapters = PdfTextExtractor.detectChapters(text, [text]);

      expect(chapters.map((chapter) => chapter.title).toList(), [
        'Capítulo 11. La música',
        '14. La siguiente parte',
      ]);
      expect(
        text.substring(chapters.first.startIndex,
            chapters.first.startIndex + chapters.first.title.length),
        chapters.first.title,
      );
      expect(chapters.last.startIndex, greaterThan(chapters.first.startIndex));
    });

    test('keeps chapter offsets aligned across blank lines', () {
      const text = 'Texto inicial\n\nChapter 2: Next\n\nContenido';
      final chapters = PdfTextExtractor.detectChapters(text, [text]);

      expect(chapters.single.startIndex, text.indexOf('Chapter 2: Next'));
      expect(chapters.single.endIndex, text.length);
    });
  });
}
