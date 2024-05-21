import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/screens/details_screens/actual_details.dart';

import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';
import 'package:trip_planner/presentation/widgets/travel_cards/actual_travel_card.dart';

import '../../Database/connections.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mysql1/mysql1.dart';

bool hayDatos = false;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  //Variables de la búsqueda de datos
  bool isLoading = false;
  DatabaseHelper db = DatabaseHelper();
  Map<String, List<Map<String, dynamic>>> groupedData = {};

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
      final db = DatabaseHelper();
      var conn = await db.getConnection();

      final result = await conn.query('''
          SELECT Viaje.Origen, Viaje.Destino, Viaje.FechaSalida, Viaje.FechaLlegada, Viaje.IdViaje, 
          SUM(Gastos_del_Viaje.cantidad) as TotalGastos, (SELECT COUNT(*) FROM Ruta 
          WHERE Ruta.IdViaje = Viaje.IdViaje) as NumRutas FROM Viaje 
          LEFT JOIN Gastos_del_Viaje ON Viaje.IdViaje = Gastos_del_Viaje.IdViaje 
          WHERE Viaje.Correo = "$correo" AND Viaje.FechaLlegada >= CURDATE() 
          GROUP BY Viaje.IdViaje ORDER BY Viaje.FechaSalida ASC
          ''');
      DateTime now = DateTime.now();
      if (result.isEmpty) {
        setState(() {
          hayDatos = false;
        });
      } else {
        setState(() {
          hayDatos = true;
        });
      }
      final groupedResults = await groupDataByMonth(result);
      for (final month in groupedResults.keys) {
        for (final row in groupedResults[month]!) {
          DateTime fechaSalidaRow = row['FechaSalida'];
          DateTime fechaLlegadaRow = row['FechaLlegada'];

          if ((now.isAfter(fechaSalidaRow) && now.isBefore(fechaLlegadaRow)) ||
              now.isBefore(fechaSalidaRow)) {
            setState(() {
              if (!groupedData.containsKey(month)) {
                groupedData[month] = [];
              }
              groupedData[month]!.add({
                'origen': row['Origen'],
                'destino': row['Destino'],
                'fechaSalida': fechaSalidaRow,
                'fechaLlegada': fechaLlegadaRow,
                'idViaje': row['IdViaje'],
                'gastos': row['TotalGastos'], // Add this line
                'numRutas': row['NumRutas'], // Add this line
              });
            });
          }
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

  Future<Map<String, List<ResultRow>>> groupDataByMonth(Results results) async {
    await initializeDateFormatting('es_ES', null);
    final Map<String, List<ResultRow>> map = {};
    for (var row in results) {
      final date = row['FechaSalida'] as DateTime;
      final month = DateFormat('MMMM', 'es_ES').format(date).toUpperCase();
      if (map[month] == null) {
        map[month] = [];
      }
      map[month]!.add(row);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final colors = Theme.of(context).colorScheme;
      final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

      return Column(
        children: [
          const SizedBox(height: 20),
          !hayDatos
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No tienes viajes programados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? colors.secondary
                              : const Color.fromARGB(255, 9, 61, 104),
                        ),
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true; // Comienza la carga
                                });
                                fetchData().then((_) {
                                  setState(() {
                                    isLoading = false; // Termina la carga
                                  });
                                });
                              },
                              child: const Text('Buscar viajes...'),
                            ),
                    ],
                  ),
                )
              : Text(
                  'Pulsa para ver todos los datos del viaje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? colors.secondary
                        : const Color.fromARGB(255, 9, 61, 104),
                  ),
                ),
          const SizedBox(height: 20),
          hayDatos
              ? Expanded(
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...groupedData[month]!.map((viaje) {
                            print("Numero de rutas -> ${viaje['numRutas']}");
                            return GestureDetector(
                              onTap: () {
                                print(viaje['idViaje']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActualDetails(
                                      idViaje: viaje['idViaje'],
                                    ),
                                  ),
                                );
                              },
                              child: ActualTravelCard(
                                origen: viaje['origen'],
                                destino: viaje['destino'],
                                fechaSalida: viaje['fechaSalida'],
                                fechaLlegada: viaje['fechaLlegada'],
                                gastos:
                                    viaje['gastos'] ?? 0.0, // Change this line
                                numRutas: viaje['numRutas'] ?? 0,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
