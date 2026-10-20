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
        pageTexts.add(normalizePageText(raw?.fullText ?? ''));
      }
      final usable = pageTexts.where((text) => text.isNotEmpty).length;
      final fullText = pageTexts.where((text) => text.isNotEmpty).join('\n');
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

  /// Conserva los saltos que entrega el extractor PDF. Son necesarios para
  /// separar encabezados y párrafos; unirlos todos hace que el índice pierda
  /// los capítulos y que los títulos queden pegados al texto.
  static String normalizePageText(String rawText) {
    final text = rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = text.split('\n').map((line) => line.trimRight()).toList();
    return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  /// Detecta encabezados conservadoramente para no convertir frases del texto
  /// normal en capítulos. Los números sueltos de listas no son suficientes.
  static List<Chapter> detectChapters(String fullText, List<String> pageTexts) {
    final chapters = <Chapter>[];
    if (fullText.isEmpty) return chapters;

    final lines = fullText.split('\n');
    int offset = 0;

    int? pageIndexFor(int charIndex) {
      var acc = 0;
      for (var i = 0; i < pageTexts.length; i++) {
        final page = pageTexts[i].trim();
        if (page.isEmpty) continue;
        if (charIndex < acc + page.length + 1) return i;
        acc += page.length + 1;
      }
      return pageTexts.length - 1;
    }

    // A heading marker must be followed by a number, Roman numeral or
    // ordinal. In particular, "parte del panel..." is ordinary prose.
    final explicitHeading = RegExp(
      r'^(?:cap[ií]tulo|chapter|cap\.|libro|book|parte|part|secci[oó]n|section)\s+(?:(?:n[úu]m(?:ero)?\.?\s*)?\d{1,3}|[IVXLCDM]{1,8}|prim(?:er|ero|era)|segund[oa]|tercer[oa]|cuart[oa]|quint[oa]|sext[oa]|s[eé]ptim[oa]|octav[oa]|noven[oa]|d[eé]cim[oa])(?:\s*(?:[:.\-–—])\s*.*)?$',
      caseSensitive: false,
    );
    final standaloneRoman = RegExp(r'^[IVXLCDM]{1,8}$');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final isShortTitle = line.length >= 3 && line.length <= 80;
      final isHeader = isShortTitle &&
          (explicitHeading.hasMatch(line) || standaloneRoman.hasMatch(line));

      if (isHeader) {
        chapters.add(Chapter(
          title: line,
          startIndex: offset + lines[i].indexOf(line),
          pageIndex: pageIndexFor(offset),
        ));
      }
      offset += lines[i].length + 1;
    }

    // The end of each chapter is the start of the next one.
    for (var i = 0; i < chapters.length; i++) {
      final nextStart = i + 1 < chapters.length
          ? chapters[i + 1].startIndex
          : fullText.length;
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
