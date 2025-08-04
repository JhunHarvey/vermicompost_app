import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_page.dart';
import 'notifications.dart';
import 'contacttab.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("FCM Background: Starting handler...");
  await Firebase.initializeApp(); // Add options if you have them specific
  print("FCM Background: Firebase initialized.");

  final notificationService = NotificationService();
  await notificationService.initialize();
  print("FCM Background: NotificationService initialized.");

  if (message.notification != null) {
    print("FCM Background: Received notification payload.");
    await notificationService.showNotification(
      title: message.notification?.title ?? 'Alert',
      body: message.notification?.body ?? 'Sensor alert',
    );
    print("FCM Background: Notification shown!");
  } else {
    print("FCM Background: No notification payload found. Message data: ${message.data}");
    // Handle data-only messages if that's what your backend sends
    if (message.data['title'] != null && message.data['body'] != null) {
        await notificationService.showNotification(
            title: message.data['title']!,
            body: message.data['body']!,
        );
        print("FCM Background: Data-only notification shown!");
    }
  }
  print("FCM Background: Handler finished.");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'PT Sans',
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  bool _valveOpen = false;

@override
void initState() {
  super.initState();

  _fadeController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
  _fadeController.forward();

  // 🔔 Initialize FCM and get token
  _setupFCM();
}

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      print("🔑 FCM Token: $token");

      // TODO: Save token to your database here
      // Example if using Firebase Realtime Database:
      /*
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/user123");
      await ref.set({
        "fcmToken": token,
      });
      */

      // Optionally listen to token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("🔁 Token refreshed: $newToken");
        // Update your database if needed
      });
    } else {
      print("❌ FCM permission not granted");
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _getCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          valveOpen: _valveOpen,
          onValveToggle: (value) {
            setState(() {
              _valveOpen = value;
            });
          },
        );
      case 1:
        return const notifications();
      case 2:
        return const contacttab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'VermiApp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _getCurrentTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            _fadeController.reverse().then((_) {
              setState(() {
                _currentIndex = index;
              });
              _fadeController.forward();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 30),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page, size: 30),
            label: 'Contact',
          ),
        ],
        selectedLabelStyle: TextStyle(color: Colors.black),      // <-- Black text for selected
        unselectedLabelStyle: TextStyle(color: Colors.black),    // <-- Black text for unselected
        backgroundColor: Colors.green[400],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
