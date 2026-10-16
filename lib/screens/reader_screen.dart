import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../services/pdf_text_extractor.dart';

enum ReaderMode { adaptive, original }

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _extractor = PdfTextExtractor();
  final _scrollController = ScrollController();
  ExtractedPdf? _document;
  String? _error;
  bool _loading = true;
  bool _controlsVisible = false;
  ReaderMode _mode = ReaderMode.adaptive;
  double _fontSize = 20;
  int _anchor = 0;

  static const _paper = Color(0xFFF5EBD8);
  static const _ink = Color(0xFF34342F);

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _loadText() async {
    try {
      final extracted = await _extractor.extract(widget.path);
      if (!mounted) return;
      setState(() {
        _document = extracted;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _rememberAnchor() {
    if (_scrollController.hasClients) {
      _anchor = _scrollController.offset.round();
    }
  }

  void _changeFont(double value) {
    _rememberAnchor();
    setState(() => _fontSize = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _anchor.toDouble().clamp(0, _scrollController.position.maxScrollExtent),
        );
      }
    });
  }

  void _step(int direction) {
    if (!_scrollController.hasClients || _document == null) return;
    final amount = MediaQuery.sizeOf(context).height * 0.72;
    final target = (_scrollController.offset + amount * direction)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mode == ReaderMode.adaptive ? _paper : Colors.white,
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
              Positioned.fill(
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _step(-1),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 42,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _step(1),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
            if (_mode == ReaderMode.adaptive)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => setState(() => _controlsVisible = !_controlsVisible),
                    child: const SizedBox(width: 90, height: 120),
                  ),
                ),
              ),
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
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 48),
        child: SelectableText(
          _document!.fullText,
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.62,
            color: _ink,
            fontFamily: 'serif',
          ),
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
            const Text(
              'No se ha podido preparar la lectura adaptable',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink),
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
        color: _paper.withValues(alpha: 0.97),
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
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
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
