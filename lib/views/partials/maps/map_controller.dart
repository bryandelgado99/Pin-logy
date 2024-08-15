import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:pin_logy/helpers/image_bite.dart';
import 'package:pin_logy/views/partials/maps/map_style.dart';

class MapController extends ChangeNotifier {
  // Lista de marcadores
  final Map<MarkerId, Marker> _markers = {};

  // Establecimiento de marcas
  Set<Marker> get markers => _markers.values.toSet();

  final _pinIcon = Completer<BitmapDescriptor>();
  final Completer<GoogleMapController> _mapController = Completer();

  bool _loading =  true;
  bool get loading => _loading;

  // Booleano para definir el estao del GPS Android
  late bool _isGPSEnabled;
  bool get gpsEnabled => _isGPSEnabled;

  StreamSubscription? _gpsSubscription;

  // Posición predeterminada
  Position? _initialPosition;
  CameraPosition get initialCameraPosition {
    if (_initialPosition != null) {
      return CameraPosition(
        target: LatLng(
          _initialPosition!.latitude,
          _initialPosition!.longitude,
        ),
        zoom: 15,
      );
    } else {
      return const CameraPosition(
        target: LatLng(0.0, 0.0),
        zoom: 15,
      );
    }
  }

  // Obtenemos latitud y longitud, descomponiendo la camara inicial de posición
  double? get initialLatitude => _initialPosition?.latitude;
  double? get initialLongitude => _initialPosition?.longitude;

  void setInitialPosition(Position position) {
    _initialPosition = position;
    notifyListeners();
  }

  MapController() {
    _init();
  }

  Future<void> _init() async{
    final value = await imageToBytes('assets/user-tag-svgrepo-com.png');
    final bitMap = BitmapDescriptor.fromBytes(value);
    _pinIcon.complete(bitMap);

    // Comprobación de GPS habilitado
    _isGPSEnabled = await Geolocator.isLocationServiceEnabled();

    _loading = false;

    //Escucha el estado del servicio
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
            (status) async {
          _isGPSEnabled = status == ServiceStatus.enabled;
          await getInitialPosition();
          notifyListeners();
        }
    );
    await getInitialPosition();
    notifyListeners();
  }

  // Función para obtener la posición incial con GPS
  Future<void> getInitialPosition() async{
    if(_isGPSEnabled && _initialPosition == null){
      //_initialPosition = await Geolocator.getLastKnownPosition();
      _initialPosition = await Geolocator.getCurrentPosition();
    }
  }

  //Función para enceder GPS
  Future<void> enableGPS() async => await Geolocator.openLocationSettings();

  // Función para cambiar estilo de mapa
  void onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    controller.setMapStyle(mapData);
  }

  // Agregar marcador
  void onTap(LatLng position) async {
    final icon = await _pinIcon.future;

    final markerId = MarkerId(_markers.length.toString());
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: icon,
    );
    _markers[markerId] = marker;
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }
}