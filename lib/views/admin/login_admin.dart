// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/views/admin/pages/admin_mainpage.dart';
import 'package:pin_logy/views/admin/register_admin.dart';
import 'package:toastification/toastification.dart';
import '../../services/auth/admin/admin_auth_provider.dart';
import '../partials/onLoadingBoard.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AdminAuthProvider _authProvider = AdminAuthProvider();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.admin_panel_settings_rounded, size: 25),
            const SizedBox(width: 12),
            Text("Perfil de Administración",
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          actions: [
            CustomThemeSwitcher(
                lightTheme: Themes.lightTheme, darkTheme: Themes.darkTheme)
          ]),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/resource_abstract.png',
                  fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
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
                      Text("Bienvenido",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 24),
                      Text(
                        "En este perfil puedes monitorear las actividades de usuarios y su localización en tiempo real.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
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
          const SizedBox(height: 18),
          TextFormField(
            controller: _passController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                onPressed: () {
                  showPasswordResetBottomSheet(context, _authProvider);
                },
                child: Text("¿Olvidaste tu contraseña?",
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                    textAlign: TextAlign.center),
              ),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Mostrar pantalla de carga
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const LoadingScreen()),
                    );

                    try {
                      final user = await _authProvider.loginAdmin(correo: _mailController.text, password: _passController.text);

                      if (user != null) {
                        // Si el inicio de sesión es exitoso, navegar a la pantalla principal
                        Navigator.of(context)
                            .pop(); // Regresar de la pantalla de carga
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const AdminMainpage()),
                        );
                      } else {
                        // Mostrar mensaje de error y regresar a la pantalla de inicio de sesión
                        Navigator.of(context)
                            .pop(); // Regresar de la pantalla de carga
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          title: const Text("Error al iniciar sesión"),
                          description:
                              const Text("Correo y/o contraseña incorrectos"),
                          alignment: Alignment.topCenter,
                          autoCloseDuration: const Duration(seconds: 8),
                        );
                      }
                    } catch (e) {
                      // Manejar excepciones y mostrar mensaje de error
                      Navigator.of(context)
                          .pop(); // Regresar de la pantalla de carga
                      toastification.show(
                        context: context,
                        type: ToastificationType.error,
                        style: ToastificationStyle.flat,
                        title: const Text("Error al iniciar sesión"),
                        description:
                            const Text("Correo y/o contraseña incorrectos"),
                        alignment: Alignment.topCenter,
                        autoCloseDuration: const Duration(seconds: 8),
                      );
                    }
                  }
                },
                child: const Text("Ingresar"),
              ),
            ],
          ),
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
        const SizedBox(height: 25),
        FilledButton(
          /*onPressed: () async {
            try{
              await _authProvider.signInWithGoogle();
              toastification.show(
                  context: context,
                  type: ToastificationType.info,
                  style: ToastificationStyle.flat,
                  title: const Text("Iniciando sesión con Google"),
                  description: const Text("Por favor, espere..."),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 8)
              );
            }catch (e){
              toastification.show(
                  context: context,
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: const Text("Error de inicio de sesión"),
                  description: const Text("El ususario ya existe con otro método de registro."),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 8)
              );
            }
          },*/
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(EvaIcons.google),
                Text("Iniciar sesión con Google"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showPasswordResetBottomSheet(
      BuildContext context, AdminAuthProvider authProvider) {
    final TextEditingController emailController = TextEditingController();
    final passKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: passKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recuperar Contraseña',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                    "Ingresa el correo electrónico con el que te registraste y enviarte un enlace con el correo de recuperación de contraseña.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obligatorio";
                    } else if (!value.contains('@')) {
                      return "Formato de correo incorrecto";
                    }
                    return null;
                  },
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (passKey.currentState!.validate()) {
                      try {
                        await authProvider
                            .sendPasswordResetEmail(emailController.text);
                        toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            style: ToastificationStyle.flat,
                            title: const Text("Recuperación de contraseña"),
                            description:
                                const Text("Correo enviado satisfactoriamente"),
                            alignment: Alignment.topCenter,
                            autoCloseDuration: const Duration(seconds: 8));
                        Navigator.pop(context);
                      } catch (e) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          title: const Text("Error"),
                          description: const Text(
                              "Se produjo un error al enviar el correo de recuperación"),
                          alignment: Alignment.topCenter,
                          autoCloseDuration: const Duration(seconds: 8),
                        );
                      }
                    }
                  },
                  child: const Text('Enviar'),
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
