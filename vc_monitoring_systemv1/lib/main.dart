import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'notifications.dart';
import 'contacttab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  // ✅ Valve state moved here
  bool _valveOpen = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    _fadeController.forward();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fadeController.reverse().then((_) {
          setState(() {
            _currentIndex = _tabController.index;
          });
          _fadeController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home, size: 30), text: 'Home'),
            Tab(icon: Icon(Icons.notifications, size: 30), text: 'Notifications'),
            Tab(icon: Icon(Icons.contact_page, size: 30), text: 'Contact'),
          ],
        ),
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
    );
  }
}
