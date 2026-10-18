
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste la posición de lectura (desplazamiento en píxeles) de cada libro,
/// indexada por la ruta del archivo.
class ReadPositionService {
  static const _keyPrefix = 'read_position_';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  String _key(String path) => '$_keyPrefix${Uri.file(path).pathSegments.last}';

  /// Guarda el desplazamiento de lectura para [path].
  Future<void> save(String path, double offset) async {
    final prefs = await _prefs();
    await prefs.setDouble(_key(path), offset);
  }

  /// Lee el desplazamiento guardado para [path]. Devuelve 0 si no hay registro.
  Future<double> load(String path) async {
    final prefs = await _prefs();
    try {
      return prefs.getDouble(_key(path)) ?? 0;
    } catch (_) {
      return 0;
    }
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

