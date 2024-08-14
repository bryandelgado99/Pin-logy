import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:pin_logy/views/partials/maps/map_style.dart';

class MapController extends ChangeNotifier{
  //Lista de marcadores
  final Map <MarkerId, Marker> _markers = {};

  //Establecimiento de marcas
  Set<Marker> get markers => _markers.values.toSet();

  //Posición predeterminada
  final initialPosition = const CameraPosition(target: LatLng(-0.2328349,-78.5230887), zoom: 15);

  // Función para cambiar estilo de mapa
  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapData);
  }

  //Función para obtener mi posición actual
 CameraPosition onRealTimePosition(double lat, double long){
    return CameraPosition(
        target: LatLng(lat, long),
        zoom: 13
    );
  }

  //Agregar marcador
  void onTap(LatLng position){
    final markerId = MarkerId(_markers.length.toString());
    final marker = Marker(
      markerId: markerId,
      position: position
    );

    _markers[markerId] = marker;
    notifyListeners();
  }
}
