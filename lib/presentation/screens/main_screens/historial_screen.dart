import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';

import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

bool hayDatos = false;

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  //*Variables de la búsqueda de datos

  final db = Mysql();

  List<String> origen = [];
  List<String> destino = [];
  List<double> precioMin = [];
  List<double> precioMax = [];
  List<DateTime> fechaSalida = [];
  List<DateTime> fechaLlegada = [];

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
      MySqlConnection conn = await db.getConnection();

      final result = await conn.query(
          'SELECT origen, destino, fechaSalida, fechaLlegada FROM Viaje WHERE Correo = "$correo"');

      db.closeConnection(conn);

      if (result.isEmpty) {
        setState(() {
          hayDatos = false;
        });
      } else {
        setState(() {
          hayDatos = true;
        });
      }
      for (final row in result) {
        DateTime fechaSalidaRow = row[2];
        DateTime fechaLlegadaRow = row[3];

        origen.add(row[0]);
        destino.add(row[1]);
        fechaSalida.add(fechaSalidaRow);
        fechaLlegada.add(fechaLlegadaRow);
      }
    } else {
      print("Correo es nulo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final db = Mysql();
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
            body: Column(
              children: [
                hayDatos
                    ? const Text(
                        'Pulsa para ver todos los datos del viaje',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 9, 61, 104),
                        ),
                      )
                    : const Text(
                        'No tienes viajes en tu historial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 9, 61, 104),
                        ),
                      ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/historial_details'),
                    child: ListView.builder(
                      itemCount: origen.length,
                      itemBuilder: (context, index) {
                        return ActualTravelCard(
                          origen: origen[index],
                          destino: destino[index],
                          fechaSalida: fechaSalida[index],
                          fechaLlegada: fechaLlegada[index],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
