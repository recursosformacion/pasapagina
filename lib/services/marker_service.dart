import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/marker.dart';

class MarkerService {
  static const _key = 'library_markers';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<List<Marker>> _readAll() async {
    final prefs = await _prefs();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final markers = <Marker>[];
    for (final e in raw) {
      try {
        markers.add(Marker.fromJson(jsonDecode(e) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupt entries
      }
    }
    return markers;
  }

  Future<void> _writeAll(List<Marker> markers) async {
    final prefs = await _prefs();
    await prefs.setStringList(_key, markers.map((m) => jsonEncode(m.toJson())).toList());
  }

  /// Guarda o actualiza un marcador.
  Future<void> saveMarker(Marker marker) async {
    final markers = await _readAll();
    final index = markers.indexWhere((m) => m.id == marker.id);
    if (index >= 0) {
      markers[index] = marker;
    } else {
      markers.add(marker);
    }
    markers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _writeAll(markers);
  }

  /// Lee todos los marcadores de un libro, ordenados por fecha descendente.
  Future<List<Marker>> getMarkersForBook(String bookId) async {
    final all = await _readAll();
    return all.where((m) => m.bookId == bookId).toList();
  }

  /// Elimina un marcador por id.
  Future<void> removeMarker(String id) async {
    final markers = await _readAll()..removeWhere((m) => m.id == id);
    await _writeAll(markers);
  }

  /// Actualiza la etiqueta de un marcador.
  Future<void> updateMarkerLabel(String id, String label) async {
    final markers = await _readAll();
    final index = markers.indexWhere((m) => m.id == id);
    if (index >= 0) {
      markers[index] = markers[index].copyWith(label: label);
      await _writeAll(markers);
    }
  }

  /// Elimina todos los marcadores de un libro.
  Future<void> removeMarkersForBook(String bookId) async {
    final markers = await _readAll()..removeWhere((m) => m.bookId == bookId);
    await _writeAll(markers);
  }
}
