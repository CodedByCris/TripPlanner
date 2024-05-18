import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';

class AddRuta extends ConsumerStatefulWidget {
  final int idViaje;
  const AddRuta({super.key, required this.idViaje});

  @override
  NewScreenState createState() => NewScreenState();
}

class NewScreenState extends ConsumerState<AddRuta> {
  DatabaseHelper db = DatabaseHelper();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController ubicacionController = TextEditingController();
  TextEditingController notasController = TextEditingController();
  TextEditingController ordenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    formKey = GlobalKey<FormState>();
    ubicacionController = TextEditingController();
    notasController = TextEditingController();
    ordenController = TextEditingController();
  }

  @override
  void dispose() {
    ubicacionController.dispose();
    notasController.dispose();
    ordenController.dispose();
    super.dispose(); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVA RUTA'),
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
            _ubicacion(colors),
            const SizedBox(
              height: 20.0,
            ),
            _notas(colors),
            const SizedBox(
              height: 20.0,
            ),
            _orden(colors),
            const SizedBox(
              height: 20.0,
            ),
            _btnGuardar(ref, colors, context, db),
          ],
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
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          // Guarda los datos
          String? ubicacion = ubicacionController.text.toUpperCase().trim();
          String? notas = notasController.text.trim();
          String? orden = ordenController.text.trim();

          // Clear the text fields
          ubicacionController.clear();
          notasController.clear();
          ordenController.clear();

          //Comprobaciones
          if (notas.isEmpty) {
            notas = 'Sin notas';
          }
          if (orden.isEmpty) {
            orden = '0';
          }
          String sql =
              'INSERT INTO Ruta(Ubicacion, NotasRuta, Orden, IdViaje) VALUES (?, ?, ?, ?)';
          await db.getConnection().then((conn) async {
            await conn.query(sql, [ubicacion, notas, orden, widget.idViaje]);
          });

          // Muestra un dialogo
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Ruta añadida correctamente'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _ubicacion(ColorScheme colors) {
    return TextFormField(
      controller: ubicacionController,
      decoration: InputDecoration(
        labelText: '* Ubicación (Torre Eiffel, Atocha, etc)',
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

  Widget _notas(ColorScheme colors) {
    return TextFormField(
      controller: notasController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Notas del viaje',
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

  Widget _orden(ColorScheme colors) {
    return TextFormField(
      controller: ordenController,
      keyboardType:
          TextInputType.number, // Cambia el tipo de teclado a numérico
      decoration: InputDecoration(
        labelText: 'Orden (1, 2, 3, etc)',
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
