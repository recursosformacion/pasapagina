import 'package:flutter/material.dart';

import '../models/marker.dart';
import '../services/marker_service.dart';
import 'reader_screen.dart';

class MarkersScreen extends StatefulWidget {
  const MarkersScreen({super.key, required this.bookId, required this.bookTitle});

  final String bookId;
  final String bookTitle;

  @override
  State<MarkersScreen> createState() => _MarkersScreenState();
}

class _MarkersScreenState extends State<MarkersScreen> {
  final _markerService = MarkerService();
  List<Marker> _markers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final markers = await _markerService.getMarkersForBook(widget.bookId);
    if (!mounted) return;
    setState(() {
      _markers = markers;
      _loading = false;
    });
  }

  Future<void> _remove(Marker marker) async {
    await _markerService.removeMarker(marker.id);
    await _load();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marcadores de ${widget.bookTitle}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _markers.isEmpty
              ? const Center(child: Text('No hay marcadores en este libro.'))
              : ListView.builder(
                  itemCount: _markers.length,
                  itemBuilder: (_, i) {
                    final marker = _markers[i];
                    return Dismissible(
                      key: Key(marker.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _remove(marker),
                      child: ListTile(
                        leading: const Icon(Icons.bookmark, color: Colors.orange),
                        title: Text(
                          marker.label ?? 'Sin etiqueta',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (marker.textFragment != null)
                              Text(
                                marker.textFragment!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            Text(
                              _formatDate(marker.createdAt),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ReaderScreen(
                                path: widget.bookId,
                                title: widget.bookTitle,
                                initialPosition: marker.position,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
