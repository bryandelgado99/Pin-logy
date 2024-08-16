import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_logy/components/info_dialog.dart';
import 'map_style.dart';

class MapController extends ChangeNotifier {
  // Lista de marcadores
  final Map<MarkerId, Marker> _markers = {};

  // Líneas de ubicación
  final Map<PolylineId, Polyline> _polylines = {};

  // Polígonos de formas
  final Map<PolygonId, Polygon> _polygons = {};

  // Establecimiento de marcas
  Set<Marker> get markers => _markers.values.toSet();
  Set<Polyline> get polylines => _polylines.values.toSet();
  Set<Polygon> get polygons => _polygons.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  bool _loading = true;
  bool get loading => _loading;

  // Booleano para definir el estado del GPS Android
  late bool _isGPSEnabled;
  bool get gpsEnabled => _isGPSEnabled;

  StreamSubscription? _gpsSubscription, _positionSubcription;
  GoogleMapController? _googleMapController;

  String _polygonId = '0';

  // Posición predeterminada
  Position? _initialPosition;
  Position? get initialPosition => _initialPosition;

  // Obtenemos latitud y longitud, descomponiendo la cámara inicial de posición
  double? get initialLatitude => _initialPosition?.latitude;
  double? get initialLongitude => _initialPosition?.longitude;

  void setInitialPosition(Position position) {
    _initialPosition = position;
    notifyListeners();
  }

  MapController() {
    _init();
  }

  // Función para cambiar el estilo del mapa
  void onMapCreated(GoogleMapController controller,  BuildContext context) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    _googleMapController = controller;
    controller.setMapStyle(mapData);
    notifyListeners();

    // Mostrar el diálogo una vez que el mapa se haya cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const InfoDialog();
        },
      );
    });
  }

  Future<void> _init() async {
    // Comprobación de GPS habilitado
    _isGPSEnabled = await Geolocator.isLocationServiceEnabled();
    _loading = false;

    // Escucha el estado del servicio
    _gpsSubscription = Geolocator.getServiceStatusStream().listen((status) async {
      _isGPSEnabled = status == ServiceStatus.enabled;
      if (_isGPSEnabled) {
        _initLocationUpdates();
      }
    });
    _initLocationUpdates();
  }

  // Función para obtener la posición inicial con GPS
  getInitialPosition(Position position) {
    if (_isGPSEnabled && _initialPosition == null) {
      _initialPosition = position;
    }
  }

  // Función para actualizar la posición
  Future<void> _initLocationUpdates() async {
    bool initialized = false;
    await _positionSubcription?.cancel();
    _positionSubcription = Geolocator.getPositionStream().listen(
          (position) async {
        if (kDebugMode) {
          print("🗺️: $position");
        }
        if (!initialized) {
          getInitialPosition(position);
          initialized = true;
          notifyListeners();
        }
        final googleMapController = this._googleMapController;
        if (googleMapController != null) {
          final zoom = await googleMapController.getZoomLevel();
          final cameraUpdate = CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            zoom,
          );
          googleMapController.animateCamera(cameraUpdate);
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error: ${e.runtimeType} ⚠️");
        }
        if (e is LocationServiceDisabledException) {
          _isGPSEnabled = false;
          notifyListeners();
        }
      },
    );
  }

  // Método simplificado y fusionado para mover la cámara a una nueva posición
  Future<void> moveCameraToPosition(double latitude, double longitude) async {
    final GoogleMapController controller = await _mapController.future;
    // Crear una nueva posición de cámara
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15, // Ajusta el nivel de zoom según sea necesario
      ),
    );
    // Animar la cámara a la nueva posición
    controller.animateCamera(cameraUpdate);
  }

  // Función para encender GPS
  Future<void> enableGPS() async => await Geolocator.openLocationSettings();

  // Actualiza el ID del polígono cuando se crea uno nuevo
  void newPolygon() {
    _polygonId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Agregar marcador
  void onTap(LatLng position) {
    final polygonID = PolygonId(_polygonId);
    late Polygon polygon;

    if (_polygons.containsKey(polygonID)) {
      final tmp = _polygons[polygonID]!;
      polygon = tmp.copyWith(
          pointsParam: [...tmp.points, position]
      );
    } else {
      polygon = Polygon(
        polygonId: polygonID,
        points: [position],
        fillColor: Colors.blueGrey.withOpacity(0.5),
        strokeColor: Colors.blueGrey,
        strokeWidth: 2,
      );
    }

    _polygons[polygonID] = polygon;
    notifyListeners();
  }

  // Método para borrar el polígono al hacer long press
  void onLongPressTap() {
    final polygonID = PolygonId(_polygonId);

    if (_polygons.containsKey(polygonID)) {
      _polygons.remove(polygonID); // Eliminar el polígono del mapa
      notifyListeners(); // Notificar a los listeners para que se actualice la UI
    }
  }


  // Método para calcular el área del polígono en metros cuadrados
  double calculatePolygonArea() {
    final polygonID = PolygonId(_polygonId);
    if (!_polygons.containsKey(polygonID)) {
      return 0.0; // Retornar 0 si no hay polígono
    }

    final polygon = _polygons[polygonID]!;
    return _computePolygonArea(polygon.points);
  }

  // Método privado para calcular el área de un polígono
  double _computePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final point1 = points[i];
      final point2 = points[(i + 1) % points.length];

      final lat1 = _toRadians(point1.latitude);
      final lng1 = _toRadians(point1.longitude);
      final lat2 = _toRadians(point2.latitude);
      final lng2 = _toRadians(point2.longitude);

      area += (lng2 - lng1) * (2 + math.sin(lat1) + math.sin(lat2));
    }

    area = area.abs() * 6378137.0 * 6378137.0 / 2.0;
    return area;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }

  @override
  void dispose() {
    _positionSubcription?.cancel(); // Cuando ya no aparezca la página, se cancela el escucha de cambios de ubicación
    _gpsSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }
}
