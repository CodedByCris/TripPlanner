import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../functions/connections.dart';
import '../../widgets/interface/comparador.dart';
import '../../widgets/widgets.dart';

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
    String? correoTemp = await getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      final db = Mysql();
      final result = await db.getConnection().then((value) => value.query(
          'SELECT origen, destino, fechaSalida, fechaLlegada FROM Viaje WHERE Correo = "$correo"'));

      for (final row in result) {
        setState(() {
          origen.add(row[0]);
          destino.add(row[1]);
          fechaSalida.add(row[2]);
          fechaLlegada.add(row[3]);
        });
      }
    } else {
      print("Correo es nulo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Pulsa para modificar los datos del viaje',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 9, 61, 104),
          ),
        ),
        Expanded(
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
      ],
    );
  }
}
