import 'package:flutter/material.dart';
import 'package:pin_logy/services/auth/user/user_auth_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {

  final UserAuthProvider _authProvider = UserAuthProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
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
        actions: [
          IconButton(
              onPressed: (){
                _authProvider.signOut();
              },
              icon: const Icon(Icons.logout_rounded)
          )
        ],
      ),
      body: const Center(
        child: Text("Hello"),
      ),
    );
  }
}
