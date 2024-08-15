import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

Future<Uint8List> imageToBytes(String path, {int width = 100, int height = 100}) async{
  final byteData = await rootBundle.load(path);
  final bytes = byteData.buffer.asUint8List();
  final UI.Codec codec = await UI.instantiateImageCodec(
      bytes, targetWidth: width, targetHeight: height
  );
  final frame = await codec.getNextFrame();
  final newbyteData = await frame.image.toByteData(
    format: UI.ImageByteFormat.png
  );
  return newbyteData!.buffer.asUint8List();
}