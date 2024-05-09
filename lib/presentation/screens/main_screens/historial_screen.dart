import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final db = Mysql();
  Map<String, List<ResultRow>> groupedData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? correoTemp = await Mysql().getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      MySqlConnection conn = await db.getConnection();

      final result = await conn.query(
          'SELECT Origen, Destino, FechaSalida, FechaLlegada, IdViaje FROM Viaje WHERE Correo = "$correo" AND FechaLlegada < CURDATE() ORDER BY FechaSalida ASC');
      db.closeConnection(conn);

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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = Theme.of(context).colorScheme;
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return NetworkSensitive(
          child: Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                ref: ref,
                titulo: 'HISTORIAL',
              ),
            ),
            body: hayDatos
                ? ListView.builder(
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
                                print(viaje['IdViaje']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActualDetails(
                                      idViaje: viaje['IdViaje'],
                                      bd: db,
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
                  )
                : const Center(
                    child: Text(
                      'No tienes viajes en tu historial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 9, 61, 104),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
