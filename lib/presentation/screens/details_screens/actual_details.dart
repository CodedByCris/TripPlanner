import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_gasto.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_ruta.dart';

import 'detalles.dart';

class ActualDetails extends StatefulWidget {
  final int idViaje;

  const ActualDetails({super.key, required this.idViaje});

  @override
  State<ActualDetails> createState() => _ActualDetailsState();
}

class _ActualDetailsState extends State<ActualDetails> {
  DatabaseHelper bd = DatabaseHelper();
  Results? resultViaje;
  Results? resultRuta;
  Results? resultGastos;
  MySqlConnection? conn;

  @override
  void initState() {
    super.initState();
    setupConnection().then((_) {
      fetchData();
    }); // Llama a la función fetchData
  }

  Future<void> setupConnection() async {
    conn = await bd.getConnection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Crea una nueva función fetchData
  Future<void> fetchData() async {
    print('Consultas');

    resultViaje = await conn!.query(
        'SELECT Destino, Origen, FechaSalida, FechaLlegada, NotasViaje FROM Viaje WHERE idViaje = ${widget.idViaje}');
    resultRuta = await conn!.query(
        'SELECT Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje} ORDER BY Orden DESC');
    resultGastos = await conn!.query(
        'SELECT Descripción, Cantidad, FechaGasto FROM Gastos_del_Viaje WHERE idViaje = ${widget.idViaje}');

    print(resultViaje);
    print(resultRuta);
    print(resultGastos);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setupConnection().then((_) => fetchData()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('DETALLES DEL VIAJE'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('DETALLES DEL VIAJE'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  const Text('Datos del viaje:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  viaje(resultViaje),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rutas:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddRuta(
                                idViaje: widget.idViaje,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  rutas(resultRuta),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gastos:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddGasto(
                                idViaje: widget.idViaje,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  gastos(resultGastos),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
