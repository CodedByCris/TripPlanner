import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_gasto.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_ruta.dart';
import 'package:share_plus/share_plus.dart';

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
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    shareData();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Presiona sobre las tarjetas para interactuar.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                          DateTime fechaInicio =
                              resultViaje!.first.values![2] as DateTime;
                          DateTime fechaFin =
                              resultViaje!.first.values![3] as DateTime;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddGasto(
                                idViaje: widget.idViaje,
                                fechaInicio: fechaInicio,
                                fechaFin: fechaFin,
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

  Widget viaje(resultViaje) {
    if (resultViaje == null || resultViaje!.isEmpty) {
      return const Text('No hay datos del viaje');
    } else {
      List<ResultRow> rows = resultViaje!.toList();
      return ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          ResultRow row = rows[index];
          return GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('¿Qué quieres hacer?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Modificar'),
                        onPressed: () {
                          // Aquí va el código para modificar el viaje
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: const Icon(Icons.flight,
                        size: 40.0), // Add your icon here
                    title: Text(
                      '${row['Origen']} - ${row['Destino']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          '${row['FechaSalida'].toIso8601String().substring(0, 10)} - ${row['FechaLlegada'].toIso8601String().substring(0, 10)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${row['NotasViaje']}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

// Crea un widget llamado rutas
  Widget rutas(resultRuta) {
    if (resultRuta == null || resultRuta!.isEmpty) {
      return const Text('No hay datos de las rutas');
    } else {
      List<ResultRow> rows = resultRuta!.toList();
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: rows.length,
          itemBuilder: (context, index) {
            ResultRow row = rows[index];
            return GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _dialog(context);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      leading: const Icon(Icons.map, size: 40.0),
                      title: Text(
                        '${row['Ubicacion']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Notas: ${row['NotasRuta']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

// Crea un widget llamado gastos
  Widget gastos(resultGastos) {
    if (resultGastos == null || resultGastos!.isEmpty) {
      return const Text('No hay datos de los gastos');
    } else {
      List<ResultRow> rows = resultGastos!.toList();
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: rows.length,
          itemBuilder: (context, index) {
            ResultRow row = rows[index];
            return GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _dialog(context);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      leading: const Icon(Icons.money,
                          size: 40.0), // Add your icon here
                      title: Text(
                        'Importe: ${row['Cantidad']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Notas: ${row['Descripción']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Fecha: ${row['FechaGasto'].toIso8601String().substring(0, 10)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _dialog(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Qué quieres hacer?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Modificar'),
          onPressed: () {
            // Aquí va el código para modificar la ruta
          },
        ),
        TextButton(
          child: const Text('Eliminar'),
          onPressed: () {
            // Aquí va el código para eliminar la ruta
          },
        ),
      ],
    );
  }

  void shareData() {
    String data = "";

    // Añade los datos del viaje
    if (resultViaje != null && resultViaje!.isNotEmpty) {
      data += "\nDatos del viaje:\n";
      for (var row in resultViaje!) {
        data += "\n${row['Origen']} - ${row['Destino']}\n";
        data +=
            "${row['FechaSalida'].toIso8601String().substring(0, 10)} - ${row['FechaLlegada'].toIso8601String().substring(0, 10)}\n";
        data += "${row['NotasViaje']}\n";
      }
      data += "\n";
    }

    // Añade los datos de las rutas
    if (resultRuta != null && resultRuta!.isNotEmpty) {
      data += "\nRutas:\n";
      for (var row in resultRuta!) {
        data += "\n${row['Ubicacion']}\n";
        data += "Notas: ${row['NotasRuta']}\n";
      }
      data += "\n";
    }

    // Añade los datos de los gastos
    if (resultGastos != null && resultGastos!.isNotEmpty) {
      data += "\nGastos:\n";
      for (var row in resultGastos!) {
        data += "\nImporte: ${row['Cantidad']}\n";
        data += "Notas: ${row['Descripción']}\n";
        data +=
            "Fecha: ${row['FechaGasto'].toIso8601String().substring(0, 10)}\n";
      }
      data += "\n";
    }

    // Comparte los datos
    Share.share(data);
  }
}
