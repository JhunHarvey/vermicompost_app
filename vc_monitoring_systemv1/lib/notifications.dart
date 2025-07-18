import 'package:flutter/material.dart';

class notifications extends StatefulWidget {
  const notifications({super.key});

  @override
  NotificationTabState createState() => NotificationTabState();
}

class NotificationTabState extends State<notifications> {
  bool showUnreadOnly = true;

  // Make notifications static so it persists across widget rebuilds/tabs
  static final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Low Moisture Alert",
      message: "Alert: Moisture Level is below 60% - Compost is too dry",
      time: "now",
      isUnread: true,
    ),
    NotificationItem(
      title: "Low Water Tank Level",
      message: "Alert: Water Tank Level is 20% - Refill the Tank",
      time: "1 hour ago",
      isUnread: true,
    ),
    NotificationItem(
      title: "Low Water Tank Level",
      message: "Alert: Water Tank Level is 20% - Refill the Tank",
      time: "10 hours ago",
      isUnread: false,
    ),
    NotificationItem(
      title: "Vermitea Level Alert",
      message: "Alert: Vermitea Level is 95% - Risk of overflow. Drain vermitea now.",
      time: "1 day ago",
      isUnread: false,
    ),
    NotificationItem(
      title: "Vermitea Level Alert",
      message: "Alert: Vermitea Level is 70% - Plan to use or store vermitea within 24 hours.",
      time: "2 days ago",
      isUnread: false,
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  List<NotificationItem> get filteredNotifications {
    if (showUnreadOnly) {
      return notifications.where((notif) => notif.isUnread).toList();
    }
    return notifications;
  }

  void _showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Mark all as Read'),
          content: Text('Are you sure to mark all as read?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in notifications) {
                    notification.isUnread = false;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All notifications marked as read'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Yes'),
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
          title: Text('Delete All Notifications'),
          content: Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All notifications deleted'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Yes'),
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
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
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
                  children: [
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
                        Text(
                          '${notifications.where((n) => n.isUnread).length} unread',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        '${notifications.length} total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Toggle buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!),
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
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: showUnreadOnly ? Colors.green[400] : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: showUnreadOnly
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
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
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: !showUnreadOnly ? Colors.green[400] : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: !showUnreadOnly
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return NotificationCard(
                        notification: notification,
                        showUnreadOnly: showUnreadOnly,
                        onMarkAsRead: () {
                          setState(() {
                            notification.isUnread = false;
                          });
                        },
                        onDelete: () {
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showUnreadOnly)
                    ElevatedButton.icon(
                      onPressed: () {
                        _showMarkAllAsReadDialog();
                      },
                      icon: Icon(Icons.done_all, size: 18),
                      label: Text('Mark all as Read'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteAllDialog();
                      },
                      icon: Icon(Icons.delete_sweep, size: 18),
                      label: Text('Delete All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isUnread ? Colors.green[200]! : Colors.grey[200]!,
          width: notification.isUnread ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              onMarkAsRead();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.green[600],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
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
                          SizedBox(height: 2),
                          Text(
                            notification.time,
                            style: TextStyle(
                              color: Colors.grey[500],
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
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    if (notification.isUnread)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Unread',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Spacer(),
                    // Action buttons
                    if (showUnreadOnly && notification.isUnread)
                      Material(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onMarkAsRead,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green[600],
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
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: onMarkAsRead,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 8),
                          Material(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: onDelete,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[600],
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
