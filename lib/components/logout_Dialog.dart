import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:pin_logy/services/auth/admin/admin_auth_provider.dart';
import 'package:pin_logy/views/partials/compose_view.dart';

class LogoutDialog {
  static Future<bool> show(
      BuildContext context, AdminAuthProvider authProvider) async {
    // Retorna un Future<bool> asegurando que el valor sea bool (true o false) y no null
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Evita que el diálogo se cierre al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Retorna false si se cancela
              },
            ),
            TextButton(
              child: const Text('Cerrar Sesión'),
              onPressed: () async {
                await _signOut(context,
                    authProvider); // Retorna true si se confirma el cierre de sesión
              },
            ),
          ],
        );
      },
    );
    // Asegúrate de que result no sea null, y retorna false si lo es
    return result ?? false;
  }

  static Future<void> _signOut(
      BuildContext context, AdminAuthProvider authProvider) async {
    try {
      await authProvider.signOut();
      // Usa un `Future.delayed` para asegurar que la navegación se maneje después de cerrar sesión
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const ComposeView()), // Reemplaza LoginAdmin con la pantalla de inicio de sesión
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error al cerrar sesión: $e');
      }
      // Mostrar mensaje de error o notificación si es necesario
    }
  }
}
