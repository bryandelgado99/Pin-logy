import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  _LocationHistoryPageState createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _getTerrains();
  }

// Obtener la froma del terreno
  Future<void> _getTerrains() async {
    FirebaseFirestore.instance
        .collection('terrains')
        .snapshots()
        .listen((snapshot) {
      Set<Polygon> newPolygons = {};
      for (var doc in snapshot.docs) {
        List<LatLng> points = [];
        for (var point in doc['points']) {
          points.add(LatLng(point.latitude, point.longitude));
        }
        newPolygons.add(
          Polygon(
            polygonId: PolygonId(doc.id),
            points: points,
            strokeWidth: 2,
            fillColor: Colors.green.withOpacity(0.5),
          ),
        );
      }
      setState(() {});
    });
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
                        _selectedUserId =
                            _selectedUserId == userId ? null : userId;
                      });
                    },
                  ),
                  if (_selectedUserId == userId) _buildUserCard(userId),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('UserLocations')
          .doc(userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error fetching user location data: ${snapshot.error}');
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error al cargar datos'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          print('No data found for user ID: $userId');
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin historial reciente'),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>?;

        print('Data fetched for user ID: $userId: $data'); // Depuración

        if (data == null ||
            !data.containsKey('locations') ||
            (data['locations'] as List).isEmpty) {
          print('No location data for user ID: $userId');
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin historial reciente'),
            ),
          );
        }

        var locationList =
            (data['locations'] as List<dynamic>).cast<Map<String, dynamic>>();
        print('Locations list: $locationList'); // Depuración

        List<Marker> markers = locationList.map((location) {
          var lat = (location['latitude'] as num?)?.toDouble() ?? 0.0;
          var lng = (location['longitude'] as num?)?.toDouble() ?? 0.0;
          return Marker(
            markerId: MarkerId(location['id'] ?? 'unknown'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: location['name'] ?? 'No Name'),
          );
        }).toList();

        print('Markers: $markers'); // Depuración

        if (markers.isEmpty) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sin historial reciente'),
            ),
          );
        }

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
                      target: LatLng(
                        markers.isNotEmpty
                            ? markers.first.position.latitude
                            : 0.0,
                        markers.isNotEmpty
                            ? markers.first.position.longitude
                            : 0.0,
                      ),
                      zoom: 12,
                    ),
                    markers: Set<Marker>.of(markers),
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
