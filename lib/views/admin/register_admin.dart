// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class RegisterAdmin extends StatefulWidget {
  const RegisterAdmin({super.key});

  @override
  State<RegisterAdmin> createState() => _RegisterAdminState();
}

class _RegisterAdminState extends State<RegisterAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _repeatpassController = TextEditingController();

  bool _obscureTextPass = true;
  bool _obscureTextRepeatPass = true;

  final database = FirebaseFirestore.instance;

  Future<void> onregisterAdmin(BuildContext context) async {
    try {
      // Verificar si el usuario ya existe
      var existingUserQuery = await database
          .collection('Admins')
          .where('email', isEqualTo: _mailController.text)
          .get();

      if (existingUserQuery.docs.isNotEmpty) {
        // Usuario ya existe, mostrar toast de error
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Error"),
          description: const Text("El usuario ya existe."),
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

      // Mostrar el toast de "Registrándote como administrador"
      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text("Registrándote como administrador"),
        description: const Text("Por favor, espere..."),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(milliseconds: 400),
        animationBuilder: (context, animation, alignment, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        icon: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: lowModeShadow,
        showProgressBar: false,
        closeOnClick: false,
        pauseOnHover: false,
      );

      // Encriptar la contraseña
      var bytes =
          utf8.encode(_passController.text); // datos que vamos a hashear
      var digest = sha256.convert(bytes);

      // Guardar el hash de la contraseña en la base de datos
      await database.collection('Admins').doc().set({
        "nombre": _nameController.text,
        "apellido": _lastnameController.text,
        "email": _mailController.text,
        "password": digest.toString() // hash de la contraseña
      });

      // Mostrar toast de registro exitoso
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text("Registro exitoso"),
        description: const Text("Te has registrado correctamente."),
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
    } catch (e) {
      // Manejar errores y mostrar un toast de error
      if (kDebugMode) {
        print(e);
      }
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: const Text("Error"),
        description: const Text("Ocurrió un error durante el registro."),
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
            "Registro",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
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
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
          
              // Llamanado al método de registro:
                await onregisterAdmin(context);
              }
            },
            child: const Text("Regístrate"),
          ),
        ],
      ),
    );
  }
}
