import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _saveLocationToFirestore();
      });
    } catch (e) {
      print("Location Error: $e");
    }
  }

  void _saveLocationToFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _currentPosition != null) {
      _firestore.collection('users').doc(user.uid).set({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      // Manejar el caso cuando _currentPosition es null, quizás mostrar un loading o un mensaje de error
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Ubicación Actual'),
        ),
        body: const Center(child: Text('Ubicación no disponible')),
      );
    }

    LatLng currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Ubicación Actual'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLatLng,
          ),
        },
        mapType: MapType.normal,
      ),
    );
  }
}