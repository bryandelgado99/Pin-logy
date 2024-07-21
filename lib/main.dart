import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/views/partials/compose_view.dart';

void main() => runApp(const MyApp());

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
      home: const ComposeView()
    ),
  );
  }
}
