import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class notifications extends StatefulWidget {
  const notifications({super.key});

  @override
  NotificationTabState createState() => NotificationTabState();
}

class NotificationTabState extends State<notifications> {
  bool showUnreadOnly = true;
  late StreamSubscription<NotificationItem> _notificationSubscription;
  final NotificationService _notificationService = NotificationService();
  List<NotificationItem> _notifications = []; // Start with empty list

  @override
  void initState() {
    super.initState();
    // Initialize with existing notifications from service
    _notifications = List<NotificationItem>.from(_notificationService.notificationHistory);

    // Subscribe to new notifications
    _notificationSubscription = _notificationService.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          // Always sync with the latest history
          _notifications = List<NotificationItem>.from(_notificationService.notificationHistory);
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  List<NotificationItem> get notifications => _notifications;

  List<NotificationItem> get filteredNotifications {
    return showUnreadOnly 
        ? _notifications.where((notif) => notif.isUnread).toList()
        : _notifications;
  }

  void _showMarkAllAsReadDialog() {
    showDialog (
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Mark all as Read'),
          content: const Text('Are you sure to mark all as read?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in notifications) {
                    if (notification.isUnread) {
                      NotificationService().markAsRead(notification);
                      notification.isUnread = false;
                    }
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All notifications marked as read'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Delete All Notifications'),
          content: const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await NotificationService().clearAllNotifications();
                setState(() {
                  _notifications.clear(); // <-- update this line
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All notifications deleted'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9), // Colors.green[50] as const
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000), // Colors.grey.withAlpha(25) as const
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Can't use const for dynamic text
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        // Can't use const for Border.all with dynamic color
                      ),
                      // Can't use const for dynamic text
                      child: Text(
                        '${notifications.length} total',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Toggle buttons
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    // Can't use const for Border.all with dynamic color
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showUnreadOnly = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: showUnreadOnly ? Colors.green[400] : Colors.transparent,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                            boxShadow: showUnreadOnly
                                ? const [
                                    BoxShadow(
                                      color: Color(0x4D388E3C), // Colors.green.withAlpha(77)
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Text(
                            "Unread",
                            style: TextStyle(
                              color: showUnreadOnly ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showUnreadOnly = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: !showUnreadOnly ? Colors.green[400] : Colors.transparent,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                            boxShadow: !showUnreadOnly
                                ? const [
                                    BoxShadow(
                                      color: Color(0x4D388E3C),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Text(
                            "All",
                            style: TextStyle(
                              color: !showUnreadOnly ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Notification list
          Expanded(
            child: Container(
              color: Colors.green[50],
              child: filteredNotifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return NotificationCard(
                        notification: notification,
                        showUnreadOnly: showUnreadOnly,
                        onMarkAsRead: () {
                          _notificationService.markAsRead(notification);
                          setState(() {
                            notification.isUnread = false;
                          });
                        },
                        onDelete: () {
                          _notificationService.deleteNotification(notification);
                          setState(() {
                            notifications.remove(notification);
                          });
                        },
                      );
                    },
                  ),
            ),
          ),
          // Action buttons
          if (filteredNotifications.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showUnreadOnly)
                    ElevatedButton.icon(
                      onPressed: () {
                        _showMarkAllAsReadDialog();
                      },
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Mark all as Read'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        elevation: 2,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteAllDialog();
                      },
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('Delete All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        elevation: 2,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool showUnreadOnly;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.showUnreadOnly,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        // Can't use const for Border.all with dynamic color
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (notification.isUnread) {
              NotificationService().markAsRead(notification); // Add this line
              onMarkAsRead(); // Keep this line
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.time,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    notification.message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (notification.isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: const Text(
                          'Unread',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Action buttons
                    if (showUnreadOnly && notification.isUnread)
                      Material(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          onTap: () {
                            NotificationService().markAsRead(notification);
                            onMarkAsRead();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    else if (!showUnreadOnly)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (notification.isUnread)
                            Material(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                onTap: () {
                                  NotificationService().markAsRead(notification);
                                  onMarkAsRead();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Material(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              onTap: onDelete,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
