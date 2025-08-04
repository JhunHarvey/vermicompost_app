import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    Duration cooldown = const Duration(seconds: 60),
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
    required double waterLevel,
    required double vermiteaLevel,
  }) async {
    final moistureKey = 'moisture_${moisture.toStringAsFixed(1)}';
    final tempKey = 'temp_${temperature.toStringAsFixed(1)}';
    final waterKey = 'water_${waterLevel.toStringAsFixed(1)}';
    final vermiteaKey = 'vermitea_${vermiteaLevel.toStringAsFixed(1)}';

    // Moisture alerts
    if (moisture < 60) {
      await _throttledNotification(
        key: 'low_$moistureKey',
        title: "Critical Moisture Alert",
        body: "Moisture is low at ${moisture.toStringAsFixed(1)}%",
      );
    } else if (moisture > 80) {
      await _throttledNotification(
        key: 'high_$moistureKey',
        title: "High Moisture Alert",
        body: "Moisture is high at ${moisture.toStringAsFixed(1)}%",
      );
    }

    // Temperature alerts
    if (temperature < 15) {
      await _throttledNotification(
        key: 'low_$tempKey',
        title: "Low Temperature Alert",
        body: "Temperature is low at ${temperature.toStringAsFixed(1)}°C",
      );
    } else if (temperature > 38) {
      await _throttledNotification(
        key: 'high_$tempKey',
        title: "High Temperature Alert",
        body: "Temperature is high at ${temperature.toStringAsFixed(1)}°C",
      );
    }

    // Water level alerts
    if (waterLevel < 20) {
      await _throttledNotification(
        key: 'low_$waterKey',
        title: "Low Water Level",
        body: "Water is critically low at ${waterLevel.toStringAsFixed(1)} cm",
      );
    } else if (waterLevel > 90) {
      await _throttledNotification(
        key: 'high_$waterKey',
        title: "High Water Level",
        body: "Water level is high at ${waterLevel.toStringAsFixed(1)} cm",
      );
    }

    // Vermitea level alerts
    if (vermiteaLevel < 20) {
      await _throttledNotification(
        key: 'low_$vermiteaKey',
        title: "Low Vermitea Level",
        body: "Vermitea is low at ${vermiteaLevel.toStringAsFixed(1)} cm",
      );
    } else if (vermiteaLevel > 90) {
      await _throttledNotification(
        key: 'high_$vermiteaKey',
        title: "High Vermitea Level",
        body: "Vermitea is high at ${vermiteaLevel.toStringAsFixed(1)} cm",
      );
    }
  }

  // ================= UTILITY METHODS =================
  Future<void> clearAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _notificationHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    _notificationStreamController.add(NotificationItem(
      title: '',
      message: '',
      time: '',
      isUnread: false,
    ));
  }

  String _formatTime(DateTime time) {
    return DateFormat('MMM dd, HH:mm').format(time);
  }
}