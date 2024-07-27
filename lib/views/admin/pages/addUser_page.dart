import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../services/auth/user/user_auth_provider.dart';

class AdduserPage extends StatefulWidget {
  const AdduserPage({super.key});

  @override
  State<AdduserPage> createState() => _AdduserPageState();
}

class _AdduserPageState extends State<AdduserPage> {
  final GlobalKey<FormState> _registerKey = GlobalKey<FormState>();
  final TextEditingController _nameUserController = TextEditingController();
  final TextEditingController _lastnameUserController = TextEditingController();
  final TextEditingController _mailUserController = TextEditingController();
  final UserAuthProvider _authProvider = UserAuthProvider();

  Future<void> _registerNewUser() async {
    if (_registerKey.currentState!.validate()) {
      try {
        // Obtener el adminId del administrador en sesión
        String? adminId = await _authProvider.getAdminId();
        if (adminId == null) {
          throw Exception('No se pudo obtener el adminId del administrador en sesión.');
        }

        await _authProvider.registerUser(
          name: _nameUserController.text,
          lastName: _lastnameUserController.text,
          email: _mailUserController.text,
          adminId: adminId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado con éxito. Se ha enviado un correo con la contraseña.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              EvaIcons.person_add,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              "Agregar usuarios",
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Antes de comenzar",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Para registrar un nuevo usuario en el sistema, se debe completar el siguiente formulario con todos los datos necesarios. La contraseña generada será enviada al correo del nuevo usuario.",
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                _onRegisterUserForm(),
                const SizedBox(height: 100), // Espacio para que el contenido no esté sobre el botón
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FilledButton(
                  onPressed: _registerNewUser,
                  child: Text(
                    "Registrar usuario",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _onRegisterUserForm() {
    return Form(
      key: _registerKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Datos del Usuario",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _dataUserInfo(),
          const SizedBox(height: 12),
          _mailField(),
          const SizedBox(height: 25),
          Card(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Importante",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "La contraseña será generada automáticamente y almacenada en la base de datos. Se le enviará al usuario un correo electrónico con las credenciales de acceso.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataUserInfo() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Nombre"),
            ),
            keyboardType: TextInputType.text,
            controller: _nameUserController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                return 'La primera letra del nombre debe ser mayúscula';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Apellido"),
            ),
            keyboardType: TextInputType.text,
            controller: _lastnameUserController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obligatorio";
              } else if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                return 'La primera letra del apellido debe ser mayúscula';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _mailField() {
    return TextFormField(
      controller: _mailUserController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Correo electrónico"),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obligatorio";
        } else if (!value.contains('@')) {
          return 'Formato de correo electrónico incorrecto';
        }
        return null;
      },
    );
  }
}