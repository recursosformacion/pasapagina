import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class LibraryService {
  static const _key = 'library_books';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<List<Book>> _readAll() async {
    final prefs = await _prefs();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final books = <Book>[];
    for (final e in raw) {
      try {
        books.add(Book.fromJson(jsonDecode(e) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupt entries
      }
    }
    return books;
  }

  Future<void> _writeAll(List<Book> books) async {
    final prefs = await _prefs();
    await prefs.setStringList(_key, books.map((b) => jsonEncode(b.toJson())).toList());
  }

  Future<List<Book>> getAllBooks() => _readAll();

  Future<void> addOrUpdateBook(Book book) async {
    final books = await _readAll();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      books[index] = book;
    } else {
      books.add(book);
    }
    await _writeAll(books);
  }

  Future<void> removeBook(String id) async {
    final books = await _readAll()..removeWhere((b) => b.id == id);
    await _writeAll(books);
  }

  Future<void> updateBookTitle(String id, String title) async {
    final books = await _readAll();
    final index = books.indexWhere((b) => b.id == id);
    if (index >= 0) {
      books[index] = books[index].copyWith(title: title);
      await _writeAll(books);
    }
  }

  Future<void> updatePosition(String id, double position) async {
    final books = await _readAll();
    final index = books.indexWhere((b) => b.id == id);
    if (index >= 0) {
      books[index] = books[index].copyWith(position: position);
      await _writeAll(books);
    }
  }

  Future<void> markRead(String id, {required DateTime time, required double position}) async {
    final books = await _readAll();
    final index = books.indexWhere((b) => b.id == id);
    if (index >= 0) {
      books[index] = books[index].copyWith(lastRead: time, position: position);
      books.sort((a, b) {
        final ar = a.lastRead?.millisecondsSinceEpoch ?? 0;
        final br = b.lastRead?.millisecondsSinceEpoch ?? 0;
        return br.compareTo(ar);
      });
      await _writeAll(books);
    }
  }

  List<Book> sortBooks(List<Book> books, String sortBy) {
    final result = List<Book>.from(books);
    switch (sortBy) {
      case 'title':
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case 'dateAdded':
        result.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case 'lastRead':
        result.sort((a, b) {
          final ar = a.lastRead?.millisecondsSinceEpoch ?? 0;
          final br = b.lastRead?.millisecondsSinceEpoch ?? 0;
          return br.compareTo(ar);
        });
    }
    return result;
  }

  List<Book> searchBooks(List<Book> books, String query) {
    if (query.isEmpty) return books;
    final q = query.toLowerCase();
    return books.where((b) {
      return b.title.toLowerCase().contains(q) || (b.author ?? '').toLowerCase().contains(q);
    }).toList();
  }

  List<Book> getReadingInProgress(List<Book> books) {
    final result = books.where((b) => b.lastRead != null).toList();
    result.sort((a, b) {
      final ar = a.lastRead?.millisecondsSinceEpoch ?? 0;
      final br = b.lastRead?.millisecondsSinceEpoch ?? 0;
      return br.compareTo(ar);
    });
    return result;
  }
}
