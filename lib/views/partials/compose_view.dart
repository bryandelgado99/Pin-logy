// ignore_for_file: unused_element, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pin_logy/constants/device_constrains.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/views/admin/login_admin.dart';
import 'package:pin_logy/views/user/login_view.dart';

class ComposeView extends StatefulWidget {
  const ComposeView({super.key});

  @override
  _ComposeViewState createState() => _ComposeViewState();
}

class _ComposeViewState extends State<ComposeView> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    var lightTheme = Themes.lightTheme;
    var darkTheme = Themes.darkTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/resource_abstract.png', // Cambia esto a la ruta de tu imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          DeviceConstraints.isDesktop(context)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset("assets/advice.png", scale: 1.25),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Lo sentimos, esta aplicación es de uso exclusivo para dispositivos móviles",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _buildContainerTop(),
                    ),
                    Expanded(
                      child: _buildContainerOptions(context, screenWidth),
                    ),
                  ],
                ),
          Positioned(
            top: 25,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomThemeSwitcher(
                  lightTheme: lightTheme, darkTheme: darkTheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerTop() {
    return SizedBox.expand(
      child: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 128, 128, 128).withOpacity(0.3),
          ),
          onTopInfo(context),
        ],
      ),
    );
  }

  Widget _buildContainerOptions(BuildContext context, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 89, 103, 179),
      ),
      child: onBottomItems(context),
    );
  }

  Widget onTopInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            'assets/icon.png',
            scale: 2.85,
          ),
          SizedBox(height: 30),
          Text(
            "Pin-logy",
            style: theme.textTheme.displayMedium,
          ),
          SizedBox(height: 8),
          Text(
            "Ubícate en tu mundo",
            style: theme.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget onBottomItems(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Inicia sesión para disfrutar todos los beneficios de la aplicación.",
              style: theme.textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 275, // Ajusta el ancho según sea necesario
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginUserView()));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded),
                      SizedBox(width: 10),
                      Text("Iniciar sesión"),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 35),
            Text(
              "¿Eres administrador?",
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 275, // Ajusta el ancho según sea necesario
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginAdmin()));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.admin_panel_settings_rounded),
                      SizedBox(width: 10),
                      Text("Perfil - Administrador"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
