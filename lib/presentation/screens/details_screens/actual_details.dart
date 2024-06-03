import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_gasto.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/add_ruta.dart';
import 'package:share_plus/share_plus.dart';

import '../../functions/snackbars.dart';

class ActualDetails extends StatefulWidget {
  final int idViaje;
  final isDarkMode;

  const ActualDetails(
      {super.key, required this.idViaje, required this.isDarkMode});

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
    //print('Consultas');

    resultViaje = await conn!.query(
        'SELECT idViaje, Destino, Origen, FechaSalida, FechaLlegada, NotasViaje FROM Viaje WHERE idViaje = ${widget.idViaje}');
    resultRuta = await conn!.query(
        'SELECT IdRuta, Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje} ORDER BY Orden ASC');
    resultGastos = await conn!.query(
        'SELECT IdGasto, Descripción, Cantidad, FechaGasto FROM Gastos_del_Viaje WHERE idViaje = ${widget.idViaje}');

    //print(resultViaje);
    //print(resultRuta);
    //print(resultGastos);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return FutureBuilder(
        future: setupConnection().then((_) => fetchData()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'DETALLES DEL VIAJE',
                  style: TextStyle(
                      fontSize: 20,
                      color: widget.isDarkMode
                          ? Colors.white
                          : const Color.fromARGB(255, 29, 29, 29)),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'DETALLES DEL VIAJE',
                  style: TextStyle(
                      fontSize: 20,
                      color: widget.isDarkMode
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 0, 0)),
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
              body: Stack(
                children: [
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Image.asset(
                        widget.isDarkMode
                            ? 'assets/images/avion_details_noche.jpg'
                            : 'assets/images/avion_details.jpg',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * 0.3,
                      );
                    },
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    maxChildSize: 0.8,
                    minChildSize: 0.8,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              !widget.isDarkMode ? Colors.white : Colors.black,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              const TabBar(
                                tabs: [
                                  Tab(text: 'Viaje'),
                                  Tab(text: 'Rutas'),
                                  Tab(text: 'Gastos'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    viaje(resultViaje),
                                    rutas(resultRuta),
                                    gastos(resultGastos),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      );
    });
  }

  Widget viaje(resultViaje) {
    final formKey = GlobalKey<FormState>();

    if (resultViaje == null || resultViaje!.isEmpty) {
      return const Column(
        children: [
          Center(
            child: Text('No hay datos del viaje'),
          ),
        ],
      );
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
                            final origenController = TextEditingController(
                              text: row['Origen'],
                            );
                            final destinoController = TextEditingController(
                              text: row['Destino'],
                            );
                            final salidaController = TextEditingController(
                              text: row['FechaSalida']
                                  .toIso8601String()
                                  .substring(0, 10),
                            );
                            final llegadaController = TextEditingController(
                              text: row['FechaLlegada']
                                  .toIso8601String()
                                  .substring(0, 10),
                            );
                            final notasController = TextEditingController(
                              text: row['NotasViaje'] ?? 'Sin notas',
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Modificar Viaje'),
                                  content: SingleChildScrollView(
                                    child: _formViaje(
                                        formKey,
                                        origenController,
                                        destinoController,
                                        salidaController,
                                        context,
                                        llegadaController,
                                        notasController),
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
                                        // Solo cerrar el diálogo si el formulario es válido
                                        if (formKey.currentState!.validate()) {
                                          // Obtén los valores de los controladores de texto
                                          String origen =
                                              origenController.text.trim();
                                          String destino =
                                              destinoController.text.trim();
                                          String salida =
                                              salidaController.text.trim();
                                          String llegada =
                                              llegadaController.text.trim();
                                          String notas =
                                              notasController.text.trim();

                                          if (notas == '') {
                                            notas = 'Sin notas';
                                          }

                                          // Crea la consulta SQL
                                          String sql =
                                              "UPDATE Viaje SET Origen = '$origen', Destino = '$destino', FechaSalida = '$salida', FechaLlegada = '$llegada', NotasViaje = '$notas' WHERE IdViaje = ${widget.idViaje}";

                                          // Ejecuta la consulta SQL
                                          // Asegúrate de reemplazar 'database' con la referencia a tu base de datos
                                          conn!.query(sql);
                                          Snackbar().mensaje(context,
                                              'Viaje modificado con éxito');
                                          setState(() {
                                            fetchData();
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      ]);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    "Mantén pulsado sobre las tarjetas para interactuar.",
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight,
                          size: 20.0), // Add your icon here
                      Text(
                        '${row['idViaje']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flight_takeoff_rounded, size: 25.0),
                          const SizedBox(width: 20),
                          Text(
                            '${row['Origen']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ],
                      ),
                      Text(
                        "${row['FechaSalida'].toIso8601String().substring(0, 10)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, size: 25.0),
                          const SizedBox(width: 20),
                          Text(
                            '${row['Destino']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ],
                      ),
                      Text(
                        "${row['FechaLlegada'].toIso8601String().substring(0, 10)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    '${row['NotasViaje']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _formViaje(
      GlobalKey<FormState> formKey,
      TextEditingController origenController,
      TextEditingController destinoController,
      TextEditingController salidaController,
      BuildContext context,
      TextEditingController llegadaController,
      TextEditingController notasController) {
    return Form(
      key: formKey,
      child: Wrap(
        children: <Widget>[
          TextFormField(
            controller: origenController,
            decoration: const InputDecoration(labelText: 'Origen'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un origen';
              }
              // Comprobar si el valor contiene números
              if (RegExp(r'[0-9]').hasMatch(value)) {
                return 'El origen no puede contener números';
              }
              // Comprobar si el valor tiene menos de 3 letras
              if (value.length < 3) {
                return 'El origen debe tener al menos 3 letras';
              }
              return null;
            },
          ),
          TextFormField(
            controller: destinoController,
            decoration: const InputDecoration(labelText: 'Destino'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un destino';
              }
              // Comprobar si el valor contiene números
              if (RegExp(r'[0-9]').hasMatch(value)) {
                return 'El destino no puede contener números';
              }
              // Comprobar si el valor tiene menos de 3 letras
              if (value.length < 3) {
                return 'El destino debe tener al menos 3 letras';
              }
              return null;
            },
          ),
          TextFormField(
            controller: salidaController,
            decoration: const InputDecoration(labelText: 'Fecha de Salida'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese una fecha de salida';
              }
              return null;
            },
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
              );
              if (picked != null) {
                salidaController.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
          TextFormField(
            controller: llegadaController,
            decoration: const InputDecoration(labelText: 'Fecha de Llegada'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese una fecha de llegada';
              }
              if (DateTime.parse(value)
                  .isBefore(DateTime.parse(salidaController.text))) {
                return 'La fecha de llegada debe ser posterior a la fecha de salida';
              }
              return null;
            },
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
              );
              if (picked != null) {
                llegadaController.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
          TextFormField(
            controller: notasController,
            decoration: const InputDecoration(labelText: 'Notas del Viaje'),
          ),
        ],
      ),
    );
  }

// Crea un widget llamado rutas
  Widget rutas(resultRuta) {
    if (resultRuta == null || resultRuta!.isEmpty) {
      return Column(
        children: [
          const Center(
            child: Text('No hay datos del viaje'),
          ),
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
              ).then((value) {
                setState(() {
                  fetchData();
                });
              });
            },
          ),
        ],
      );
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
                child: Column(children: [
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
                      ).then((value) {
                        setState(() {
                          fetchData();
                        });
                      });
                    },
                  ),
                  GestureDetector(
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
                                  '  ${row['NotasRuta']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          )))
                ]));
          },
        ),
      );
    }
  }

// Crea un widget llamado gastos
  Widget gastos(resultGastos) {
    if (resultGastos == null || resultGastos!.isEmpty) {
      return Column(
        children: [
          const Center(
            child: Text('No hay datos del viaje'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              DateTime fechaInicio = resultViaje!.first.values![2] as DateTime;
              DateTime fechaFin = resultViaje!.first.values![3] as DateTime;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGasto(
                    idViaje: widget.idViaje,
                    fechaInicio: fechaInicio,
                    fechaFin: fechaFin,
                  ),
                ),
              ).then((value) {
                setState(() {
                  fetchData();
                });
              });
            },
          ),
        ],
      );
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
                child: Column(
                  children: [
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
                        ).then((value) {
                          setState(() {
                            fetchData();
                          });
                        });
                      },
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: const Icon(Icons.money,
                              size: 40.0), // Add your icon here
                          title: Text(
                            ' ${row['Cantidad']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                '  ${row['Descripción']}',
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
                    const Divider(),
                  ],
                ));
          },
        ),
      );
    }
  }

  Widget _dialog(BuildContext context, String tipo, result) {
    final formKey = GlobalKey<FormState>();
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
                          child: Form(
                            key: formKey,
                            child: Wrap(
                              children: <Widget>[
                                TextFormField(
                                  controller: locationController,
                                  decoration: const InputDecoration(
                                      labelText: 'Ubicación'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese una ubicación';
                                    }
                                    if (value.length <= 3) {
                                      return 'La ubicación debe tener más de 3 letras';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: notesController,
                                  decoration:
                                      const InputDecoration(labelText: 'Notas'),
                                ),
                                TextFormField(
                                  controller: orderController,
                                  decoration:
                                      const InputDecoration(labelText: 'Orden'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (int.tryParse(value) == null) {
                                        return 'Por favor, ingrese un número válido o deje el campo vacío';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
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
                              if (formKey.currentState!.validate()) {
                                // Obtén los valores de los controladores de texto
                                String notasRuta = notesController.text.trim();
                                String orden = orderController.text.trim();
                                String ubicacion =
                                    locationController.text.trim();

                                if (orden == '') {
                                  orden = '0';
                                }

                                if (notasRuta == '') {
                                  notasRuta = 'Sin notas';
                                }

                                // Obtén el IdRuta
                                String idRuta = result['IdRuta'].toString();

                                // Crea la consulta SQL
                                String sql =
                                    "UPDATE Ruta SET NotasRuta = '$notasRuta', Orden = '$orden', Ubicacion = '$ubicacion' WHERE IdRuta = $idRuta";

                                // Ejecuta la consulta SQL
                                // Asegúrate de reemplazar 'database' con la referencia a tu base de datos
                                conn!.query(sql);
                                Snackbar().mensaje(
                                    context, 'Ruta modificado con éxito');
                                Navigator.of(context).pop();
                                setState(() {
                                  fetchData();
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  )
                : // Define la clave del formulario
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Modificar $tipo'),
                        content: SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Wrap(
                              children: <Widget>[
                                TextFormField(
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                      labelText: 'Cantidad'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, introduce una cantidad';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                      labelText: 'Descripción'),
                                ),
                                TextFormField(
                                  controller: dateController,
                                  decoration:
                                      const InputDecoration(labelText: 'Fecha'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, introduce una fecha';
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      dateController.text = picked
                                          .toIso8601String()
                                          .substring(0, 10);
                                    }
                                  },
                                ),
                              ],
                            ),
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
                              if (formKey.currentState!.validate()) {
                                // Obtén los valores de los controladores de texto
                                String cantidad = amountController.text.trim();
                                String descripcion =
                                    descriptionController.text.trim();
                                String fecha = dateController.text.trim();

                                if (fecha == '') {
                                  fecha = DateTime.now().toIso8601String();
                                }

                                if (descripcion == '') {
                                  descripcion = 'Sin descripción';
                                }

                                // Obtén el IdRuta
                                String idGasto = result['IdGasto'].toString();

                                // Crea la consulta SQL
                                String sql =
                                    "UPDATE Gastos_del_Viaje SET Cantidad = '$cantidad', Descripción = '$descripcion', FechaGasto = '$fecha' WHERE IdGasto = $idGasto";

                                // Ejecuta la consulta SQL
                                // Asegúrate de reemplazar 'database' con la referencia a tu base de datos
                                conn!.query(sql);
                                Snackbar().mensaje(
                                    context, 'Gasto modificado con éxito');
                                setState(() {
                                  fetchData();
                                });

                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
          },
        ),
        TextButton(
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
            tipo.compareTo('ruta') == 0
                ? Snackbar().mensaje(context, 'Ruta eliminada correctamente')
                : Snackbar().mensaje(context, 'Gasto eliminado correctamente');
            setState(() {
              fetchData();
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void shareData(row) {
    String deepLink = "tripPlanner://viaje/${widget.idViaje}";

    // Comparte el enlace
    Share.share('Mira este viaje en mi aplicación: $deepLink');
  }
}
