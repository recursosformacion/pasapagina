import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdfrx/pdfrx.dart';

import '../services/pdf_text_extractor.dart';
import '../services/read_position_service.dart';
import '../services/library_service.dart';
import '../services/marker_service.dart';
import '../services/read_settings_service.dart';
import '../models/marker.dart';
import '../models/read_settings.dart';
import '../models/chapter.dart';
import 'markers_screen.dart';
import 'reading_settings_screen.dart';

enum ReaderMode { adaptive, original }

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.path, required this.title, this.initialPosition});

  final String path;
  final String title;
  final double? initialPosition;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _extractor = PdfTextExtractor();
  final _scrollController = ScrollController();
  final _textKey = GlobalKey();
  static const double _textTopPadding = 36;
  final _positionService = ReadPositionService();
  final _libraryService = LibraryService();
  final _markerService = MarkerService();
  final _settingsService = ReadSettingsService();
  ReadSettings _settings = const ReadSettings();
  ExtractedPdf? _document;
  String? _error;
  bool _loading = true;
  bool _controlsVisible = false;
  ReaderMode _mode = ReaderMode.adaptive;
  double _fontSize = 20;
  int _anchor = 0;
  Timer? _positionSaveTimer;
  double _scaleStartFontSize = 20;
  bool _scalingText = false;

  Color get _bgColor {
    switch (_settings.theme) {
      case 'white':
        return Colors.white;
      case 'dark':
        return const Color(0xFF2A2A2A);
      case 'cream':
      default:
        return const Color(0xFFF5EBD8);
    }
  }

  Color get _inkColor {
    switch (_settings.theme) {
      case 'white':
        return const Color(0xFF1A1A1A);
      case 'dark':
        return const Color(0xFFF5EBD8);
      case 'cream':
      default:
        return const Color(0xFF34342F);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadText();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings(widget.path);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _fontSize = settings.fontSize;
    });
  }

  Future<void> _loadText() async {
    try {
      final extracted = await _extractor.extract(widget.path);
      if (!mounted) return;
      setState(() {
        _document = extracted;
        _loading = false;
      });
      await _restorePosition();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _restorePosition() async {
    final saved = await _positionService.load(widget.path);
    final target = widget.initialPosition ?? saved;
    if (!mounted || _document == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients || _document == null) return;
      final extent = _scrollController.position.maxScrollExtent;
      final index = target.round().clamp(0, _document!.fullText.length);
      final offset = _offsetForTextIndex(index);
      _scrollController.jumpTo(offset.clamp(0.0, extent));
    });
  }

  RenderParagraph? get _textParagraph {
    final renderObject = _textKey.currentContext?.findRenderObject();
    return renderObject is RenderParagraph ? renderObject : null;
  }

  int _currentTextIndex() {
    final document = _document;
    if (document == null || document.fullText.isEmpty || !_scrollController.hasClients) {
      return 0;
    }

    final paragraph = _textParagraph;
    if (paragraph != null) {
      // The paragraph starts below the top padding inside the scroll view.
      final localY = (_scrollController.offset - _textTopPadding)
          .clamp(0.0, paragraph.size.height);
      final index = paragraph
          .getPositionForOffset(Offset(0, localY))
          .offset;
      return index.clamp(0, document.fullText.length);
    }

    // Defensive fallback for Flutter versions where SelectableText does not
    // expose its paragraph render object through the key.
    final extent = _scrollController.position.maxScrollExtent;
    final ratio = extent > 0 ? (_scrollController.offset / extent).clamp(0.0, 1.0) : 0.0;
    return (ratio * document.fullText.length).round();
  }

  double _offsetForTextIndex(int index) {
    final document = _document;
    if (document == null || document.fullText.isEmpty || !_scrollController.hasClients) {
      return 0;
    }

    final paragraph = _textParagraph;
    if (paragraph != null) {
      final safeIndex = index.clamp(0, document.fullText.length);
      final caret = paragraph.getOffsetForCaret(
        TextPosition(offset: safeIndex),
        Rect.zero,
      );
      return caret.dy + _textTopPadding;
    }

    final extent = _scrollController.position.maxScrollExtent;
    final ratio = (index / document.fullText.length).clamp(0.0, 1.0);
    return ratio * extent;
  }

  void _rememberAnchor() {
    if (_scalingText) return;
    if (_scrollController.hasClients && _document != null) {
      _anchor = _currentTextIndex();
      final savedIndex = _anchor.toDouble();
      _positionSaveTimer?.cancel();
      _positionSaveTimer = Timer(const Duration(milliseconds: 650), () {
        _persistPosition(savedIndex);
      });
    }
  }

  Future<void> _persistPosition(double position) async {
    await _positionService.save(widget.path, position);
    await _libraryService.updatePosition(widget.path, position);
  }

  void _restoreAnchorAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients || _document == null) return;
      final extent = _scrollController.position.maxScrollExtent;
      final offset = _offsetForTextIndex(_anchor);
      _scrollController.jumpTo(offset.clamp(0.0, extent));
    });
  }

  void _changeFont(double value) {
    _rememberAnchor();
    setState(() => _fontSize = value);
    _settingsService.saveSettings(_settings.copyWith(fontSize: value), widget.path);
    _restoreAnchorAfterLayout();
  }

  String _textFragmentAt() {
    if (_document == null) return '';
    if (_document!.fullText.isEmpty) return '';
    final index = _currentTextIndex().clamp(0, _document!.fullText.length - 1);
    const half = 60;
    final start = (index - half).clamp(0, _document!.fullText.length);
    final end = (index + half).clamp(0, _document!.fullText.length);
    return _document!.fullText.substring(start, end).trim();
  }

  Future<void> _addMarker() async {
    if (_scrollController.hasClients == false) return;
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Añadir marcador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Etiqueta opcional',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            Text(
              _textFragmentAt(),
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final charIndex = _currentTextIndex().toDouble();
    await _markerService.saveMarker(
      Marker(
        id: '${widget.path}:${DateTime.now().millisecondsSinceEpoch}',
        bookId: widget.path,
        position: charIndex,
        label: result.isEmpty ? null : result,
        createdAt: DateTime.now(),
        textFragment: _textFragmentAt(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcador guardado')),
    );
  }

  Future<void> _openChapterIndex() async {
    if (_document == null || _document!.chapters.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se detectaron capítulos en este libro.')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView.builder(
          itemCount: _document!.chapters.length,
          itemBuilder: (_, i) {
            final chapter = _document!.chapters[i];
            return ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(chapter.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: chapter.pageIndex != null ? Text('Página ${chapter.pageIndex! + 1}') : null,
              onTap: () {
                Navigator.pop(context);
                _jumpToChapter(chapter);
              },
            );
          },
        ),
      ),
    );
  }

  void _jumpToChapter(Chapter chapter) {
    if (!_scrollController.hasClients || _document == null) return;
    final extent = _scrollController.position.maxScrollExtent;
    final ratio = _document!.fullText.isNotEmpty ? (chapter.startIndex / _document!.fullText.length).clamp(0.0, 1.0) : 0.0;
    final offset = ratio * extent;
    _scrollController.animateTo(
      offset.clamp(0.0, extent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _step(int direction) {
    if (!_scrollController.hasClients || _document == null) return;
    final amount = MediaQuery.sizeOf(context).height * 0.85;
    final target = (_scrollController.offset + amount * direction)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _positionSaveTimer?.cancel();
    if (_scrollController.hasClients && _document != null) {
      final charIndex = _currentTextIndex().toDouble();
      _libraryService.markRead(
        widget.path,
        time: DateTime.now(),
        position: charIndex,
      );
      _persistPosition(charIndex);
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (_mode == ReaderMode.original)
              PdfViewer.file(widget.path)
            else if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_document == null)
              _buildExtractionFallback()
            else
              _buildAdaptiveText(),
            if (_mode == ReaderMode.adaptive && _document != null)
              _buildPageMargins(),
            if (_mode == ReaderMode.adaptive)
              _buildCenterTap(),
            if (_controlsVisible) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveText() {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _rememberAnchor();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(_settings.margins, _textTopPadding, _settings.margins, 48),
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: SelectableText(
            key: _textKey,
            _document!.fullText,
            style: TextStyle(
              fontSize: _fontSize,
              height: _settings.lineHeight,
              color: _inkColor,
              fontFamily: _settings.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _rememberAnchor();
    _scalingText = true;
    _scaleStartFontSize = _fontSize;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newSize = (_scaleStartFontSize * details.scale).clamp(14.0, 34.0);
    if ((newSize - _fontSize).abs() < 0.15) return;
    setState(() => _fontSize = newSize);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scalingText = false;
    _settingsService.saveSettings(_settings.copyWith(fontSize: _fontSize), widget.path);
    _restoreAnchorAfterLayout();
  }

  Widget _buildPageMargins() {
    return Positioned.fill(
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _step(-1),
              child: const SizedBox.expand(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 70,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _step(1),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterTap() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => setState(() => _controlsVisible = !_controlsVisible),
          child: const SizedBox(width: 90, height: 120),
        ),
      ),
    );
  }

  Widget _buildExtractionFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 54, color: Color(0xFF4F8A7B)),
            const SizedBox(height: 16),
            Text(
              'No se ha podido preparar la lectura adaptable',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _inkColor),
            ),
            const SizedBox(height: 10),
            Text(_error ?? 'El documento no contiene texto extraíble.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => setState(() {
                _mode = ReaderMode.original;
                _controlsVisible = false;
              }),
              child: const Text('Abrir PDF original'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Material(
        color: _bgColor.withValues(alpha: 0.97),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Volver a la biblioteca',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF34342F)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ocultar controles',
                    onPressed: () => setState(() => _controlsVisible = false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.text_decrease_rounded),
                  Expanded(
                    child: Slider(
                      min: 14,
                      max: 34,
                      divisions: 10,
                      value: _fontSize,
                      label: _fontSize.round().toString(),
                      onChanged: _changeFont,
                    ),
                  ),
                  const Icon(Icons.text_increase_rounded),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.bookmark_add_rounded),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _addMarker,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Añadir marcador'),
                    ),
                  ),
                  const Icon(Icons.bookmark_rounded),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MarkersScreen(bookId: widget.path, bookTitle: widget.title),
                        ),
                      ),
                      icon:                   const Icon(Icons.list, size: 18),
                      label: const Text('Ver marcadores'),
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReadingSettingsScreen(bookId: widget.path),
                  ),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Ajustes de lectura'),
              ),
              FilledButton.icon(
                onPressed: _openChapterIndex,
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text('Índice de capítulos'),
              ),
              SegmentedButton<ReaderMode>(
                segments: const [
                  ButtonSegment(value: ReaderMode.adaptive, label: Text('Lectura adaptable')),
                  ButtonSegment(value: ReaderMode.original, label: Text('PDF original')),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) => setState(() {
                  _mode = selection.first;
                  _controlsVisible = false;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
