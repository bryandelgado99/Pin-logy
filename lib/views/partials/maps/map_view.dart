import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_logy/views/partials/maps/map_controller.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapController>(
      create: (context) => MapController(),
      child: Scaffold(
        body: Consumer<MapController>(
            builder: (_, controller, __) => GoogleMap(
              initialCameraPosition: controller.initialPosition,
              onMapCreated: controller.onMapCreated,
              zoomControlsEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              markers: controller.markers,
              onTap: controller.onTap,
            ),
        ),
      ),
    );
  }
}

