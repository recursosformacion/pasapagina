class Book {
  Book({
    required this.id,
    required this.title,
    this.author,
    this.coverBase64,
    this.lastRead,
    this.position = 0.0,
    required this.dateAdded,
  });

  final String id;
  String title;
  final String? author;
  final String? coverBase64;
  final DateTime? lastRead;
  final double position;
  final DateTime dateAdded;

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverBase64,
    DateTime? lastRead,
    double? position,
    DateTime? dateAdded,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverBase64: coverBase64 ?? this.coverBase64,
      lastRead: lastRead ?? this.lastRead,
      position: position ?? this.position,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'coverBase64': coverBase64,
        'lastRead': lastRead?.toIso8601String(),
        'position': position,
        'dateAdded': dateAdded.toIso8601String(),
      };

  static Book fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String?,
        coverBase64: json['coverBase64'] as String?,
        lastRead: json['lastRead'] != null
            ? DateTime.parse(json['lastRead'] as String)
            : null,
        position: (json['position'] as num?)?.toDouble() ?? 0.0,
        dateAdded: DateTime.parse(json['dateAdded'] as String),
      );
}
