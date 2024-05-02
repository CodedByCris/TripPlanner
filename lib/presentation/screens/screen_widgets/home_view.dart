import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../Database/connections.dart';
import '../../widgets/widgets.dart';

bool hayDatos = false;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
      final result = await db.getConnection().then((value) => value.query(
          'SELECT origen, destino, fechaSalida, fechaLlegada FROM Viaje WHERE Correo = "$correo"'));

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
      for (final row in result) {
        DateTime fechaSalidaRow = row[2];
        DateTime fechaLlegadaRow = row[3];

        if ((now.isAfter(fechaSalidaRow) && now.isBefore(fechaLlegadaRow)) ||
            now.isBefore(fechaSalidaRow)) {
          setState(() {
            origen.add(row[0]);
            destino.add(row[1]);
            fechaSalida.add(fechaSalidaRow);
            fechaLlegada.add(fechaLlegadaRow);
          });
        }
      }
    } else {
      print("Correo es nulo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/actual_details'),
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
    );
  }
}
