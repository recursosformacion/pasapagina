import 'package:flutter_test/flutter_test.dart';
import 'package:pasapagina/services/pdf_text_extractor.dart';

void main() {
  group('PdfTextExtractor.detectChapters', () {
    test('does not mistake prose beginning with “parte” for a chapter', () {
      const text = 'Capítulo 7\nContenido del capítulo.\n'
          'parte del panel, Y se me ha ocurrido una idea.\n'
          'Capítulo 8\nContenido del siguiente capítulo.';

      final chapters = PdfTextExtractor.detectChapters(text, [text]);

      expect(chapters.map((chapter) => chapter.title).toList(), [
        'Capítulo 7',
        'Capítulo 8',
      ]);
      expect(chapters[1].startIndex, text.indexOf('Capítulo 8'));
    });

    test('recognizes numbered parts and preserves their exact text position', () {
      const firstPage = 'Introducción\nTexto introductorio.';
      const secondPage = 'Parte II\nNuevo contenido.';
      final text = '$firstPage\n$secondPage';

      final chapters = PdfTextExtractor.detectChapters(
        text,
        [firstPage, secondPage],
      );

      expect(chapters, hasLength(1));
      expect(chapters.single.title, 'Parte II');
      expect(chapters.single.startIndex, text.indexOf('Parte II'));
      expect(chapters.single.pageIndex, 1);
    });
  });
}
