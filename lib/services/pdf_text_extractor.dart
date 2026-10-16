import 'package:pdfrx/pdfrx.dart';

class ExtractedPdf {
  const ExtractedPdf({
    required this.pageTexts,
    required this.fullText,
  });

  final List<String> pageTexts;
  final String fullText;
}

class PdfTextExtractor {
  /// Extracts selectable text page by page. Image-only/scanned PDFs return
  /// little or no text and should be opened in original-page mode instead.
  Future<ExtractedPdf> extract(String path) async {
    final document = await PdfDocument.openFile(path);
    try {
      final pageTexts = <String>[];
      for (final page in document.pages) {
        final raw = await page.loadText();
        pageTexts.add((raw?.fullText ?? '').trim());
      }
      final usable = pageTexts.where((text) => text.isNotEmpty).length;
      final fullText = pageTexts.where((text) => text.isNotEmpty).join('\n\n');
      if (usable == 0 || fullText.trim().length < 40) {
        throw const PdfExtractionException(
          'Este PDF no contiene suficiente texto seleccionable. Puede ser un documento escaneado; prueba el modo PDF original.',
        );
      }
      return ExtractedPdf(pageTexts: pageTexts, fullText: fullText);
    } finally {
      document.dispose();
    }
  }
}

class PdfExtractionException implements Exception {
  const PdfExtractionException(this.message);
  final String message;

  @override
  String toString() => message;
}
