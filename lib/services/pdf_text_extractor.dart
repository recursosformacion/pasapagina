import 'package:pdfrx/pdfrx.dart';

import '../models/chapter.dart';

class ExtractedPdf {
  const ExtractedPdf({
    required this.pageTexts,
    required this.fullText,
    this.chapters = const <Chapter>[],
  });

  final List<String> pageTexts;
  final String fullText;
  final List<Chapter> chapters;
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
      final chapters = detectChapters(fullText, pageTexts);
      return ExtractedPdf(pageTexts: pageTexts, fullText: fullText, chapters: chapters);
    } finally {
      document.dispose();
    }
  }

  /// Heurística para detectar encabezados de capítulo en el texto normalizado.
  static List<Chapter> detectChapters(String fullText, List<String> pageTexts) {
    final chapters = <Chapter>[];
    if (fullText.isEmpty) return chapters;

    final lines = fullText.split('\n');
    int offset = 0;
    int? pageIndexFor(int charIndex) {
      int acc = 0;
      for (int i = 0; i < pageTexts.length; i++) {
        final page = pageTexts[i].trim();
        if (page.isEmpty) continue;
        if (charIndex < acc + page.length + 2) return i;
        acc += page.length + 2;
      }
      return pageTexts.length - 1;
    }

    // Avoid guessing from arbitrary uppercase lines or isolated paragraphs:
    // those heuristics can turn ordinary body text into false chapters.
    final explicitHeading = RegExp(
      r'^(cap[ií]tulo|chapter|parte|part|secci[oó]n|section|cap\.|libro|book)\b',
      caseSensitive: false,
    );
    final numberedHeading = RegExp(
      r'^(?:\d{1,3}[.)]|[IVXLCDM]{1,8}[.)])\s+[A-ZÁÉÍÓÚÑ]',
      caseSensitive: false,
    );
    final standaloneRoman = RegExp(r'^[IVXLCDM]{1,8}$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final isShortTitle = line.length >= 3 && line.length <= 80;
      final isHeader = isShortTitle &&
          (explicitHeading.hasMatch(line) ||
              numberedHeading.hasMatch(line) ||
              standaloneRoman.hasMatch(line));

      if (isHeader) {
        chapters.add(Chapter(
          title: line,
          startIndex: offset,
          pageIndex: pageIndexFor(offset),
        ));
      }
      offset += lines[i].length + 1;
    }

    // Set endIndex for each chapter
    for (int i = 0; i < chapters.length; i++) {
      final nextStart = i + 1 < chapters.length ? chapters[i + 1].startIndex : fullText.length;
      chapters[i] = Chapter(
        title: chapters[i].title,
        startIndex: chapters[i].startIndex,
        endIndex: nextStart,
        pageIndex: chapters[i].pageIndex,
      );
    }

    return chapters;
  }
}

class PdfExtractionException implements Exception {
  const PdfExtractionException(this.message);
  final String message;

  @override
  String toString() => message;
}
