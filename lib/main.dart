import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/appointment_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_theme.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB6VCkO_Y--kzZo8vPX4lejmWy46nXOpwU",
          authDomain: "dr-haripada.firebaseapp.com",
          projectId: "dr-haripada",
          storageBucket: "dr-haripada.firebasestorage.app",
          messagingSenderId: "471597065830",
          appId: "1:471597065830:web:e90902e5f6556c577befa7",
          measurementId: "G-5ZX838XJCN",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init: $e');
  }
  runApp(const DrHaripadaApp());
}

class DrHaripadaApp extends StatelessWidget {
  const DrHaripadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'ডা. হরিপদ - সিরিয়াল বুকিং অ্যাপ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
