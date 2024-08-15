import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_logy/views/partials/maps/map_controller.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapController>(
      create: (_) => MapController(),
      child: Scaffold(
        body: Selector<MapController, bool>(
          selector: (_, controller) => controller.loading,
          builder: (context, loading, progressIndicator) {
            if (loading) {
              return progressIndicator!;
            }
            return Consumer<MapController>(
              builder: (context, controller, __) {
                if (!controller.gpsEnabled) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          icon: const Icon(Icons.crisis_alert_rounded),
                          title: const Text("Acceso al GPS"),
                          content: Text(
                            "Para poder usar la aplicación, activa el GPS y obtener tu posición en tiempo real",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                controller.enableGPS();
                                Navigator.pop(context); // Cierra el diálogo después de activar el GPS
                              },
                              child: const Text("Activar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancelar"),
                            ),
                          ],
                        );
                      },
                    );
                  });
                }

                final initialCameraPosition = CameraPosition(
                  target: LatLng(
                    controller.initialPosition!.longitude,
                    controller.initialPosition!.latitude
                  ),
                  zoom: 15
                );

                return GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: controller.onMapCreated,
                  polylines: controller.polylines,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  markers: controller.markers,
                  onTap: controller.onTap,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  polygons: controller.polygons,
                );
              },
            );
          },
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}