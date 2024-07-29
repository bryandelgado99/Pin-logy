// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../services/auth/admin/admin_auth_provider.dart';

class RegisterAdmin extends StatefulWidget {
  const RegisterAdmin({super.key});

  @override
  _RegisterAdminState createState() => _RegisterAdminState();
}

class _RegisterAdminState extends State<RegisterAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _repeatpassController = TextEditingController();
  final AdminAuthProvider _adminAuthProvider = AdminAuthProvider();

  bool _obscureTextPass = true;
  bool _obscureTextRepeatPass = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Registro de Administrador",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 25),
          Text(
            "Llena el siguiente formulario para formar parte del equipo de Pin-logy y utilizar nuestros servicios.",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 25),
          onRegisterForm(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget onRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nombre
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  showCursor: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obligatorio";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Apellido
              Expanded(
                child: TextFormField(
                  controller: _lastnameController,
                  keyboardType: TextInputType.text,
                  showCursor: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Apellido',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obligatorio";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Correo Electrónico
          TextFormField(
            controller: _mailController,
            keyboardType: TextInputType.emailAddress,
            showCursor: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Correo Electrónico',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return "Formato de correo electrónico incorrecto";
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          // Contraseña
          TextFormField(
            controller: _passController,
            obscureText: _obscureTextPass,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureTextPass ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureTextPass = !_obscureTextPass;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (value.length < 6) {
                return "La contraseña debe tener al menos 6 caracteres";
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          // Repetir Contraseña
          TextFormField(
            controller: _repeatpassController,
            obscureText: _obscureTextRepeatPass,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Repite tu contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureTextRepeatPass
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureTextRepeatPass = !_obscureTextRepeatPass;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (value != _passController.text) {
                return "Las contraseñas no coinciden";
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await _adminAuthProvider.registerAdmin(
                      nombre: _nameController.text,
                      apellido: _lastnameController.text,
                      correo: _mailController.text,
                      password: _passController.text,
                      rol: 'Administrador',
                    );

                    // Notification de registro exitoso
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      style: ToastificationStyle.flat,
                      title: const Text("Administrador registrado"),
                      description: const Text("Puedes iniciar sesión"),
                      alignment: Alignment.topCenter,
                      autoCloseDuration: const Duration(seconds: 8),
                    );
                  } catch (e) {
                    // Notificación de registro fallido
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text("Error al registrar administrador"),
                      description:
                          const Text("El correo ya se encuentra en uso."),
                      alignment: Alignment.topCenter,
                      autoCloseDuration: const Duration(seconds: 8),
                    );
                  }
                }
              },
              child: const Text("Regístrate"),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
