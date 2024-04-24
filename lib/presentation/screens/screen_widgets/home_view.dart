import 'package:flutter/material.dart';

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
  String origen = '';
  String destino = '';
  DateTime fechaSalida = DateTime.now();
  DateTime fechaLlegada = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
    print('HOME VIEW');
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
          print("resultados$result");
          origen = row[0];
          destino = row[1];
          fechaSalida = row[2];
          fechaLlegada = row[3];
        });
      }
    } else {
      print("Correo es nulo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        ActualTravelCard(
          origen: origen,
          destino: destino,
          fechaSalida: fechaSalida,
          fechaLlegada: fechaLlegada,
        ),
        const ComparadorWidget(),
      ],
    );
  }
}
