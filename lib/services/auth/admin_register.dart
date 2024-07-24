// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pin_logy/views/admin/admin_mainpage.dart';
import 'package:toastification/toastification.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Iniciar sesión con Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // El usuario canceló el inicio de sesión
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Iniciar sesión con Firebase
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) {
      return;
    }

    // Verificar si el usuario ya existe en Firestore
    var userQuery = await FirebaseFirestore.instance
        .collection('Admins')
        .where('email', isEqualTo: user.email)
        .get();

    String adminId;
    if (userQuery.docs.isNotEmpty) {
      // Usuario ya registrado con correo y contraseña, no permitir inicio de sesión con Google
      var userDoc = userQuery.docs.first;
      if (userDoc.data().containsKey('password')) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Error de inicio de sesión"),
          description: const Text("No puedes iniciar sesión con Google. Ya estás registrado con correo y contraseña."),
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
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return;
      }
      adminId = userDoc.id;
    } else {
      // Nuevo usuario, guardar en Firestore
      var newUserDoc = await FirebaseFirestore.instance.collection('Admins').add({
        'email': user.email,
        'name': user.displayName,
        // Otros datos que quieras guardar
      });
      adminId = newUserDoc.id;
      if (kDebugMode) {
        print(adminId);
      }
    }

    // Navegar a la página principal del administrador
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AdminMainpage(adminId: adminId)),
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
      description: const Text("Ocurrió un error durante el inicio de sesión."),
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
