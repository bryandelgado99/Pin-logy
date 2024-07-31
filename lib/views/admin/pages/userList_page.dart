import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // Variable to store the ID of the user being edited
  String? _editingUserId;

  // Controllers for editing user details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Variable to store the Future of the users collection
  late Future<QuerySnapshot> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<QuerySnapshot> _fetchUsers() {
    return FirebaseFirestore.instance.collection('Users').get();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _updateUser(String userId) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'name': _nameController.text,
      'lastName': _lastNameController.text,
    });
    _refreshUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario actualizado correctamente')),
    );
  }

  Future<void> _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
    _refreshUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Usuarios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los usuarios'));
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userDoc = users[index];
              var user = userDoc.data() as Map<String, dynamic>;
              var userName = user['name'] ?? 'Nombre no disponible';
              var userLastName = user['lastName'] ?? 'Apellido no disponible';
              var userEmail = user['email'] ?? 'Correo no disponible';
              var userId = userDoc.id;

              return Column(
                children: [
                  ListTile(
                    title: Text("$userName $userLastName"),
                    subtitle: Text(userEmail),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _editingUserId = userId;
                              _nameController.text = userName;
                              _lastNameController.text = userLastName;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final shouldDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text(
                                    '¿Estás seguro de que deseas eliminar este usuario?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete) {
                              await _deleteUser(userId);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_editingUserId == userId)
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration:
                                  const InputDecoration(labelText: 'Nombre'),
                            ),
                            TextField(
                              controller: _lastNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Apellido'),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _editingUserId = null;
                                    });
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updateUser(userId),
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
