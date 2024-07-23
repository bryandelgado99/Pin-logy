// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/views/admin/register_admin.dart';
import 'package:toastification/toastification.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final database = FirebaseFirestore.instance;
  bool _obscureText = true;

  Future<void> onloginAdmin() async {
    try {
      // Obtener los datos del usuario con el correo ingresado
      var userQuery = await database
          .collection('Admins')
          .where('email', isEqualTo: _mailController.text)
          .get();

      if (userQuery.docs.isEmpty) {
        // Usuario no encontrado, mostrar toast de error
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Error de inicio de sesión"),
          description: const Text("Correo o contraseña incorrectos."),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(milliseconds: 5000),
          animationBuilder: (context, animation, alignment, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: lowModeShadow,
        );
        return;
      }

      // Obtener la contraseña encriptada almacenada
      var userDoc = userQuery.docs.first;
      var storedPassword = userDoc['password'];

      // Encriptar la contraseña ingresada
      var bytes = utf8.encode(_passController.text);
      var digest = sha256.convert(bytes);

      // Comparar la contraseña ingresada (encriptada) con la almacenada
      if (digest.toString() == storedPassword) {
        // Mostrar indicador de progreso y opacar la pantalla
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return Stack(
              children: [
                const Center(
                  child: CircularProgressIndicator(),
                ),
                Container(
                  color: Colors.black54, // Opacar la pantalla
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          },
        );

      // Esperar 500 milisegundos
      await Future.delayed(const Duration(milliseconds: 500));

      // Cerrar el indicador de progreso
      Navigator.of(context).pop();

      // Mostrar alert dialog de éxito
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sesión iniciada"),
            content: const Text("Has iniciado sesión correctamente."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      } else {
        // Contraseña incorrecta, mostrar toast de error
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Error de inicio de sesión"),
          description: const Text("Correo o contraseña incorrectos."),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(milliseconds: 5000),
          animationBuilder: (context, animation, alignment, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: lowModeShadow,
        );
      }
    } catch (e) {
      // Manejar errores y mostrar un toast de error
      print(e);
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: const Text("Error"),
        description:
            const Text("Ocurrió un error durante el inicio de sesión."),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(milliseconds: 5000),
        animationBuilder: (context, animation, alignment, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: lowModeShadow,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var lightTheme = Themes.lightTheme;
    var darkTheme = Themes.darkTheme;
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 25,
            ),
            const SizedBox(width: 12),
            Text(
              "Perfil de Administración",
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          // Asegúrate de implementar CustomThemeSwitcher en tu código.
          CustomThemeSwitcher(lightTheme: lightTheme, darkTheme: darkTheme)
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bienvenido",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "En este perfil puedes monitorear las actividades de usuarios y su localización en tiempo real.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      formSignIn(context),
                      const SizedBox(height: 40),
                      socialButtons(),
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
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const RegisterAdmin(),
                      );
                    },
                    child: Text("¿Eres nuevo? Regístrate",
                        style: theme.textTheme.labelMedium,
                        textAlign: TextAlign.center)),
                FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await onloginAdmin();
                      }
                    },
                    child: const Text("Ingresar"))
              ])
        ],
      ),
    );
  }

  Widget socialButtons() {
    var theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "También puedes hacer uso de tus redes sociales favoritas.",
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 25,
        ),
        FilledButton(
          onPressed: () async {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(EvaIcons.google),
                Text("Iniciar sesión con Google")
              ],
            ),
          ),
        )
      ],
    );
  }
}
