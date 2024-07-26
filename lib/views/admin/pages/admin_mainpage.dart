// ignore_for_file: library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/design/theme.dart';
import 'package:pin_logy/services/auth/admin/admin_auth_provider.dart';
import 'package:pin_logy/views/admin/login_admin.dart';

class AdminMainpage extends StatefulWidget {
  const AdminMainpage({super.key});

  @override
  _AdminMainpageState createState() => _AdminMainpageState();
}

class _AdminMainpageState extends State<AdminMainpage> {
  User? _user;
  String _userName = '';
  String _userLastName = '';
  String _userRole = '';
  final AdminAuthProvider _authProvider = AdminAuthProvider();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }


  Future<void> _getUserData() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        final uid = _user!.uid;
        final userDoc = await FirebaseFirestore.instance.collection('Admins').doc(uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _userName = userData?['nombre'] ?? 'Nombre no disponible';
            _userLastName = userData?['apellido'] ?? 'Nombre no disponible';
            _userRole = userData?['rol'] ?? 'Rol no disponible';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos del usuario: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authProvider.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginAdmin()), // Reemplaza LoginPage con la pantalla de inicio de sesión
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cerrar sesión: $e');
      }
      // Mostrar mensaje de error o notificación si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido $_userName", style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: _onDrawer(context), // Aquí se integra el Drawer personalizado
      body: const Center(child: Text("Hello")),
    );
  }

  Widget _onDrawer(BuildContext context){
    var lightTheme = Themes.lightTheme;
    var darkTheme = Themes.darkTheme;

    return Drawer(
      child: Column(
        children: [
          // Header Drawer
          UserAccountsDrawerHeader(
            accountName: Text(_userName + ' ' + _userLastName),
            accountEmail: Text(_userRole),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          // Menu Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              //Navigator.pushNamed(context, '/home'); // Ajusta la ruta si es necesario
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Agregar usuario'),
            onTap: () {
              Navigator.pop(context);
              //Navigator.pushNamed(context, '/add-user'); // Ajusta la ruta si es necesario
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de usuarios'),
            onTap: () {
              Navigator.pop(context);
              //Navigator.pushNamed(context, '/user-list'); // Ajusta la ruta si es necesario
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Historial de ubicaciones'),
            onTap: () {
              Navigator.pop(context);
              //Navigator.pushNamed(context, '/location-list'); // Ajusta la ruta si es necesario
            },
          ),
          const Spacer(), // Empuja el botón hacia abajo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomThemeSwitcher(lightTheme: lightTheme, darkTheme: darkTheme),
                ElevatedButton(
                  onPressed: _signOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 8),
                      Text("Salir", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}