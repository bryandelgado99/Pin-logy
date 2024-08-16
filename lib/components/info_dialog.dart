import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.info_outline),
      title: Text("Antes de empezar", style: Theme.of(context).textTheme.headlineSmall,),
        content: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Este mapa proporciona información en tiempo real sobre tu ubicación. Puedes crear y eliminar polígonos para marcar áreas de interés, determinar sus áreas, etc.",
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 15),
            Text("Los pasos a realizar son:"),
            SizedBox(height: 8),
            // Primer elemento de la lista
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• "), // El símbolo del punto
                Expanded(
                  child: Text(
                    "Para crear polígonos debes dar un toque en cualquier punto de la pantalla. Recuerda que se necesitan más de tres puntos.",
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Segundo elemento de la lista
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• "), // El símbolo del punto
                Expanded(
                  child: Text(
                    "Mantén presionado sobre el polígono para eliminar este del mapa, al igual que sus puntos de interés.",
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
