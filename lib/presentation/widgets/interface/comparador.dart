// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/search_screen.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../providers/theme_provider.dart';
import '../ubi.dart';

class ComparadorWidget extends StatefulWidget {
  const ComparadorWidget({
    super.key,
  });

  @override
  State<ComparadorWidget> createState() => _ComparadorWidgetState();
}

class _ComparadorWidgetState extends State<ComparadorWidget> {
  Results? resultViaje;
  MySqlConnection? conn;
  DatabaseHelper? bd;
  GlobalKey<FormState>? formKey;
  TextEditingController? origenText;
  TextEditingController? destinoText;
  TextEditingController? precioMinText;
  TextEditingController? precioMaxText;
  TextEditingController? fechaSalidaText;
  TextEditingController? fechaLlegadaText;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    origenText = TextEditingController();
    destinoText = TextEditingController();
    precioMinText = TextEditingController();
    precioMaxText = TextEditingController();
    fechaSalidaText = TextEditingController();
    fechaLlegadaText = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return Stack(children: [
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //!Titulo
                      const Text(
                        'ENCUENTRA TU VIAJE PERFECTO',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      //!Subtitulo
                      const Text(
                        'Introduce los detalles de tu viaje y descubre las mejores actividades y ofertas',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      //!Campo de texto origen
                      _origen(colors),
                      const SizedBox(height: 20),

                      //!Campo de texto destino
                      _destino(colors),
                      const SizedBox(height: 20),

                      //! Precio mínimo y máximo
                      _precio(colors),
                      const SizedBox(height: 20),

                      //!Fecha de salida y llegada
                      fechas(colors, context),
                      const SizedBox(height: 50),

                      //!Botón de buscar
                      _btnBuscar(colors, isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          )
        ]);
      },
    );
  }

  Widget _precio(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          //*Minimo
          child: TextFormField(
            controller: precioMinText,
            decoration: InputDecoration(
              labelText: 'MINIMO',
              prefixIcon: Icon(
                Icons.attach_money,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 20),

        //*Maximo
        Expanded(
          child: TextFormField(
            controller: precioMaxText,
            decoration: InputDecoration(
              labelText: 'MAXIMO',
              prefixIcon: Icon(
                Icons.attach_money,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _btnBuscar(ColorScheme colors, isDarkMode) {
    //print("Correo$correo");
    return ElevatedButton.icon(
      onPressed: () async {
        if (formKey != null && formKey!.currentState!.validate()) {
          // Guarda los datos
          String origen = origenText!.text;
          String destino = destinoText!.text;
          String precioMin = precioMinText!.text;
          String precioMax = precioMaxText!.text;
          String fechaSalida = fechaSalidaText!.text;
          String fechaLlegada = fechaLlegadaText!.text;

          // Conecta a la base de datos
          bd = DatabaseHelper();
          conn = await bd!.getConnection();
          resultViaje = await consultas(
            origen: origen,
            destino: destino.isNotEmpty ? destino : null,
            fechaSalida:
                fechaSalida.isNotEmpty ? DateTime.parse(fechaSalida) : null,
            fechaLlegada:
                fechaLlegada.isNotEmpty ? DateTime.parse(fechaLlegada) : null,
            precioMin: precioMin.isNotEmpty ? double.parse(precioMin) : null,
            precioMax: precioMax.isNotEmpty ? double.parse(precioMax) : null,
          );
          //print(resultViaje);

          // Comprueba si la consulta devuelve datos
          if (resultViaje != null && resultViaje!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  isDarkMode: isDarkMode,
                  resultViaje: resultViaje!,
                ),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('No se encontraron resultados'),
                  content: const Text(
                      'No se encontraron viajes con los criterios seleccionados.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cerrar'),
                      onPressed: () {
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
      icon: const Icon(Icons.search),
      label: const Text("Buscar"),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colors.primary, // foreground
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        textStyle: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget fechas(ColorScheme colors, BuildContext context) {
    return Row(
      children: [
        Expanded(
          //*Salida
          child: TextFormField(
            controller: fechaSalidaText,
            decoration: InputDecoration(
                labelText: 'SALIDA',
                prefixIcon: Icon(
                  Icons.calendar_month,
                  color: colors.primary,
                ),
                border: const OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true),
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
                fechaSalidaText!.text = date.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        //*Llegada
        Expanded(
          child: TextFormField(
            controller: fechaLlegadaText,
            decoration: InputDecoration(
              labelText: 'LLEGADA',
              prefixIcon: Icon(
                Icons.calendar_month,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
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
                fechaLlegadaText!.text =
                    date.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _destino(ColorScheme colors) {
    return TextFormField(
      controller: destinoText,
      decoration: InputDecoration(
        labelText: 'DESTINO',
        prefixIcon: ubiActual(colors, destinoText, context),
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _origen(ColorScheme colors) {
    return TextFormField(
      controller: origenText,
      decoration: InputDecoration(
        labelText: '* ORIGEN',
        prefixIcon: ubiActual(colors, origenText, context),
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un punto de origen';
        }
        return null;
      },
    );
  }

  String? correoConsulta;
  //!Consultas
  Future<Results> consultas({
    required String origen,
    String? destino,
    DateTime? fechaSalida,
    DateTime? fechaLlegada,
    double? precioMin,
    double? precioMax,
  }) async {
    if (correo == null || correo!.isEmpty) {
      correoConsulta = "";
    } else {
      correoConsulta = correo!.trim();
    }
    List<dynamic> parameters = [origen.toUpperCase().trim(), correoConsulta];
    String query = '''
SELECT Viaje.Destino, Viaje.Origen, Viaje.FechaSalida, Viaje.FechaLlegada, Viaje.Correo,
 Viaje.IdViaje, SUM(Gastos_del_Viaje.Cantidad) as TotalGastos, 
 (SELECT COUNT(*) FROM Ruta WHERE Ruta.IdViaje = Viaje.IdViaje) as NumRutas
FROM Viaje LEFT JOIN Gastos_del_Viaje ON Viaje.IdViaje = Gastos_del_Viaje.IdViaje 
WHERE Viaje.Origen = ? AND Viaje.Correo != ?
''';

    if (destino != null) {
      query += ' AND Viaje.Destino = ?';
      parameters.add(destino.toUpperCase().trim());
    }

    if (fechaSalida != null) {
      query += ' AND Viaje.FechaSalida >= ?';
      String fechaSalidaNormal = fechaSalida.toIso8601String().substring(0, 10);
      parameters.add(fechaSalidaNormal);
    }

    if (fechaLlegada != null) {
      query += ' AND Viaje.FechaLlegada <= ?';
      String fechaLlegadaNormal =
          fechaLlegada.toIso8601String().substring(0, 10);
      parameters.add(fechaLlegadaNormal);
    }

    query += ' GROUP BY Viaje.IdViaje';

    if (precioMin != null || precioMax != null) {
      precioMin = precioMin ?? 0;
      precioMax = precioMax ?? 999999;
      query += ' HAVING SUM(Gastos_del_Viaje.Cantidad) BETWEEN ? AND ?';
      parameters.addAll([precioMin, precioMax]);
    }

    query += ' ORDER BY Viaje.FechaSalida ASC';

    //print("origen $origen"
    " __  destino $destino"
        " __  fechaSalida $fechaSalida"
        " __  fechaLlegada $fechaLlegada"
        " __  precioMin $precioMin"
        " __  precioMax $precioMax";
    //print(resultViaje);
    return resultViaje = await conn!.query(query, parameters);
  }
}
