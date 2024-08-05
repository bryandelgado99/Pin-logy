import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pin_logy/components/logout_Dialog.dart';
import 'package:pin_logy/components/theme_switcher.dart';
import 'package:pin_logy/services/auth/admin/admin_auth_provider.dart';
import 'package:pin_logy/views/admin/pages/addUser_page.dart';
import 'package:pin_logy/views/admin/pages/userList_page.dart';
import 'package:pin_logy/views/admin/pages/locationHistory_page.dart';

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

  List<Map<String, dynamic>> _usersWithLocations = [];
  bool _isLoading = true;

  DateTime? _lastPressedTime;
  static const int _doublePressInterval = 2; // Intervalo en segundos

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getUsersWithLocations();
  }

  Future<void> _getUserData() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        final uid = _user!.uid;
        final userDoc = await FirebaseFirestore.instance
            .collection('Admins')
            .doc(uid)
            .get();

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

  Future<void> _getUsersWithLocations() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      if (usersSnapshot.docs.isNotEmpty) {
        final selectedUsers = (usersSnapshot.docs..shuffle())
            .take(4)
            .toList(); // Obtener 4 usuarios
        List<Map<String, dynamic>> usersWithLocations = [];

        for (var userDoc in selectedUsers) {
          var user = userDoc.data();
          var userId = userDoc.id;
          var locationsSnapshot = await FirebaseFirestore.instance
              .collection('UserLocations')
              .doc(userId)
              .get();

          var locations = locationsSnapshot.data() ?? {};

          usersWithLocations.add({
            'name': user['name'] ?? 'Nombre no disponible',
            'lastName': user['lastName'] ?? 'Apellido no disponible',
            'locations': locations,
          });
        }

        setState(() {
          _usersWithLocations = usersWithLocations;
          _isLoading = false;
        });
      } else {
        print('No se encontraron usuarios en la colección Users.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener ubicaciones de usuarios: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    final currentTime = DateTime.now();
    final isDoublePress = _lastPressedTime != null &&
        currentTime.difference(_lastPressedTime!) <=
            const Duration(seconds: _doublePressInterval);

    if (isDoublePress) {
      SystemNavigator.pop();
      return true;
    } else {
      _lastPressedTime = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presiona nuevamente para salir'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.home,
                color: Theme.of(context).appBarTheme.iconTheme?.color ??
                    Colors.white,
              ),
              const SizedBox(
                width: 12,
              ),
              Text("Inicio",
                  style: Theme.of(context).appBarTheme.titleTextStyle),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        drawer: _onDrawer(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildUserMaps(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              tooltip: 'Lista de ubicaciones',
              heroTag: 'Lista de ubicaciones',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationHistoryPage(),
                  ),
                );
              },
              child: const Icon(EvaIcons.map),
            ),
            const SizedBox(
              height: 12,
            ),
            FloatingActionButton.extended(
              heroTag: 'Agregar usuario',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdduserPage(),
                  ),
                );
              },
              label: const Row(
                children: [
                  Text("Nuevo usuario"),
                  SizedBox(
                    width: 12,
                  ),
                  Icon(EvaIcons.person_add),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMaps() {
    if (_usersWithLocations.isEmpty) {
      return const Center(
          child: Text('No se encontraron usuarios con ubicaciones.'));
    }

    return ListView.builder(
      itemCount: _usersWithLocations.length,
      itemBuilder: (context, index) {
        var user = _usersWithLocations[index];
        var name = user['name'];
        var lastName = user['lastName'];
        var locations = user['locations'] as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name $lastName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        locations['latitude']?.toDouble() ?? 0.0,
                        locations['longitude']?.toDouble() ?? 0.0,
                      ),
                      zoom: 12,
                    ),
                    markers: _buildMarkers(locations),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers(Map<String, dynamic> locations) {
    return locations.entries
        .map((entry) {
          var loc = entry.value;
          if (loc is Map<String, dynamic>) {
            return Marker(
              markerId: MarkerId(entry.key),
              position: LatLng(
                loc['latitude']?.toDouble() ?? 0.0,
                loc['longitude']?.toDouble() ?? 0.0,
              ),
            );
          }
          return null;
        })
        .whereType<Marker>()
        .toSet();
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Agregar usuario'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdduserPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de usuarios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserListPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Historial de ubicaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationHistoryPage(),
                ),
              );
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
                    LogoutDialog.show(context, _authProvider);
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
