import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/details_screens/actual_details.dart';

import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';
import 'package:trip_planner/presentation/widgets/travel_cards/actual_travel_card.dart';

import '../../Database/connections.dart';
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
  //*Variables de la búsqueda de datos

  Mysql db = Mysql();
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? correoTemp = await Mysql().getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      final db = Mysql();
      final result = await db.getConnection().then((value) => value.query(
          'SELECT Origen, Destino, FechaSalida, FechaLlegada, IdViaje FROM Viaje WHERE Correo = "$correo" ORDER BY FechaSalida ASC'));
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
              });
            });
          }
        }
      }
    } else {
      print("Correo es nulo");
    }
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
    return Column(
      children: [
        const SizedBox(height: 20),
        hayDatos
            ? const Text(
                'Pulsa para modificar los datos del viaje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 9, 61, 104),
                ),
              )
            : const Text(
                'No tienes viajes programados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 9, 61, 104),
                ),
              ),
        const SizedBox(height: 20),
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
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...groupedData[month]!.map((viaje) {
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
    );
  }
}
