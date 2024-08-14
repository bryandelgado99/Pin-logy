import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class RequestPermissionController{
  final Permission location_permitions;

  RequestPermissionController(this.location_permitions);
  final _stringController = StreamController<PermissionStatus>.broadcast();

  Stream<PermissionStatus> get onPermissionChanged => _stringController.stream;


  request() async{
    final status = await location_permitions.request();
    _notifyUser(status);
  }

  void _notifyUser(PermissionStatus status){
    if(!_stringController.isClosed && _stringController.hasListener){
      _stringController.sink.add(status);
    }

  }

  void dispose(){
    _stringController.close();
  }
}