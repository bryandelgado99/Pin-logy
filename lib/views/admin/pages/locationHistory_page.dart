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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var locations = snapshot.data!.data() as Map<String, dynamic>?;

        if (locations == null || locations.isEmpty) {
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
                        locations['latitude'] ?? 0.0,
                        locations['longitude'] ?? 0.0,
                      ),
                      zoom: 12,
                    ),
                    markers: Set<Marker>.of(
                      locations.entries.map(
                        (entry) {
                          var loc = entry.value;
                          return Marker(
                            markerId: MarkerId(entry.key),
                            position: LatLng(
                              loc['latitude'] ?? 0.0,
                              loc['longitude'] ?? 0.0,
                            ),
                          );
                        },
                      ),
                    ),
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
