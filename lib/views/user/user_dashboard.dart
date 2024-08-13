import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/services/auth/admin/admin_auth_provider.dart';
import '../../components/logout_Dialog.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  User? _user;
  String _userName = '';
  String _userLastName = '';
  String _userRole = '';
  final AdminAuthProvider authProvider = AdminAuthProvider();

  final _initialPosition = const CameraPosition(target: LatLng(25.15, 45.125));

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
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          print("User Data: $userData");  // Para depuración
          setState(() {
            _userName = userData?['nombre'] ?? 'Sin nombre';
            _userLastName = userData?['apellido'] ?? '';
            _userRole = userData?['rol'] ?? 'Rol no disponible';
          });
        } else {
          print("User document does not exist");
        }
      } else {
        print("User is null");
      }
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Colors.white,
            ),
            const SizedBox(
              width: 12,
            ),
            Text("Tu ubicación",
                style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: _onDrawer(context),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: "Información de ubicación",
        child: const Icon(Icons.info_rounded),
      ),
    );
  }

  Widget _onDrawer(BuildContext context) {
    var lightTheme = ThemeData.light();
    var darkTheme = ThemeData.dark();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Bienvenido/a, $_userName $_userLastName'),
            accountEmail: Text(_userRole),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomThemeSwitcher(
                  lightTheme: lightTheme,
                  darkTheme: darkTheme,
                ),
                ElevatedButton(
                  onPressed: () {
                    LogoutDialog.show(context, authProvider);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 8),
                      Text(
                        "Salir",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

