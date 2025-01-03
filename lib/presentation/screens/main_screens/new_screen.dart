// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'package:trip_planner/presentation/widgets/ubi.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';

class NewScreen extends ConsumerStatefulWidget {
  const NewScreen({super.key});

  @override
  NewScreenState createState() => NewScreenState();
}

class NewScreenState extends ConsumerState<NewScreen> {
  DatabaseHelper db = DatabaseHelper();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController origenController = TextEditingController();
  TextEditingController destinoController = TextEditingController();
  TextEditingController fechaOrigenController = TextEditingController();
  TextEditingController fechaLlegadaController = TextEditingController();
  TextEditingController precioBilletesController = TextEditingController();
  TextEditingController notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    formKey = GlobalKey<FormState>();
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
    super.dispose(); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    final correo = ref.watch(tokenProvider);

    if (correo == null) {
      return Scaffold(
        appBar: AppBar(
          title: CustomAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            titulo: 'NUEVO VIAJE',
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black, Colors.white],
                ),
                image: DecorationImage(
                  image: !isDarkMode
                      ? const AssetImage('assets/images/avion.jpg')
                      : const AssetImage('assets/images/avion_noche.jpg'),
                  opacity: !isDarkMode ? 0.4 : 1, // Replace with your image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Debes iniciar sesión para crear un viaje',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            isDarkMode ? Colors.white : Colors.black),
                      ),
                      onPressed: () {
                        GoRouter.of(context).go('/login');
                      },
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: !isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: CustomAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            titulo: 'NUEVO VIAJE',
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black, Colors.white],
                ),
                image: DecorationImage(
                  image: !isDarkMode
                      ? const AssetImage('assets/images/avion.jpg')
                      : const AssetImage('assets/images/avion_noche.jpg'),
                  opacity: !isDarkMode ? 0.4 : 1, // Replace with your image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, left: 10, right: 10, bottom: 10),
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: <Widget>[
                    const Text(
                      'Los campos * son obligatorios',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _origen(colors),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _destino(colors),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _fechaOrigen(colors, context),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: _fechaLlegada(colors, context),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _precioBilletes(colors),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _notas(colors),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _btnGuardar(ref, colors, context, db, correo),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _btnGuardar(WidgetRef ref, ColorScheme colors, BuildContext context,
      DatabaseHelper db, String correo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
      ),
      child: const Text(
        'Crear viaje',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          // Guarda los datos
          String? origen = origenController.text.toUpperCase().trim();
          String? destino = destinoController.text.toUpperCase().trim();
          String? fechaSalida = fechaOrigenController.text.trim();
          String? fechaLlegada = fechaLlegadaController.text.trim();
          String? precioBilletes = precioBilletesController.text.trim();
          String? notas = notasController.text.trim();
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
                              .add(const Duration(days: 365))
                              .toIso8601String()
                              .substring(0, 10);
                        }
                        String sql =

                            //INSERTO LOS DATOS DEL VIAJE
                            'INSERT INTO Viaje(Origen, Destino, FechaSalida, FechaLlegada, NotasViaje, Correo) VALUES (?, ?, ?, ?, ?, ?)';
                        await db.getConnection().then((conn) async {
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
                            int idViaje =
                                result.elementAt(result.length - 1)[0];

                            //INSERTO LOS DATOS DEL PRECIO
                            String sqlPrecio =
                                'INSERT INTO Gastos_del_Viaje(Descripción, Cantidad, FechaGasto, IdViaje) VALUES (?, ?, ?, ?)';
                            await conn.query(sqlPrecio, [
                              "Gastos en los billetes",
                              precioBilletes,
                              DateTime.now().toIso8601String().substring(0, 10),
                              idViaje
                            ]);
                          }

                          Snackbar()
                              .mensaje(context, 'Viaje creado correctamente');
                        });
                        ref.read(completedTripsProvider.notifier).refresh();
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

  Widget _notas(ColorScheme colors) {
    return TextFormField(
      controller: notasController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'NOTAS DEL VIAJE (opcional)',
        prefixIcon: Icon(
          Icons.comment,
          color: colors.primary,
        ),
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
      validator: (value) {
        if (value!.length < 3 && value.isNotEmpty) {
          return 'Por favor ingrese una nota válida';
        }
        return null;
      },
    );
  }

  Widget _precioBilletes(ColorScheme colors) {
    return TextFormField(
      controller: precioBilletesController,
      decoration: InputDecoration(
        labelText: 'PRECIO BILLETES (opcional)',
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(
          Icons.attach_money,
          color: colors.primary,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        String trimmedValue = value!.trim();
        if (trimmedValue.isNotEmpty) {
          var parsedValue = double.tryParse(trimmedValue);
          if (parsedValue == null || parsedValue < 0.0) {
            return 'Por favor ingrese un precio válido';
          }
        }
        return null;
      },
    );
  }

  Widget _fechaLlegada(ColorScheme colors, BuildContext context) {
    return TextFormField(
      controller: fechaLlegadaController,
      decoration: InputDecoration(
        labelText: 'LLEGADA',
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: colors.primary,
        ),
      ),
      onTap: () async {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // to prevent opening default keyboard
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          fechaLlegadaController.text = date.toIso8601String().substring(0, 10);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        DateTime fechaSalida = DateTime.parse(fechaOrigenController.text);
        DateTime fechaLlegada = DateTime.parse(value);

        if (fechaLlegada.isBefore(fechaSalida) && value.isNotEmpty) {
          return 'Llegada debe ser posterior a Salida';
        }
        return null;
      },
    );
  }

  Widget _fechaOrigen(ColorScheme colors, BuildContext context) {
    return TextFormField(
      controller: fechaOrigenController,
      decoration: InputDecoration(
        labelText: '* SALIDA',
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: colors.primary,
        ),
      ),
      onTap: () async {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // to prevent opening default keyboard
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          fechaOrigenController.text = date.toIso8601String().substring(0, 10);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una fecha de salida';
        }
        return null;
      },
    );
  }

  Widget _destino(ColorScheme colors) {
    return TextFormField(
      controller: destinoController,
      decoration: InputDecoration(
        labelText: '* DESTINO',
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: ubiActual(colors, destinoController, context),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 3) {
          return 'Por favor ingrese un destino válido';
        }
        return null;
      },
    );
  }

  Widget _origen(ColorScheme colors) {
    return TextFormField(
      controller: origenController,
      decoration: InputDecoration(
        labelText: '* ORIGEN',
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: ubiActual(colors, origenController, context),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 3) {
          return 'Por favor ingrese un origen válido';
        }
        return null;
      },
    );
  }
}
