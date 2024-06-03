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
    groupedData.clear();
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
      //print("Correo es nulo");
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
      final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

      return Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.black, Colors.white],
            ),
            image: DecorationImage(
              image: !isDarkMode
                  ? const AssetImage('assets/images/avion.jpg')
                  : const AssetImage('assets/images/avion_noche.jpg'),
              opacity: !isDarkMode ? 0.4 : 1, // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            !hayDatos
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: !isDarkMode
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.card_travel,
                              size: 80,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color.fromARGB(255, 0, 0, 0),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'No tienes viajes programados a futuro.',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 0, 0, 0),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Text(
                                'Puedes programar uno en la sección "Nuevo" o actualizar la pantalla si has creado uno.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 6, 6, 6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
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
                                    child: Text(
                                      'Actualizar viajes...',
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 0),
            hayDatos
                ? Expanded(
                    child: ListView.builder(
                      itemCount: groupedData.length,
                      itemBuilder: (context, index) {
                        final month = groupedData.keys.elementAt(index);
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                month,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            ...groupedData[month]!.map((viaje) {
                              return GestureDetector(
                                onTap: () {
                                  //print(viaje['idViaje']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ActualDetails(
                                        isDarkMode: isDarkMode,
                                        idViaje: viaje['idViaje'],
                                      ),
                                    ),
                                  ).then((_) {
                                    //print("Después del then");
                                    Future.delayed(Duration.zero, () {
                                      setState(() {
                                        fetchData();
                                      });
                                    });
                                  });
                                },
                                child: ActualTravelCard(
                                  origen: viaje['origen'],
                                  destino: viaje['destino'],
                                  fechaSalida: viaje['fechaSalida'],
                                  fechaLlegada: viaje['fechaLlegada'],
                                  gastos: viaje['gastos'] ??
                                      0.0, // Change this line
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
        ),
      ]);
    });
  }
}
