import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/views/partials/splash.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
    } catch (e) {
      print('Firebase initialization error: $e');
    }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
    initTheme: Themes.lightTheme,
    builder: (p0, theme) => MaterialApp(
      title: 'Pin-logy',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen()
    ),
  );
  }
}
