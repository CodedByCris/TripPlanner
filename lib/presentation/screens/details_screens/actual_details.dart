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
        'SELECT IdRuta, Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje} ORDER BY Orden DESC');
    resultGastos = await conn!.query(
        'SELECT IdGasto, Descripción, Cantidad, FechaGasto FROM Gastos_del_Viaje WHERE idViaje = ${widget.idViaje}');

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
              title: const Text(
                'DETALLES DEL VIAJE',
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'DETALLES DEL VIAJE',
                style: TextStyle(fontSize: 20),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    shareData(resultViaje);
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
                      "Mantén pulsado sobre las tarjetas para interactuar.",
                      textAlign: TextAlign.center,
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Modificar Viaje'),
                                content: SingleChildScrollView(
                                  child: Wrap(
                                    children: <Widget>[
                                      TextField(
                                        controller: TextEditingController(
                                            text: row['Origen']),
                                        decoration: const InputDecoration(
                                            labelText: 'Origen'),
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text: row['Destino']),
                                        decoration: const InputDecoration(
                                            labelText: 'Destino'),
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text: row['FechaSalida']
                                                .toIso8601String()
                                                .substring(0, 10)),
                                        decoration: const InputDecoration(
                                            labelText: 'Fecha de Salida'),
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text: row['FechaLlegada']
                                                .toIso8601String()
                                                .substring(0, 10)),
                                        decoration: const InputDecoration(
                                            labelText: 'Fecha de Llegada'),
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text: row['NotasViaje']),
                                        decoration: const InputDecoration(
                                            labelText: 'Notas del Viaje'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Aceptar'),
                                    onPressed: () {
                                      //TODO: UPDATE EN LA BASE DE DATOS
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
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
                    return _dialog(context, 'ruta', row);
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
                    return _dialog(context, 'gasto', row);
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

  Widget _dialog(BuildContext context, String tipo, result) {
    TextEditingController locationController =
        TextEditingController(text: result['Ubicacion']);
    TextEditingController notesController =
        TextEditingController(text: result['NotasRuta']);
    TextEditingController orderController =
        TextEditingController(text: result['Orden'].toString());
    TextEditingController amountController =
        TextEditingController(text: result['Cantidad'].toString());
    TextEditingController descriptionController =
        TextEditingController(text: result['Descripción']);
    TextEditingController dateController = TextEditingController(
        text: result['FechaGasto'].toString().split(" ")[0]);

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
            tipo.compareTo('ruta') == 0
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Modificar $tipo'),
                        content: SingleChildScrollView(
                          child: Wrap(
                            children: <Widget>[
                              TextField(
                                controller: locationController,
                                decoration: const InputDecoration(
                                    labelText: 'Ubicación'),
                              ),
                              TextField(
                                controller: notesController,
                                decoration:
                                    const InputDecoration(labelText: 'Notas'),
                              ),
                              TextField(
                                controller: orderController,
                                decoration:
                                    const InputDecoration(labelText: 'Orden'),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Aceptar'),
                            onPressed: () {
                              //TODO: UPDATE EN LA BASE DE DATOS DE RUTAS
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  )
                : showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Modificar $tipo'),
                        content: SingleChildScrollView(
                          child: Wrap(
                            children: <Widget>[
                              TextField(
                                controller: amountController,
                                decoration: const InputDecoration(
                                    labelText: 'Cantidad'),
                              ),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                    labelText: 'Descripción'),
                              ),
                              TextField(
                                controller: dateController,
                                decoration:
                                    const InputDecoration(labelText: 'Fecha'),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Aceptar'),
                            onPressed: () {
                              //TODO: UPDATE EN LA BASE DE DATOS DE GASTOS
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
          },
        ),
        TextButton(
          //TODO:FALTA QUE SE RECARGUE LA PÁGINA
          child: const Text('Eliminar'),
          onPressed: () {
            String tableName =
                tipo.compareTo('ruta') == 0 ? 'Ruta' : 'Gastos_del_Viaje';
            String idField = tipo.compareTo('ruta') == 0 ? 'IdRuta' : 'IdGasto';
            int id = tipo.compareTo('ruta') == 0
                ? result['IdRuta']
                : result['IdGasto'];

            String sql = 'DELETE FROM $tableName WHERE $idField = $id';

            conn!.query(sql);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void shareData(row) {
    // TODO: INTENTAR QUE FUNCIONE PARA ABRIR LA APP
    String deepLink = "tripPlanner://viaje/${widget.idViaje}";

    // Comparte el enlace
    Share.share('Mira este viaje en mi aplicación: $deepLink');
  }
}
