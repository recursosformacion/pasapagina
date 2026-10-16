
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
    return prefs.getDouble(_key(path)) ?? 0;
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

/// Serializa/deserializa la biblioteca de libros importados.
class LibraryService {
  static const _key = 'library_books';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  /// Guarda la lista de rutas de libros importados.
  Future<void> saveLibrary(List<String> paths) async {
    final prefs = await _prefs();
    await prefs.setStringList(_key, paths.toSet().toList());
  }

  /// Lee las rutas de libros importados.
  Future<List<String>> loadLibrary() async {
    final prefs = await _prefs();
    return prefs.getStringList(_key) ?? <String>[];
  }

  /// Añade un libro a la biblioteca si no está ya presente.
  Future<void> addBook(String path) async {
    final current = await loadLibrary();
    if (!current.contains(path)) {
      current.add(path);
      await saveLibrary(current);
    }
  }
}
