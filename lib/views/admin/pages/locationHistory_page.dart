import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  _LocationHistoryPageState createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  String? _selectedUserId;
  bool _locationPermissionGranted = false;

  void _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    setState(() {
      _locationPermissionGranted = status.isGranted;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ubicaciones'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userDoc = users[index];
              var user = userDoc.data() as Map<String, dynamic>;
              var userName = user['name'] ?? 'Nombre no disponible';
              var userLastName = user['lastName'] ?? 'Apellido no disponible';
              var userEmail = user['email'] ?? 'Correo no disponible';
              var userId = userDoc.id;

              return Column(
                children: [
                  ListTile(
                    title: Text("$userName $userLastName"),
                    subtitle: Text(userEmail),
                    onTap: () {
                      setState(() {
                        _selectedUserId = _selectedUserId == userId ? null : userId;
                      });
                    },
                  ),
                  if (_selectedUserId == userId) UserLocationMap(userId: userId, locationPermissionGranted: _locationPermissionGranted),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class UserLocationMap extends StatelessWidget {
  final String userId;
  final bool locationPermissionGranted;

  const UserLocationMap({
    required this.userId,
    required this.locationPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('UserLocations').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error al cargar datos'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin historial reciente'),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('locations') || data['locations'] == null) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin historial reciente'),
            ),
          );
        }

        var locationList = (data['locations'] as List<dynamic>).cast<Map<String, dynamic>>();

        if (locationList.length < 3) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay suficientes ubicaciones para crear un polígono.'),
            ),
          );
        }

        List<LatLng> points = locationList.map((location) {
          var lat = (location['latitude'] as num?)?.toDouble() ?? 0.0;
          var lng = (location['longitude'] as num?)?.toDouble() ?? 0.0;
          return LatLng(lat, lng);
        }).toList();

        Set<Polygon> polygons = {
          Polygon(
            polygonId: const PolygonId('user_area'),
            points: points,
            strokeWidth: 2,
            fillColor: Colors.green.withOpacity(0.5),
          ),
        };

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de Ubicaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: points.isNotEmpty ? points.first : const LatLng(0.0, 0.0),
                      zoom: 12,
                    ),
                    myLocationEnabled: locationPermissionGranted,
                    polygons: polygons,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
