class NoteItem {
  final int id;
  final String title;
  final String content;
  final String timestamp;

  const NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'timestamp': timestamp,
  };

  NoteItem copyWith({
    int? id,
    String? title,
    String? content,
    String? timestamp,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
