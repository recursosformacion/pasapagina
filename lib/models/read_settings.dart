class ReadSettings {
  const ReadSettings({
    this.theme = 'cream',
    this.fontFamily = 'serif',
    this.fontSize = 20.0,
    this.lineHeight = 1.62,
    this.margins = 28.0,
    this.readerMode = 'adaptive',
  });

  final String theme;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final double margins;
  final String readerMode;

  ReadSettings copyWith({
    String? theme,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? margins,
    String? readerMode,
  }) {
    return ReadSettings(
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      margins: margins ?? this.margins,
      readerMode: readerMode ?? this.readerMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'margins': margins,
        'readerMode': readerMode,
      };

  static ReadSettings fromJson(Map<String, dynamic> json) => ReadSettings(
        theme: json['theme'] as String? ?? 'cream',
        fontFamily: json['fontFamily'] as String? ?? 'serif',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.62,
        margins: (json['margins'] as num?)?.toDouble() ?? 28.0,
        readerMode: json['readerMode'] as String? ?? 'adaptive',
      );
}
