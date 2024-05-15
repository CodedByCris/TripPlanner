import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../providers/theme_provider.dart';

bool hayDatosss = false;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final db = DatabaseHelper();
  Map<String, List<ResultRow>> groupedData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading =
          true; // Establecer isLoading en true antes de cargar los datos
    });
    String? correoTemp = await DatabaseHelper().getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      MySqlConnection conn = await db.getConnection();

      // Consulta a la tabla Usuario_GrupoViaje
      final result = await conn.query(
          'SELECT IdGrupo FROM Usuario_GrupoViaje WHERE Correo = ?', [correo]);

      if (result.isEmpty) {
        setState(() {
          hayDatosss = false;
        });
      } else {
        setState(() {
          hayDatosss = true;
        });

        // Realizar una segunda consulta a la tabla Grupos de Viaje
        for (var row in result) {
          final grupoResult = await conn.query(
              'SELECT Descripcion, FechaCreacion, NombreGrupo, TipoGrupo FROM Grupos de Viaje WHERE IdGrupo = ?',
              [row['IdGrupo']]);

          // Aquí puedes procesar los resultados de la consulta a Grupos de Viaje
          // Por ejemplo, podrías agregarlos a una lista o a un mapa
        }
      }
    } else {
      print("Correo es nulo");
    }
    setState(() {
      isLoading =
          false; // Establecer isLoading en false después de cargar los datos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = Theme.of(context).colorScheme;
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Mensajes',
              style: TextStyle(
                color: isDarkMode ? colors.secondary : colors.primary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          body: hayDatosss
              ? Expanded(
                  child: ListView.builder(
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      return null;
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    'No tienes conversaciones activas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 9, 61, 104),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
