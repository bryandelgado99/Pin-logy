// ignore_for_file: no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:toastification/toastification.dart';

class LoginUserView extends StatefulWidget {
  const LoginUserView({super.key});

  @override
  _LoginUserViewState createState() => _LoginUserViewState();
}

class _LoginUserViewState extends State<LoginUserView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var lightTheme = Themes.lightTheme;
    var darkTheme = Themes.darkTheme;
    var theme = Theme.of(context);

    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        actions: [
          CustomThemeSwitcher(lightTheme: lightTheme, darkTheme: darkTheme)
        ],
      ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: bottomInsets > 0
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomInsets),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxHeight: bottomInsets > 0
                        ? constraints.maxHeight + bottomInsets
                        : constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Iniciar sesión",
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Ingresa con tu correo electrónico y contraseña registrados, o, haz uso de tus redes sociales favoritas.",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          formSignIn(context),
                          const SizedBox(
                            height: 50,
                          ),
                          socialButtons()
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget formSignIn(BuildContext context) {
    var theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _mailController,
            keyboardType: TextInputType.emailAddress,
            showCursor: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Correo Electrónico'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (!value.contains('@')) {
                return "Formato de correo electrónico incorrecto";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 18,
          ),
          TextFormField(
            controller: _passController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                  onPressed: () {},
                  child: Text("¿Olvidaste tu contraseña?",
                      style: theme.textTheme.labelMedium,
                      textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.info,
                    style: ToastificationStyle.flatColored,
                    title: const Text("Iniciando sesión..."),
                    description: const Text("Por favor, espere"),
                    alignment: Alignment.topRight,
                    autoCloseDuration: const Duration(
                      milliseconds: 5000,
                    ),
                    animationBuilder: (
                      context,
                      animation,
                      alignment,
                      child,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    icon: CircularProgressIndicator(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: lowModeShadow,
                    showProgressBar: false,
                    closeOnClick: false,
                    pauseOnHover: false,
                  );
                } 
              },
              child: const Text("Ingresar"))
        ],
      ),
    );
  }

  Widget socialButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(EvaIcons.google),
              Text("Iniciar sesión con Google")
            ],
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Bootstrap.microsoft),
              Text("Iniciar sesión con Microsoft")
            ],
          ),
        ),
      ],
    );
  }
}
