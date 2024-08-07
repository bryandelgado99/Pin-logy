import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para obtener el adminId del administrador en sesión
  Future<String?> getAdminId() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      // Buscar el documento del administrador en Firestore usando el UID del administrador
      DocumentSnapshot adminDoc =
      await _firestore.collection('Admins').doc(currentUser.uid).get();

      if (adminDoc.exists) {
        return adminDoc.id; // Devuelve el ID del documento, que corresponde al adminId
      } else {
        return null; // El documento no existe
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener adminId: $e');
      }
      return null;
    }
  }

  // Función para generar una contraseña aleatoria
  String _generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  Future<void> _sendEmail(String toEmail, String password) async {
    final Email email = Email(
      body:
      'Hola Usuario/a,\n\nTu cuenta ha sido creada con éxito. Aquí están tus credenciales:\n\n'
          'Correo electrónico: $toEmail\n'
          'Contraseña: $password\n\n'
          'Por favor, cambia tu contraseña después de iniciar sesión.',
      subject: 'Credenciales de acceso Pin-logy | Usuario',
      recipients: [toEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar el correo: $e');
      }
      // Manejo adicional del error o notificación al usuario
    }
  }

  // Función para registrar al usuario
  Future<void> registerUser({
    required String name,
    required String lastName,
    required String email,
    required String adminId,
  }) async {
    // Generar una contraseña aleatoria de 8 caracteres
    String password = _generateRandomPassword();

    try {
      // Crear el usuario en Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Almacenar los datos del usuario en Firestore
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'name': name,
        'lastName': lastName,
        'email': email,
        'role': 'user',
        'admin_id': adminId, // Aquí almacenamos el adminId
        'created_at': FieldValue.serverTimestamp(),
      });

      // Enviar correo electrónico al usuario con la contraseña
      await _sendEmail(email, password);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  // Función para iniciar sesión con correo y contraseña
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Guardar los datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_email', email);
      await prefs.setString('admin_password', password);

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error al iniciar sesión: $e');
      }
      rethrow;
    }
  }

  // Función para cerrar sesión con correo
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Limpiar los datos de SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_email');
      await prefs.remove('admin_password');

      if (kDebugMode) {
        print('Usuario cerrado sesión correctamente.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cerrar sesión: $e');
      }
      rethrow;
    }
  }

  // Función para obtener el administrador autenticado desde SharedPreferences
  Future<User?> getPersistedAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('admin_email');
    String? password = prefs.getString('admin_password');

    if (email != null && password != null) {
      return signInWithEmailAndPassword(email: email, password: password);
    } else {
      return null;
    }
  }
}