import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
import '../../providers/theme_provider.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final db = DatabaseHelper();
  MySqlConnection? conn;

  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final groupNameController = TextEditingController();
  String? selectedUser;
  String? selectedGroupType;
  List<String> groupTypes = ['Chat privado', 'Grupo público', 'Grupo privado'];

  // Change users to a Map
  Map<String, String> users = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    conn = await db.getConnection();

    final userResult = await conn!.query(
        'SELECT NombreUsuario, Correo FROM Usuario WHERE Correo != ?',
        [correo]);

    // Add the results to the users map
    for (var row in userResult) {
      users[row['NombreUsuario']] = row['Correo'];
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
            'NUEVO CHAT',
            style: TextStyle(
              color: isDarkMode
                  ? colors.secondary
                  : const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: selectedUser,
                  items: users.keys.map((String user) {
                    return DropdownMenuItem<String>(
                      value: user,
                      child: Text(
                        user,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUser = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona un usuario';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedGroupType,
                  items: groupTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGroupType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona un tipo de grupo';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de grupo',
                  ),
                ),
                if (selectedGroupType != 'Chat privado') ...[
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Descripción del grupo'),
                  ),
                  TextFormField(
                    controller: groupNameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del grupo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre de grupo';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Get the selected user's email
                      String selectedUserEmail = users[selectedUser]!;

                      // Insert the new group
                      var result = await conn!.query(
                        'INSERT INTO Grupos_de_Viaje (Descripción, FechaCreacion, NombreGrupo, TipoGrupo) VALUES (?, ?, ?, ?)',
                        [
                          descriptionController.text.isEmpty
                              ? ""
                              : descriptionController.text.trim(),
                          DateTime.now().toIso8601String().substring(0, 10),
                          groupNameController.text.isEmpty
                              ? ""
                              : groupNameController.text.trim(),
                          groupTypes.indexOf(selectedGroupType!) + 1
                        ],
                      );

                      var idGrupo = result.insertId;

                      await conn!.query(
                        'INSERT INTO Usuario_GrupoViaje (Correo, IdGrupo) VALUES (?, ?)',
                        [correo, idGrupo],
                      );
                      await conn!.query(
                        'INSERT INTO Usuario_GrupoViaje (Correo, IdGrupo) VALUES (?, ?)',
                        [selectedUserEmail, idGrupo],
                      );
                      // }
                    }
                    Snackbar()
                        .mensaje(context, 'Conversación creada correctamente');

                    Navigator.pop(context);
                  },
                  child: const Text('Crear grupo'),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
