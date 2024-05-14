import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';

class AddGasto extends ConsumerStatefulWidget {
  final int idViaje;
  const AddGasto({super.key, required this.idViaje});

  @override
  NewScreenState createState() => NewScreenState();
}

class NewScreenState extends ConsumerState<AddGasto> {
  DatabaseHelper db = DatabaseHelper();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    formKey = GlobalKey<FormState>();
    cantidadController = TextEditingController();
    descripcionController = TextEditingController();
    fechaController = TextEditingController();
  }

  @override
  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
    fechaController.dispose();
    super.dispose(); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NUEVOS GASTOS'),
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
              _cantidad(colors),
              const SizedBox(
                height: 20.0,
              ),
              _descripcion(colors),
              const SizedBox(
                height: 20.0,
              ),
              _fechaGasto(colors),
              const SizedBox(
                height: 20.0,
              ),
              _btnGuardar(ref, colors, context, db),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnGuardar(WidgetRef ref, ColorScheme colors, BuildContext context,
      DatabaseHelper db) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
      ),
      child: const Text(
        'Añadir Ruta',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          // Guarda los datos
          String? cantidad = cantidadController.text.toUpperCase();
          String? descr = descripcionController.text;
          String? fecha = fechaController.text;

          // Clear the text fields
          cantidadController.clear();
          descripcionController.clear();
          fechaController.clear();

          //! Insertar los datos en la base de datos
          //Mounted comprueba si el widget sigue en la pantalla
          if (mounted)
          // Show a dialog
          {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Ruta creado'),
                  content: const Text(
                      'El gasto ha sido creada correctamente, ¿desea añadir otro gasto?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Salir'),
                      //INSERT
                      onPressed: () async {
                        //Comprobaciones
                        if (descr!.isEmpty) {
                          descr = 'Sin descripción';
                        }
                        if (fecha!.isEmpty) {
                          fecha = DateTime.now().toString();
                        }
                        String sql =

                            //INSERTO LOS DATOS DEL VIAJE
                            'INSERT INTO Ruta(Ubicacion, NotasRuta, Orden, IdViaje) VALUES (?, ?, ?, ?)';
                        await db.getConnection().then((conn) async {
                          await conn.query(
                              sql, [cantidad, descr, fecha, widget.idViaje]);
                        });
                        Navigator.of(context).pop();
                        GoRouter.of(context).go(
                            '/home/0'); //TODO: CAMBIAR POR LA CARD DEL VIAJE ACTUAL
                      },
                    ),
                    TextButton(
                      child: const Text('Aceptar'),
                      //INSERT
                      onPressed: () async {
                        //Comprobaciones
                        if (descr!.isEmpty) {
                          descr = 'Sin descripción';
                        }
                        if (fecha!.isEmpty) {
                          fecha = DateTime.now().toString();
                        }
                        String sql =

                            //INSERTO LOS DATOS DEL VIAJE
                            'INSERT INTO Gastos_del_Viaje(Cantidad, Descripción, FechaGasto, IdViaje) VALUES (?, ?, ?, ?)';
                        await db.getConnection().then((conn) async {
                          await conn.query(
                              sql, [cantidad, descr, fecha, widget.idViaje]);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _cantidad(ColorScheme colors) {
    return TextFormField(
      controller: cantidadController,
      decoration: InputDecoration(
        labelText: '* Cantidad',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.location_on,
          color: colors.primary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 3) {
          return 'Por favor ingrese una ubicación válida';
        }
        return null;
      },
    );
  }

  Widget _descripcion(ColorScheme colors) {
    return TextFormField(
      controller: descripcionController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Descripción',
        prefixIcon: Icon(
          Icons.comment,
          color: colors.primary,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.length < 3 && value.isNotEmpty) {
          return 'Por favor más de 3 caracteres';
        }
        return null;
      },
    );
  }

//TODO: CAMBIAR A TIPO FECHA
//TODO: TIENE QUE SER >= AL INICIO DEL VIAJE Y <= AL FINAL DEL VIAJE
  Widget _fechaGasto(ColorScheme colors) {
    return TextFormField(
      controller: fechaController,
      keyboardType:
          TextInputType.number, // Cambia el tipo de teclado a numérico
      decoration: InputDecoration(
        labelText: 'Fecha del gasto',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.numbers,
          color: colors.primary,
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty) {
          int? number = int.tryParse(value);
          if (number == null || number <= 0) {
            return 'Por favor ingrese un número mayor a 0';
          }
        }
        return null;
      },
    );
  }
}
