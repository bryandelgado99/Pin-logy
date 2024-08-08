import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Colors.white,
            ),
            const SizedBox(
              width: 12,
            ),
            Text("Tu ubicación",
                style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const Center(
        child: Text("Hello"),
      ),
    );
  }
}
