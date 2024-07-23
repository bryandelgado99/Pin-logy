import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pin_logy/views/partials/compose_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    redirectPage(context);
  }

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);

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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Image.asset("assets/icon.png", scale: 2.5,)),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor,),
                  const SizedBox(height: 25),
                  Text("Cargando componentes", style: theme.textTheme.titleMedium,)
                ]
              )
            ],
          )
        ],
      ),
    );
  }

  Future <void> redirectPage(BuildContext context) async{
     await Future.delayed(
       const Duration(seconds: 10)
     );
     Navigator.push(context, MaterialPageRoute(builder: (context)=> const ComposeView()));
  }
}