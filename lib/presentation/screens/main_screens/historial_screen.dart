import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../functions/mes_mapa.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

bool hayDatos = false;

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final db = DatabaseHelper();
  bool isLoading = false;
  Map<String, List<ResultRow>> groupedData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    groupedData.clear();

    setState(() {
      isLoading =
          true; // Establecer isLoading en true antes de cargar los datos
    });
    String? correoTemp = await DatabaseHelper().getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      MySqlConnection conn = await db.getConnection();

      final result = await conn.query('''
          SELECT Viaje.Origen, Viaje.Destino, Viaje.FechaSalida, Viaje.FechaLlegada, Viaje.IdViaje, 
          SUM(Gastos_del_Viaje.cantidad) as TotalGastos, (SELECT COUNT(*) FROM Ruta 
          WHERE Ruta.IdViaje = Viaje.IdViaje) as NumRutas FROM Viaje 
          LEFT JOIN Gastos_del_Viaje ON Viaje.IdViaje = Gastos_del_Viaje.IdViaje 
          WHERE Viaje.Correo = "$correo" AND Viaje.FechaLlegada < CURDATE() 
          GROUP BY Viaje.IdViaje ORDER BY Viaje.FechaSalida ASC
          ''');
      if (result.isEmpty) {
        setState(() {
          hayDatos = false;
        });
      } else {
        setState(() {
          hayDatos = true;
        });
        groupedData = await groupDataByMonth(result);
      }
    } else {
      //print("Correo es nulo");
    }
    setState(() {
      isLoading =
          false; // Establecer isLoading en false después de cargar los datos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = Theme.of(context).colorScheme;
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        if (correo == null) {
          return Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                titulo: 'HISTORIAL',
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
                      opacity: !isDarkMode ? 0.4 : 1,
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
                          'Debes iniciar sesión para ver tu historial de viajes',
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
                titulo: 'HISTORIAL',
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
                      opacity: !isDarkMode ? 0.4 : 1,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hayDatos
                        ? Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: groupedData.length,
                                  itemBuilder: (context, index) {
                                    final month =
                                        groupedData.keys.elementAt(index);
                                    return Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            month,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                        ...groupedData[month]!.map((viaje) {
                                          return GestureDetector(
                                            onTap: () {
                                              //print(viaje['IdViaje']);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ActualDetails(
                                                    idViaje: viaje['IdViaje'],
                                                  ),
                                                ),
                                              ).then((value) => setState(() {
                                                    fetchData();
                                                  }));
                                            },
                                            child: ActualTravelCard(
                                              origen: viaje['Origen'],
                                              destino: viaje['Destino'],
                                              fechaSalida: viaje['FechaSalida'],
                                              fechaLlegada:
                                                  viaje['FechaLlegada'],
                                              gastos:
                                                  viaje['TotalGastos'] ?? 0.0,
                                              numRutas: viaje['NumRutas'],
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Expanded(
                            child: Column(
                              mainAxisAlignment: !isDarkMode
                                  ? MainAxisAlignment.spaceAround
                                  : MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 80,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No tienes viajes en tu historial',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 6, 6, 6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                        'Se te agregará un viaje al historial cuando lo completes...¡A qué esperas!.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 6, 6, 6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    isLoading
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .all<Color>(isDarkMode
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                            onPressed: fetchData,
                                            child: Text(
                                              'Actualizar historial',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          )
              ],
            ),
          );
        }
      },
    );
  }
}
