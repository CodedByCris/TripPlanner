import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';

import '../../../conf/connectivity.dart';
import '../../functions/alerts.dart';
import '../../Database/connections.dart';
import '../../widgets/widgets.dart';

class NewScreen extends ConsumerStatefulWidget {
  const NewScreen({super.key});

  @override
  NewScreenState createState() => NewScreenState();
}

class NewScreenState extends ConsumerState<NewScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController origenController;
  late final TextEditingController destinoController;
  late final TextEditingController fechaOrigenController;
  late final TextEditingController fechaLlegadaController;
  late final TextEditingController precioBilletesController;
  late final TextEditingController notasController;

  @override
  void initState() {
    super.initState();
    origenController = TextEditingController();
    destinoController = TextEditingController();
    fechaOrigenController = TextEditingController();
    fechaLlegadaController = TextEditingController();
    precioBilletesController = TextEditingController();
    notasController = TextEditingController();
  }

  @override
  void dispose() {
    origenController.dispose();
    destinoController.dispose();
    fechaOrigenController.dispose();
    fechaLlegadaController.dispose();
    precioBilletesController.dispose();
    notasController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Mysql();
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: customAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            ref: ref,
            titulo: 'NUEVO VIAJE',
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Los campos * son obligatorios',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              //!ORIGEN
              TextFormField(
                controller: origenController,
                decoration: const InputDecoration(
                  labelText: '* Origen',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Por favor ingrese un origen válido';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 10.0,
              ),

              //!Destino
              TextFormField(
                controller: destinoController,
                decoration: const InputDecoration(
                  labelText: '* Destino',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Por favor ingrese un destino válido';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 10.0,
              ),

              Row(
                children: [
                  //!Fecha de origen
                  Expanded(
                    child: TextFormField(
                      controller: fechaOrigenController,
                      decoration: const InputDecoration(
                        labelText: '* Fecha salida',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); // to prevent opening default keyboard
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          fechaOrigenController.text =
                              date.toIso8601String().substring(0, 10);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una fecha de salida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  //! Fecha de llegada
                  Expanded(
                    child: TextFormField(
                      controller: fechaLlegadaController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha llegada',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); // to prevent opening default keyboard
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          fechaLlegadaController.text =
                              date.toIso8601String().substring(0, 10);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        DateTime fechaSalida =
                            DateTime.parse(fechaOrigenController.text);
                        DateTime fechaLlegada = DateTime.parse(value);

                        if (fechaLlegada.isBefore(fechaSalida) &&
                            value.isNotEmpty) {
                          return 'La fecha de llegada debe ser posterior a la fecha de salida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              //! Precio de los billetes
              TextFormField(
                controller: precioBilletesController,
                decoration: const InputDecoration(
                  labelText: 'Precio de los billetes (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                // validator: (value) {
                //   if (value!.isNotEmpty) {
                //     double.parse(value) < 0;
                //     return 'Por favor ingrese un precio válido';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(
                height: 10.0,
              ),

              //!Notas del viaje
              TextFormField(
                controller: notasController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Notas del viaje (opcional)',
                  prefixIcon: Icon(Icons.comment),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.length < 3 && value.isNotEmpty) {
                    return 'Por favor ingrese una nota válida';
                  }
                  return null;
                },
              ),

              //! Botón para guardar los datos
              ElevatedButton(
                child: const Text('Crear viaje'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Guarda los datos
                    String? origen = origenController.text;
                    String? destino = destinoController.text;
                    String? fechaSalida = fechaOrigenController.text;
                    String? fechaLlegada = fechaLlegadaController.text;
                    String? precioBilletes = precioBilletesController.text;
                    String? notas = notasController.text;
                    // Aquí puedes guardar los datos en la base de datos o en cualquier otro lugar

                    // Clear the text fields
                    origenController.clear();
                    destinoController.clear();
                    fechaOrigenController.clear();
                    fechaLlegadaController.clear();
                    precioBilletesController.clear();
                    notasController.clear();

                    //! Insertar los datos en la base de datos

                    //Mounted comprueba si el widget sigue en la pantalla
                    if (mounted)
                    // Show a dialog
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Viaje creado'),
                            content: const Text(
                                'El viaje ha sido creado exitosamente, puedes modificar sus datos en la ventana "Home".'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Aceptar'),
                                //INSERT
                                onPressed: () async {
                                  //Comprobaciones
                                  if (notas!.isEmpty) {
                                    notas = 'Sin notas';
                                  }
                                  if (fechaLlegada!.isEmpty) {
                                    fechaLlegada = DateTime.now()
                                        .toIso8601String()
                                        .substring(0, 10);
                                  }
                                  String sql =

                                      //INSERTO LOS DATOS DEL VIAJE
                                      'INSERT INTO Viaje(Origen, Destino, FechaSalida, FechaLlegada, NotasViaje, Correo) VALUES (?, ?, ?, ?, ?, ?)';
                                  await db.getConnection().then((conn) async {
                                    String? correo = await Mysql().getCorreo();
                                    await conn.query(sql, [
                                      origen,
                                      destino,
                                      fechaSalida,
                                      fechaLlegada,
                                      notas,
                                      correo
                                    ]);

                                    if (precioBilletes.isNotEmpty) {
                                      //OBTENGO EL ID DEL VIAJE
                                      sql =
                                          "Select IdViaje from Viaje where Origen = '$origen' and Destino = '$destino' and FechaSalida = '$fechaSalida' and FechaLlegada = '$fechaLlegada' and NotasViaje = '$notas' and Correo = '$correo'";

                                      Results result = await conn.query(sql);
                                      int idViaje = result
                                          .elementAt(result.length - 1)[0];

                                      //INSERTO LOS DATOS DEL PRECIO
                                      String sqlPrecio =
                                          'INSERT INTO Gastos_del_Viaje(Descripción, Cantidad, FechaGasto, IdViaje) VALUES (?, ?, ?, ?)';
                                      await conn.query(sqlPrecio, [
                                        "Gastos en los billetes",
                                        precioBilletes,
                                        DateTime.now()
                                            .toIso8601String()
                                            .substring(0, 10),
                                        idViaje
                                      ]);
                                    }

                                    Alerts().registerSuccessfully(context);
                                    await conn.close();
                                  });
                                  Navigator.of(context).pop();
                                  GoRouter.of(context).go('/home/0');
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
