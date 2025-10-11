import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;


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

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, DateTime> _lastNotified = {};
  final List<NotificationItem> _notificationHistory = [];
  static const int _maxNotifications = 200; // Maximum notifications to store

  final _notificationStreamController = StreamController<NotificationItem>.broadcast();
  Stream<NotificationItem> get notificationStream => _notificationStreamController.stream;

  List<NotificationItem> get notificationHistory => _notificationHistory;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
    await _loadNotifications();
  }

  // ================= PERSISTENCE METHODS =================
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notificationHistory.map((n) => jsonEncode({
      'title': n.title,
      'message': n.message,
      'time': n.time,  // Already formatted as string
      'isUnread': n.isUnread,
    })).toList();
    await prefs.setStringList('notifications', jsonList);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('notifications') ?? [];
    
    _notificationHistory.clear();
    _notificationHistory.addAll(jsonList.map((json) {
      final map = jsonDecode(json);
      return NotificationItem(
        title: map['title'],
        message: map['message'],
        time: map['time'] ?? _formatTime(DateTime.now()),
        isUnread: map['isUnread'] ?? true,
      );
    }).toList());
    
    // Notify UI about loaded notifications
    for (final notification in _notificationHistory) {
      _notificationStreamController.add(notification);
    }
  }

  // ================= NOTIFICATION MANAGEMENT =================
  Future<void> markAsRead(NotificationItem notification) async {
    notification.isUnread = false;
    await _saveNotifications();
    _notificationStreamController.add(notification);
  }

  Future<void> _throttledNotification({
    required String key,
    required String title,
    required String body,
    Duration cooldown = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    final lastTime = _lastNotified[key];

    if (lastTime == null || now.difference(lastTime) > cooldown) {
      await showNotification(title: title, body: body);
      _lastNotified[key] = now;
      
      final notificationItem = NotificationItem(
        title: title,
        message: body,
        time: _formatTime(now),
        isUnread: true,
      );
      
      // Add new notification and enforce maximum limit
      _notificationHistory.insert(0, notificationItem);
      if (_notificationHistory.length > _maxNotifications) {
        _notificationHistory.removeLast();
      }
      
      _notificationStreamController.add(notificationItem);
      await _saveNotifications();
      
      // Clean up old throttling records
      if (_lastNotified.length > 50) {
        _lastNotified.removeWhere((_, timestamp) => 
            now.difference(timestamp) > Duration(minutes: 30));
      }
    }
  }

  // ================= NOTIFICATION DISPLAY =================
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'sensor_alerts_channel',
      'Sensor Alerts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // ================= SENSOR CHECKING =================
  Future<void> checkSensorValuesAndNotify({
    required double moisture,
    required double temperature,
    required String waterLevel, // <-- Change to String
    required String vermiwashLevel,
  }) async {
    // Moisture alerts
    if (moisture < 42) {
      await _throttledNotification(
        key: 'low_moisture',
        title: "Critical Moisture Alert",
        body: "Moisture is low at ${moisture.toStringAsFixed(1)}%",
        cooldown: Duration(seconds: 15),
      );
    } else if (moisture > 60) {
      await _throttledNotification(
        key: 'high_moisture',
        title: "High Moisture Alert",
        body: "Moisture is high at ${moisture.toStringAsFixed(1)}%",
      );
    }
    
        // Temperature alerts
    if (temperature < 15) {
      await _throttledNotification(
        key: 'low_temperature',
        title: "Low Temperature Alert",
        body: "Temperature is low at ${temperature.toStringAsFixed(1)}°C",
      );
    } else if (temperature > 35) {
      await _throttledNotification(
        key: 'high_temperature',
        title: "High Temperature Alert",
        body: "Temperature is high at ${temperature.toStringAsFixed(1)}°C please cool or put shade to the compost bin",
      );
    }

    // Water level alerts (now string-based)
    if (waterLevel.toUpperCase() == 'LOW') {
      await _throttledNotification(
        key: 'low_water_level',
        title: "Low Water Level",
        body: "Water level is LOW. Please refill.",
        cooldown: Duration(seconds: 10), // Reduce cooldown
      );
    }

    // Vermiwash level alerts (only HIGH from Firebase)
    if (vermiwashLevel.toUpperCase() == 'HIGH') {
      await _throttledNotification(
        key: 'high_vermiwash_level',
        title: "High Vermiwash Level",
        body: "Vermiwash storage is almost full.",
      );
    }
  }

  // ================= UTILITY METHODS =================
  Future<void> clearAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _notificationHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    // Remove this line:
    // _notificationStreamController.add(NotificationItem(isUnread: false));
    // Instead, you can notify listeners that the list is empty if needed:
    // _notificationStreamController.addStream(Stream.empty());
  }

  String _formatTime(DateTime time) {
    return DateFormat('MMM dd, HH:mm').format(time);
  }
}