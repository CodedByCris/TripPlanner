import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';

class ActualDetails extends StatefulWidget {
  final int idViaje;
  const ActualDetails({super.key, required this.idViaje});

  @override
  State<ActualDetails> createState() => _ActualDetailsState();
}

class _ActualDetailsState extends State<ActualDetails> {
  Results? resultViaje;
  Results? resultRuta;
  Results? resultGastos;
  Mysql mysql = Mysql();
  MySqlConnection? conn;

  @override
  void initState() {
    super.initState();
    setupConnection().then((_) {
      fetchData();
    }); // Llama a la función fetchData
  }

  Future<void> setupConnection() async {
    conn = await mysql.getConnection();
  }

  @override
  void dispose() {
    mysql.closeConnection(conn!);
    super.dispose();
  }

  // Crea una nueva función fetchData
  Future<void> fetchData() async {
    print('Consultas');

    resultViaje = await conn!.query(
        'SELECT Destino, Origen, FechaSalida, FechaLlegada, NotasViaje FROM Viaje WHERE idViaje = ${widget.idViaje}');
    resultRuta = await conn!.query(
        'SELECT Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje}');
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
              title: const Text('VIAJE ACTUAL'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('VIAJE ACTUAL'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  const Text('Datos del viaje:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  viaje(),
                  const Divider(),
                  const Text('Rutas:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  rutas(),
                  const Divider(),
                  const Text('Gastos:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  gastos(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

// Crea un widget llamado viaje
  Widget viaje() {
    if (resultViaje == null || resultViaje!.isEmpty) {
      return const Text('No hay datos de los gastos');
    } else {
      List<ResultRow> rows = resultViaje!.toList();
      return ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          ResultRow row = rows[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${row['Origen']} - ${row['Destino']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    'Origen: ${row['FechaSalida'].toIso8601String().substring(0, 10)}, Destino: ${row['FechaLlegada'].toIso8601String().substring(0, 10)}'),
                Text('Notas: ${row['NotasViaje']}'),
              ],
            ),
          );
        },
      );
    }
  }

// Crea un widget llamado rutas
  Widget rutas() {
    if (resultRuta == null || resultRuta!.isEmpty) {
      return const Text('No hay datos de los gastos');
    } else {
      List<ResultRow> rows = resultRuta!.toList();
      return ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          ResultRow row = rows[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('${row['Ubicacion']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Text('Notas: ${row['NotasRuta']}'),
              ],
            ),
          );
        },
      );
    }
  }

// Crea un widget llamado gastos
  Widget gastos() {
    if (resultGastos == null || resultGastos!.isEmpty) {
      return const Text('No hay datos de los gastos');
    } else {
      List<ResultRow> rows = resultGastos!.toList();
      return ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          ResultRow row = rows[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                  '${row['Descripción']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 10),
                Text('Cantidad: ${row['Cantidad']}'),
                row['FechaGasto'] == null
                    ? const Text('Fecha: No hay fecha')
                    : Text('Fecha: ${row['FechaGasto']}'),
              ],
            ),
          );
        },
      );
    }
  }
}
