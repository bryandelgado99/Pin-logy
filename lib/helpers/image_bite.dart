import 'dart:ui' as ui;

import 'package:flutter/services.dart';

Future<Uint8List> imageToBytes(String path, {int width = 100, int height = 100}) async{
  final byteData = await rootBundle.load(path);
  final bytes = byteData.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(
      bytes, targetWidth: width, targetHeight: height
  );
  final frame = await codec.getNextFrame();
  final newbyteData = await frame.image.toByteData(
    format: ui.ImageByteFormat.png
  );
  return newbyteData!.buffer.asUint8List();
}