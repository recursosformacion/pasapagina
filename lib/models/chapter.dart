class Chapter {
  const Chapter({
    required this.title,
    required this.startIndex,
    this.endIndex,
    this.pageIndex,
  });

  final String title;
  final int startIndex;
  final int? endIndex;
  final int? pageIndex;

  Map<String, dynamic> toJson() => {
        'title': title,
        'startIndex': startIndex,
        'endIndex': endIndex,
        'pageIndex': pageIndex,
      };

  static Chapter fromJson(Map<String, dynamic> json) => Chapter(
        title: json['title'] as String,
        startIndex: json['startIndex'] as int,
        endIndex: json['endIndex'] as int?,
        pageIndex: json['pageIndex'] as int?,
      );
}
