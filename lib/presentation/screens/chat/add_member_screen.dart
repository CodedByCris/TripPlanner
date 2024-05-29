// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
import '../../providers/theme_provider.dart';

class User {
  final String email;
  final String imageUrl;

  User({required this.email, required this.imageUrl});
}

class AddMemberScreen extends StatefulWidget {
  String idGrupo;
  AddMemberScreen({super.key, required this.idGrupo});

  @override
  AddMemberScreenState createState() => AddMemberScreenState();
}

class AddMemberScreenState extends State<AddMemberScreen> {
  final db = DatabaseHelper();
  MySqlConnection? conn;

  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final groupNameController = TextEditingController();
  String? selectedUser;

  // Change users to a Map
  Map<String, User> users = {};
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    conn = await db.getConnection();

    final userResult = await conn!.query(
        'SELECT NombreUsuario, Correo, Imagen FROM Usuario WHERE Correo != ?',
        [correo]);

    // Add the results to the users map
    for (var row in userResult) {
      users[row['NombreUsuario']] =
          User(email: row['Correo'], imageUrl: row['Imagen'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Consumer(builder: (context, ref, child) {
      final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'AGREGAR MIEMBRO',
              style: TextStyle(
                color: isDarkMode
                    ? colors.secondary
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          body: FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.error != null) {
                // If there is an error, display a message
                return const Center(child: Text('Ha ocurrido un error'));
              } else {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    String userName = users.keys.elementAt(index);
                    return ListTile(
                      title: Text(userName),
                      subtitle: Text(users[userName]!.email),
                      leading: users[userName]!.imageUrl.isEmpty
                          ? const Icon(Icons.person)
                          : CircleAvatar(
                              backgroundImage:
                                  NetworkImage(users[userName]!.imageUrl),
                            ),
                      onTap: () async {
                        // Get the selected user's email
                        String selectedUserEmail = users[userName]!.email;

                        try {
                          await conn!.query(
                            'INSERT INTO Usuario_GrupoViaje (Correo, IdGrupo) VALUES (?, ?)',
                            [selectedUserEmail, widget.idGrupo],
                          );
                          Snackbar().mensaje(
                              context, 'Usuario añadido al grupo exitosamente');
                        } on MySqlException catch (e) {
                          if (e.errorNumber == 1062) {
                            Snackbar().mensaje(context,
                                'Ese usuario ya está agregado al grupo');
                          } else {
                            // Handle any other error
                            Snackbar().mensaje(context,
                                'Ha ocurrido un error al agregar al usuario al grupo');
                          }
                        }

                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
          ));
    });
  }
}
