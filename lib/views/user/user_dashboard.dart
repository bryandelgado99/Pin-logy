import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_logy/components/info_dialog.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/services/auth/user/user_auth_provider.dart';
import 'package:pin_logy/services/requests/request_page.dart';
import 'package:pin_logy/views/partials/maps/map_controller.dart';
import 'package:pin_logy/views/partials/maps/map_view.dart';
import 'package:provider/provider.dart';

class UserDashboard extends StatefulWidget {
  final String userId;

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
        }

        if (userData != null) {
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
    return ChangeNotifierProvider(
      create: (_) => MapController(),
      child: Scaffold(
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
            actions: [
              IconButton(
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return const InfoDialog();
                        }
                    );
                  },
                  icon: const Icon(Icons.info_rounded)
              )
            ],
            backgroundColor: Theme.of(context).primaryColor,
          ),
          drawer: _onDrawer(context),
          body: Stack(
            children: [
              const MapView(),
              Positioned(
                right: 16,  // Mueve el card hacia la derecha
                bottom: 16, // Mueve el card hacia abajo
                child: Consumer<MapController>(
                  builder: (context, controller, child) {
                    return onCardAdvice(context, controller);
                  },
                ),
              ),
            ],
          )
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
          ListTile(
            leading: const Icon(Icons.school_rounded),
            title: const Text('Escuela Politécnica Nacional'),
            onTap: () {
              context.read<MapController>().moveCameraToPosition(-0.2124413, -78.4931591);
              Navigator.pop(context);
            },
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
                          (Route<dynamic> route) => false,
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

  Widget onCardAdvice(BuildContext context, MapController controller){
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share_location),
                const SizedBox(width: 10),
                Text("Detalles de Ubicación", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            _latitudLabel(controller.initialLatitude),
            const SizedBox(height: 8),
            _longitudLabel(controller.initialLongitude),
            const SizedBox(height: 8),
            _areaLabel(controller.calculatePolygonArea()), // Mostrar el área calculada
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

  Widget _areaLabel(double? area) {
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
          area?.toStringAsFixed(2) ?? "Sin medida", // Muestra el área con dos decimales
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
