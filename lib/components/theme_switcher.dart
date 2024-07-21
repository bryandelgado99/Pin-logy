import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

class CustomThemeSwitcher extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const CustomThemeSwitcher({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final currentBrightness = ThemeModelInheritedNotifier.of(context).theme.brightness;

    return ThemeSwitcher(
      clipper: const ThemeSwitcherCircleClipper(),
      builder: (context) {
        return TextButton(
          child: Icon(
            currentBrightness == Brightness.light
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
          onPressed: () {
            final newBrightness = currentBrightness == Brightness.light
                ? Brightness.dark
                : Brightness.light;
        
            ThemeSwitcher.of(context).changeTheme(
              theme: newBrightness == Brightness.light ? lightTheme : darkTheme,
              isReversed: newBrightness == Brightness.light,
            );
          },
        );
      },
    );
  }
}