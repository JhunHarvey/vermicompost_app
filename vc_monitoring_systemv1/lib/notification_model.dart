

class NotificationItem {
  final String title;
  final String message;
  final String time;
  bool isUnread;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });
}