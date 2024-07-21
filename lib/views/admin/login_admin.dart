import 'package:flutter/material.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';

class LoginAdmin extends StatelessWidget {
  const LoginAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    var lightTheme = Themes.lightTheme;
    var darkTheme = Themes.darkTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          CustomThemeSwitcher(lightTheme: lightTheme, darkTheme: darkTheme)
        ],
      ),
      body: const Text("Login Admin"),
    );
  }
}