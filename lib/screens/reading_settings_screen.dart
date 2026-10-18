import 'package:flutter/material.dart';

import '../services/read_settings_service.dart';
import '../models/read_settings.dart';

class ReadingSettingsScreen extends StatefulWidget {
  const ReadingSettingsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<ReadingSettingsScreen> createState() => _ReadingSettingsScreenState();
}

class _ReadingSettingsScreenState extends State<ReadingSettingsScreen> {
  final _service = ReadSettingsService();
  ReadSettings _settings = const ReadSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _service.loadSettings(widget.bookId);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _service.saveSettings(_settings, widget.bookId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajustes guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de lectura')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tema', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'cream', label: Text('Crema')),
              ButtonSegment(value: 'white', label: Text('Blanco')),
              ButtonSegment(value: 'dark', label: Text('Oscuro')),
            ],
            selected: {_settings.theme},
            onSelectionChanged: (s) => setState(() => _settings = _settings.copyWith(theme: s.first)),
          ),
          const SizedBox(height: 24),
          const Text('Tipografía', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'serif', label: Text('Serif')),
              ButtonSegment(value: 'sansSerif', label: Text('Sans serif')),
            ],
            selected: {_settings.fontFamily},
            onSelectionChanged: (s) => setState(() => _settings = _settings.copyWith(fontFamily: s.first)),
          ),
          const SizedBox(height: 24),
          _buildSlider('Tamaño de letra', _settings.fontSize, 10, 60, 1, (v) => setState(() => _settings = _settings.copyWith(fontSize: v)), _settings.fontSize.round().toString()),
          const SizedBox(height: 16),
          _buildSlider('Interlineado', _settings.lineHeight, 1.0, 2.4, 0.1, (v) => setState(() => _settings = _settings.copyWith(lineHeight: v)), _settings.lineHeight.toStringAsFixed(1)),
          const SizedBox(height: 16),
          _buildSlider('Márgenes', _settings.margins, 16, 56, 4, (v) => setState(() => _settings = _settings.copyWith(margins: v)), '${_settings.margins.round()}px'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Guardar ajustes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, double divisions, ValueChanged<double> onChanged, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(labelText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          min: min,
          max: max,
          divisions: ((max - min) / divisions).round(),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
