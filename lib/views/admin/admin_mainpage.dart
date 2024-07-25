// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

class AdminMainpage extends StatefulWidget {
  const AdminMainpage({super.key});

  @override
  _AdminMainpageState createState() => _AdminMainpageState();
}

class _AdminMainpageState extends State<AdminMainpage> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenido Admin"),
      ),
      body: const Center(child: Text("Hello")),
    );
  }
}