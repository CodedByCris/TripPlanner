import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
    final db = Mysql();
    final result = await db.getConnection().then((value) => value.query(
        'SELECT * FROM Viaje INNER JOIN Usuario ON Viaje.idUsuario = Usuario.idUsuario WHERE Usuario.Correo = "$correo"'));

    for (final row in result) {
      setState(() {
        origen = row[1];
        destino = row[2];
        fechaSalida = row[3];
        fechaLlegada = row[4];
      });
    }
    correo = await getCorreo();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Tab(
            child: ActualTravelCard(
          origen: origen,
          destino: destino,
          fechaSalida: fechaSalida,
          fechaLlegada: fechaLlegada,
        )),
        const Tab(
          child: ComparadorWidget(),
        ),
      ],
    );
  }
}
