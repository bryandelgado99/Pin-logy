// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String email;
  final String name;
  final String lastname;

  Admin({required this.email, required this.name, required this.lastname});

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    return Admin(
        email: doc['email'], name: doc['nombre'], lastname: doc['apellido']);
  }
}
