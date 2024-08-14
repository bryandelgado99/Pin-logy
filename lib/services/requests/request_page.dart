import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_logy/services/requests/request_controller.dart';
import '../../views/user/user_dashboard.dart';

class RequestPage extends StatefulWidget {
  final String userId;
  const RequestPage({super.key, required this.userId});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.request();
    });
    _subscription = _controller.onPermissionChanged.listen(
          (status) async {
        if (status == PermissionStatus.granted) {
          try {
            // Navegar al UserDashboard con el userId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(userId: widget.userId),
              ),
            );
          } catch (e) {
            rethrow;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
            Positioned.fill(
              child: Image.asset(
                'assets/resource_abstract.png', // Cambia esto a la ruta de tu imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/pin-travel-svgrepo-com.png", scale: 6,),
                          const SizedBox(height: 25,),
                          Text("Acceso a tu ubicación", style: Theme.of(context).textTheme.titleLarge,),
                        ],
                      ),
                      Text("Para garantizar el acceso correcto a las funcionalidades de esta aplciación, debes conoceder el permiso para la lectura GPS de tu dispositivo.", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 25,),
                          Text("Esperando su permiso...", style: Theme.of(context).textTheme.labelMedium),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
