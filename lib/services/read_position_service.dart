
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persiste la posición de lectura (desplazamiento en píxeles) de cada libro,
/// indexada por la ruta del archivo.
class ReadPositionService {
  static const _keyPrefix = 'read_position_';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  String _key(String path) =>
      '$_keyPrefix${base64Url.encode(utf8.encode(path)).replaceAll('=', '')}';

  String _legacyKey(String path) => '$_keyPrefix${Uri.file(path).pathSegments.last}';

  /// Guarda el desplazamiento de lectura para [path].
  Future<void> save(String path, double offset) async {
    final prefs = await _prefs();
    await prefs.setDouble(_key(path), offset);
  }

  /// Lee el desplazamiento guardado para [path]. Devuelve 0 si no hay registro.
  Future<double> load(String path) async {
    final prefs = await _prefs();
    final key = _key(path);
    final saved = prefs.getDouble(key);
    if (saved != null) return saved;

    // Migrate the previous basename-only key without losing existing progress.
    try {
      final legacy = prefs.getDouble(_legacyKey(path));
      if (legacy != null) {
        await prefs.setDouble(key, legacy);
        return legacy;
      }
    } catch (_) {
      // Ignore legacy values stored with an unexpected type.
    }
    return 0;
  }

  /// Elimina la posición guardada para [path].
  Future<void> remove(String path) async {
    final prefs = await _prefs();
    await prefs.remove(_key(path));
  }

  /// Limpia todas las posiciones guardadas (útil para tests / reset).
  Future<void> clearAll() async {
    final prefs = await _prefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

