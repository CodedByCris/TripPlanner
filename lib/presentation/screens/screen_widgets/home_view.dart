import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../functions/connections.dart';
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
        Tab(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Quieres saber cuánto vas a gastar en tu próximo viaje qué actividades realizar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Utiliza nuestro Comparador de viajes',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ORIGEN',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'DESTINO',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PRECIO MIN',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'PRECIO MAX',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FECHA SALIDA',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'FECHA ENTRADA',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.search_outlined),
                  label: const Text("Buscar"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
