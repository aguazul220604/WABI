import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:wabi/login.dart';

// 👇 Instancia global de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotificaciones(); // ✅ Ahora funciona porque main es async
  runApp(const MyApp());
}

Future<void> _initNotificaciones() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  final initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFF5271FF)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo_blanco.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Wabi',
                style: TextStyle(
                  fontFamily: "Pacifico",
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
