import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //***************************************************************Métodos de correo electronico
  Future<void> registerAdmin({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String rol,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Guardar datos del administrador en Firestore sin la contraseña
        await _firestore.collection('Admins').doc(user.uid).set({
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
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
          return user; // Contraseña correcta, autenticada por Firebase Auth
        } else {
          if (kDebugMode) {
            print('No se encontró el documento del administrador.');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('No se pudo autenticar al usuario.');
        }
        return null;
      }
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

  //Función para recuperar contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print("Password reset email sent");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send password reset email: $e");
      }
    }
  }
  //***************************************************************************

//************************************************** Métodos con Google Account
}
