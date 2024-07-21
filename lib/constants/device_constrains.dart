import 'package:flutter/material.dart';

class DeviceConstraints {
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 700; // Puedes ajustar este valor según tus necesidades
  }

  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 700; // Puedes ajustar este valor según tus necesidades
  }
}