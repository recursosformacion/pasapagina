import 'package:flutter_test/flutter_test.dart';
import 'package:pasapagina/services/pdf_text_extractor.dart';

void main() {
  test('extraction exception exposes a readable message', () {
    const error = PdfExtractionException('PDF sin texto');
    expect(error.toString(), 'PDF sin texto');
  });
}
