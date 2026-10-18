import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/read_settings.dart';

class ReadSettingsService {
  static const _defaultKey = 'read_settings_default';
  static const _prefix = 'read_settings_';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  String _key(String? bookId) => bookId == null ? _defaultKey : '$_prefix$bookId';

  Future<ReadSettings> loadSettings([String? bookId]) async {
    final prefs = await _prefs();
    final raw = prefs.getString(_key(bookId));
    if (raw == null) return const ReadSettings();
    try {
      return ReadSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReadSettings();
    }
  }

  Future<void> saveSettings(ReadSettings settings, [String? bookId]) async {
    final prefs = await _prefs();
    await prefs.setString(_key(bookId), jsonEncode(settings.toJson()));
  }

  Future<void> resetSettings([String? bookId]) async {
    final prefs = await _prefs();
    await prefs.remove(_key(bookId));
  }
}
