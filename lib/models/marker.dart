class Marker {
  const Marker({
    required this.id,
    required this.bookId,
    required this.position,
    this.label,
    required this.createdAt,
    this.textFragment,
  });

  final String id;
  final String bookId;
  final double position;
  final String? label;
  final DateTime createdAt;
  final String? textFragment;

  Marker copyWith({
    String? id,
    String? bookId,
    double? position,
    String? label,
    DateTime? createdAt,
    String? textFragment,
  }) {
    return Marker(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      position: position ?? this.position,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      textFragment: textFragment ?? this.textFragment,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'position': position,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'textFragment': textFragment,
      };

  static Marker fromJson(Map<String, dynamic> json) => Marker(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        position: (json['position'] as num?)?.toDouble() ?? 0.0,
        label: json['label'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        textFragment: json['textFragment'] as String?,
      );
}
