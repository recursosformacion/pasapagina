import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/library_service.dart';
import '../services/read_position_service.dart';
import 'reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _libraryService = LibraryService();
  final _positionService = ReadPositionService();
  List<Book> _books = [];
  List<Book> _displayed = [];
  String _query = '';
  String _sortBy = 'lastRead';
  bool _loading = true;
  String? _loadError;
  bool _hasAutoOpened = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks({bool autoOpenLastRead = true}) async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final books = await _libraryService.getAllBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _displayed = _applyFilters(books);
        _loading = false;
      });
      // Si hay un libro en curso (último leído), abrirlo automáticamente.
      if (!autoOpenLastRead || _hasAutoOpened) return;
      final inProgress = _libraryService.getReadingInProgress(books);
      if (inProgress.isNotEmpty && mounted) {
        _hasAutoOpened = true;
        await _openBook(inProgress.first);
      }
    } catch (error, stackTrace) {
      debugPrint('Error al cargar la biblioteca: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'No se pudo cargar la biblioteca. Puedes volver a intentarlo.';
      });
    }
  }

  List<Book> _applyFilters(List<Book> books) {
    final sorted = _libraryService.sortBooks(books, _sortBy);
    return _libraryService.searchBooks(sorted, _query);
  }

  List<Book> get _readingInProgress =>
      _libraryService.getReadingInProgress(_books);

  void _onSearch(String value) {
    setState(() {
      _query = value;
      _displayed = _applyFilters(_books);
    });
  }

  void _onSort(String? value) {
    if (value == null) return;
    setState(() {
      _sortBy = value;
      _displayed = _applyFilters(_books);
    });
  }

  Future<void> _addPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo acceder al archivo seleccionado.')),
      );
      return;
    }
    final book = Book(
      id: path,
      title: result.files.single.name,
      dateAdded: DateTime.now(),
    );
    await _libraryService.addOrUpdateBook(book);
    if (!mounted) return;
    await _loadBooks(autoOpenLastRead: false);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReaderScreen(path: path, title: book.title),
      ),
    );
    if (!mounted) return;
    await _loadBooks(autoOpenLastRead: false);
  }

  Future<void> _openBook(Book book) async {
    await _libraryService.markRead(book.id, time: DateTime.now(), position: book.position);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReaderScreen(path: book.id, title: book.title, initialPosition: book.position),
      ),
    );
    if (!mounted) return;
    await _loadBooks(autoOpenLastRead: false);
  }

  Future<void> _renameBook(Book book) async {
    final controller = TextEditingController(text: book.title);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar título'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!mounted || result == null || result.isEmpty || result == book.title) return;
    await _libraryService.updateBookTitle(book.id, result);
    await _loadBooks(autoOpenLastRead: false);
  }

  Future<void> _removeBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirar de la biblioteca'),
        content: Text('¿Retirar "${book.title}" de la biblioteca? El archivo original no se borrará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    await _positionService.remove(book.id);
    await _libraryService.removeBook(book.id);
    await _loadBooks(autoOpenLastRead: false);
  }

  Widget _bookTile(Book book, {bool inProgress = false}) {
    return ListTile(
      leading: book.coverBase64 != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(book.coverBase64!),
                width: 56,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 56,
                  height: 80,
                  child: Icon(Icons.menu_book_rounded, size: 34, color: Colors.orange),
                ),

            ),
      title: Text(
        book.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: book.author != null
          ? Text(book.author!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : inProgress
              ? const Text('Sigue leyendo')
              : const Text('Sin autor'),
      trailing: inProgress
          ? const Icon(Icons.play_circle_fill_rounded, color: Colors.orange)
          : null,
      onTap: () => _openBook(book),
      onLongPress: () => _showBookMenu(book),
    );
  }

  void _showBookMenu(Book book) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Cambiar título'),
            onTap: () {
              Navigator.pop(context);
              _renameBook(book);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Retirar de la biblioteca', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _removeBook(book);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
    );
  }

  Widget _buildReadingInProgress() {
    if (_readingInProgress.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Sigue leyendo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _readingInProgress.length,
            itemBuilder: (_, i) {
              final book = _readingInProgress[i];
              return SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openBook(book),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.coverBase64 != null
                            ? Image.memory(
                                base64Decode(book.coverBase64!),
                                width: 120,
                                height: 110,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 120,
                                height: 110,
                                color: const Color(0xFFF3A34B).withValues(alpha: 0.28),
                                child: const Icon(Icons.menu_book_rounded, size: 40, color: Color(0xFF4F8A7B)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const Text(
                      'Sigue leyendo',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
        actions: [
          PopupMenuButton<String>(
            onSelected: _onSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'lastRead', child: Text('Última lectura')),
              PopupMenuItem(value: 'title', child: Text('Título')),
              PopupMenuItem(value: 'dateAdded', child: Text('Fecha de incorporación')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 44),
                        const SizedBox(height: 12),
                        Text(_loadError!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _loadBooks(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
              children: [
                if (_readingInProgress.isNotEmpty) _buildReadingInProgress(),
                Expanded(
                  child: _books.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Buscar por título o autor',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: _onSearch,
                              ),
                            ),
                            Expanded(
                              child: _displayed.isEmpty
                                  ? const Center(child: Text('No se encontraron libros.'))
                                  : ListView.builder(
                                      itemCount: _displayed.length,
                                      itemBuilder: (_, i) {
                                        final book = _displayed[i];
                                        final inProgress = _readingInProgress.any((b) => b.id == book.id);
                                        return _bookTile(book, inProgress: inProgress);
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPdf,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir un PDF'),
      ),
    );
  }
}
