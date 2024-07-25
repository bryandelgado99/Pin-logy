import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerAdmin({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String rol,
  }) async {
    try {
      // Encriptar la contraseña
      final hashedPassword = _hashPassword(password);

      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Guardar datos del administrador en Firestore
        await _firestore.collection('Admins').doc(user.uid).set({
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'password': hashedPassword, // Guardar el hash de la contraseña
          'rol': rol,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar administrador: $e');
      }
      rethrow;
    }
  }

  Future<User?> loginAdmin({
    required String correo,
    required String password,
  }) async {
    try {
      // Iniciar sesión con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Obtener los datos del administrador desde Firestore
        final adminDoc = await _firestore.collection('Admins').doc(user.uid).get();

        if (adminDoc.exists) {
          final adminData = adminDoc.data();
          final storedHashedPassword = adminData?['password'] ?? '';

          // Hash de la contraseña proporcionada por el usuario
          final hashedPassword = _hashPassword(password);

          // Comparar los hashes
          if (hashedPassword == storedHashedPassword) {
            return user; // Contraseña correcta
          } else {
            print('Contraseña incorrecta.');
            return null;
          }
        } else {
          print('No se encontró el documento del administrador.');
          return null;
        }
      } else {
        print('No se pudo autenticar al usuario.');
        return null;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  // Función para cerrar sesión con correo
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Usuario cerrado sesión correctamente.');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }


  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convertir contraseña a bytes
    final digest = sha256.convert(bytes); // Crear hash SHA-256
    return digest.toString(); // Convertir hash a cadena hexadecimal
  }
}