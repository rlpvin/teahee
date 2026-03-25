class TeaCup {
  final String id;
  final String title;
  final String content;
  final String date;
  final String type; // Tall, Grande, Venti
  final List<String> mediaPaths;

  TeaCup({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.mediaPaths = const [],
  });

  factory TeaCup.fromJson(Map<String, dynamic> json) {
    return TeaCup(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      type: json['type'] as String,
      mediaPaths: (json['mediaPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'type': type,
      'mediaPaths': mediaPaths,
    };
  }

  String get formattedTitle => _applyTypography(title);
  String get formattedContent => _applyTypography(content);

  String _applyTypography(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // 1. Convert -- to — (em-dash)
    result = result.replaceAll('--', '—');

    // 2. Convert " to smart quotes
    // Replace opening quotes (start of line or after whitespace/newline)
    result = result.replaceAllMapped(
      RegExp(r'(^|[\s\n])"'),
      (match) => '${match.group(1)}“',
    );
    // Replace remaining quotes with closing quotes
    result = result.replaceAll('"', '”');

    return result;
  }
}
