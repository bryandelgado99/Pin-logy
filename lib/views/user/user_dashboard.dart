import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/services/auth/user/user_auth_provider.dart';
import 'package:pin_logy/services/requests/request_page.dart';
import 'package:pin_logy/views/partials/maps/map_controller.dart';
import 'package:pin_logy/views/partials/maps/map_view.dart';
import 'package:provider/provider.dart';

class UserDashboard extends StatefulWidget {
  final String userId; // Añadir el uid como parámetro

  const UserDashboard({super.key, required this.userId});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String _userName = '';
  String _userLastName = '';
  String _userRole = '';

  final UserAuthProvider _authProvider = UserAuthProvider();

  @override
  void initState() {
    super.initState();
    _getUserData(widget.userId); // Usa el uid del widget
  }

  // Función para obtener los datos del usuario desde Firestore
  Future<void> _getUserData(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (kDebugMode) {
          print("User Data: $userData");
        }  // Para depuración

        if (userData != null) {
          // Asigna los datos del usuario a las variables correspondientes
          setState(() {
            _userName = userData['name'] ?? 'Sin nombre';
            _userLastName = userData['lastName'] ?? '';
            _userRole = userData['role'] ?? 'Rol no disponible';
          });
        }
      } else {
        if (kDebugMode) {
          print("User document does not exist");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos del usuario: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white,
            ),
            const SizedBox(width: 12),
            Text("Tu ubicación", style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: _onDrawer(context),
      body: const MapView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              final controller = Provider.of<MapController>(context, listen: true);
              return onModalSheet(context, controller);
            },
          );
        },
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
            accountEmail: Text('Rol: $_userRole'),
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
                    _authProvider.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => RequestPage(userId: widget.userId)),
                          (Route<dynamic> route) => false, // Esto asegura que todas las rutas anteriores se eliminen
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 8),
                      Text(
                        "Salir",
                        style: Theme.of(context).textTheme.bodyMedium,
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

  Widget onModalSheet(BuildContext context, MapController controller) {
    final MapController controller = Provider.of<MapController>(context, listen: false);

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_location),
                  const SizedBox(width: 10),
                  Text("Información sobre la Ubicación", style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _latitudLabel(controller.initialLatitude),
            const SizedBox(height: 10),
            _longitudLabel(controller.initialLongitude),
            const SizedBox(height: 10),
            _areaLabel(), // Mantén esto si tienes un área de polígono que quieras mostrar
          ],
        ),
      ),
    );
  }

  Widget _latitudLabel(double? latitude) {
    return Row(
      children: [
        Text(
          "Latitud:",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          latitude?.toString() ?? 'Desconocida',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _longitudLabel(double? longitude) {
    return Row(
      children: [
        Text(
          "Longitud:",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          longitude?.toString() ?? 'Desconocida',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _areaLabel() {
    // Implementación para el área del polígono si es necesario
    return Row(
      children: [
        Text(
          "Área del polígono:",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "poligon_area.toString(),",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}