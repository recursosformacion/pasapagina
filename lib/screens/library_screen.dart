import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'reader_screen.dart';
import '../services/read_position_service.dart';

class LibraryScreen extends StatelessWidget {
  LibraryScreen({super.key});

  final _libraryService = LibraryService();

  Future<void> _openPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (!context.mounted) return;
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo acceder al archivo seleccionado.')),
      );
      return;
    }
    await _libraryService.addBook(path);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReaderScreen(path: path, title: result.files.single.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 30),
            SizedBox(width: 10),
            Text('Pasapagina', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 116,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3A34B).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.menu_book_rounded, size: 66, color: Color(0xFF4F8A7B)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu próxima aventura empieza aquí',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF34342F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Abre un PDF y ajusta la lectura a tu manera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () => _openPdf(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Añadir un PDF'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Prototipo inicial · los libros se abren desde tu dispositivo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF68665D)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
