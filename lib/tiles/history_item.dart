class HistoryItem {
  final int id;
  final int bookId;
  final int chapter;
  final int verse;
  final String? bookName;
  final String content;
  final int timestamp;
  final String action_type;

  HistoryItem({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    this.bookName,
    required this.content,
    required this.timestamp,
    required this.action_type,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "bookId": bookId,
    "chapter": chapter,
    "verse": verse,
    "bookName": bookName,
    "content": content,
    "timestamp": timestamp,
    "action_type": action_type,
  };

  factory HistoryItem.fromMap(Map<String, dynamic> m) => HistoryItem(
    id: m["id"],
    bookId: m["bookId"],
    chapter: m["chapter"],
    verse: m["verse"],
    bookName: m["bookName"],
    content: m["content"],
    timestamp: m["timestamp"],
    action_type: m["action_type"],
  );
}
