import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../Database/connections.dart';

class AddGasto extends ConsumerStatefulWidget {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int idViaje;
  const AddGasto(
      {super.key,
      required this.idViaje,
      required this.fechaInicio,
      required this.fechaFin});

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
    print(widget.fechaInicio);
    print(widget.fechaFin);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
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
    );
  }

  Widget _btnGuardar(WidgetRef ref, ColorScheme colors, BuildContext context,
      DatabaseHelper db) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
      ),
      child: const Text(
        'Añadir Gasto',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          // Guarda los datos
          String? cantidad = cantidadController.text.toUpperCase().trim();
          String? descr = descripcionController.text.trim();
          String? fecha = fechaController.text.trim();

          // Clear the text fields
          cantidadController.clear();
          descripcionController.clear();
          fechaController.clear();

          //Comprobaciones
          if (descr.isEmpty) {
            descr = 'Sin descripción';
          }
          if (fecha.isEmpty) {
            fecha = DateTime.now().toString();
          }

          String sql =
              'INSERT INTO Gastos_del_Viaje(Cantidad, Descripción, FechaGasto, IdViaje) VALUES (?, ?, ?, ?)';
          await db.getConnection().then((conn) async {
            await conn.query(sql, [cantidad, descr, fecha, widget.idViaje]);
          });

          // Muestra un dialogo
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Gasto añadido correctamente'),
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

  Widget _cantidad(ColorScheme colors) {
    return TextFormField(
      controller: cantidadController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '* Cantidad',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.attach_money_outlined,
          color: colors.primary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una cantidad';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Por favor ingrese una cantidad válida mayor a 0';
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

  Widget _fechaGasto(ColorScheme colors) {
    return TextFormField(
      controller: fechaController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha del gasto',
        border: const OutlineInputBorder(),
        prefixIcon: IconButton(
          icon: Icon(
            Icons.date_range,
            color: colors.primary,
          ),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: widget.fechaInicio,
              firstDate: widget.fechaInicio,
              lastDate: widget.fechaFin,
            );
            if (picked != null) {
              fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty) {
          DateTime? fecha = DateFormat('yyyy-MM-dd').parse(value, true);
          if (fecha.isBefore(widget.fechaInicio) ||
              fecha.isAfter(widget.fechaFin)) {
            return 'Por favor ingrese una fecha entre ${DateFormat('yyyy-MM-dd').format(widget.fechaInicio)} y ${DateFormat('yyyy-MM-dd').format(widget.fechaFin)}';
          }
        }
        return null;
      },
    );
  }
}
