class NotificationLogItem {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;

  NotificationLogItem({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
  });
}
