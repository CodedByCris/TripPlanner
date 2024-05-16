import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';
import '../../functions/mes_mapa.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

bool hayDatos = false;

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final db = DatabaseHelper();
  bool isLoading = false;
  Map<String, List<ResultRow>> groupedData = {};

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

      final result = await conn.query(
          'SELECT Origen, Destino, FechaSalida, FechaLlegada, IdViaje FROM Viaje WHERE Correo = "$correo" AND FechaLlegada < CURDATE() ORDER BY FechaSalida ASC');

      if (result.isEmpty) {
        setState(() {
          hayDatos = false;
        });
      } else {
        setState(() {
          hayDatos = true;
        });
        groupedData = await groupDataByMonth(result);
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

        if (correo == null) {
          return Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                titulo: 'HISTORIAL',
              ),
            ),
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Debes iniciar sesión para ver tu historial de viajes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 9, 61, 104),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).go('/login');
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                titulo: 'HISTORIAL',
              ),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hayDatos
                    ? Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Pulsa para ver todos los datos del viaje",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: groupedData.length,
                              itemBuilder: (context, index) {
                                final month = groupedData.keys.elementAt(index);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        month,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ...groupedData[month]!.map((viaje) {
                                      return GestureDetector(
                                        onTap: () {
                                          print(viaje['IdViaje']);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ActualDetails(
                                                idViaje: viaje['IdViaje'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: ActualTravelCard(
                                          origen: viaje['Origen'],
                                          destino: viaje['Destino'],
                                          fechaSalida: viaje['FechaSalida'],
                                          fechaLlegada: viaje['FechaLlegada'],
                                          gastos: 20,
                                          numRutas: 3,
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No tienes viajes en tu historial',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 9, 61, 104),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: fetchData,
                              child: const Text('Refrescar'),
                            ),
                          ],
                        ),
                      ),
          );
        }
      },
    );
  }
}
