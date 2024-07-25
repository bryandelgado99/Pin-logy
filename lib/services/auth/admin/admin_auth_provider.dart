import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AdminAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función paa registrar administrador
  Future<void> registerAdmin({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String rol,
  }) async {
    try {
      // Encriptar la contraseña
      final key = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encryptedPassword = encrypter.encrypt(password, iv: iv);

      // Registrar el administrador en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password, // Guarda la contraseña en texto plano solo para crear el usuario
      );

      // Guardar los datos en Firestore
      await _firestore.collection('Admins').doc(userCredential.user?.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': encryptedPassword.base64, // Guardar la contraseña encriptada
        'rol': rol,
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar el administrador: $e');
      }
      rethrow;
    }
  }

  // Función para iniciar sesión como administrador
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
          final encryptedPassword = adminData?['password'] ?? '';

          // Desencriptar la contraseña
          final key = encrypt.Key.fromLength(32);
          final iv = encrypt.IV.fromLength(16);
          final encrypter = encrypt.Encrypter(encrypt.AES(key));

          final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);

          // Comparar las contraseñas
          if (decryptedPassword == password) {
            return user; // Contraseña correcta
          } else {
            if (kDebugMode) {
              print('Contraseña incorrecta.');
            }
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


}