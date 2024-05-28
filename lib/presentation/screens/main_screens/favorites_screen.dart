import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/details_screens/favorites_details.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../Database/connections.dart';
import '../../functions/mes_mapa.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

bool hayDatoss = false;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final db = DatabaseHelper();
  Map<String, List<ResultRow>> groupedData = {};
  bool isLoading = false;

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

      // Use JOIN to combine Favoritos and Viaje tables
      final result = await conn.query(
          '''SELECT Viaje.Origen, Viaje.Destino, Viaje.FechaSalida, Viaje.FechaLlegada, 
          Viaje.IdViaje, Viaje.Correo, Gastos.TotalGastos, (SELECT COUNT(*) FROM Ruta 
          WHERE Ruta.IdViaje = Viaje.IdViaje) as NumRutas FROM Favoritos 
          JOIN Viaje ON Favoritos.IdViaje = Viaje.IdViaje 
          LEFT JOIN (SELECT IdViaje, SUM(Cantidad) as TotalGastos 
          FROM Gastos_del_Viaje GROUP BY IdViaje) as Gastos ON Gastos.IdViaje = Viaje.IdViaje 
          WHERE Favoritos.Correo = ?
          ''', [correo]);

      if (result.isEmpty) {
        setState(() {
          hayDatoss = false;
        });
      } else {
        setState(() {
          hayDatoss = true;
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

        return Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                titulo: 'FAVORITOS',
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
                Column(
                  children: [
                    !hayDatoss
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: !isDarkMode
                                  ? MainAxisAlignment.spaceAround
                                  : MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.heart_broken,
                                      size: 80,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No tienes viajes favoritos',
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
                                        'Puedes agregar uno en nuestro comparador de viajes en la pantalla principal.',
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
                                              'Actualizar favoritos',
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
                        : const SizedBox(height: 0),
                    hayDatoss
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: groupedData.length,
                              itemBuilder: (context, index) {
                                final month = groupedData.keys.elementAt(index);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
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
                                        onLongPress: () async {
                                          final conn = await db.getConnection();
                                          await conn.query(
                                              'DELETE FROM Favoritos WHERE Correo = ? AND IdViaje = ?',
                                              [correo, viaje['IdViaje']]);
                                        },
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FavoriteDetails(
                                                idViaje: viaje['IdViaje'],
                                                correo2: viaje['Correo'],
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
                                          fechaLlegada: viaje['FechaLlegada'],
                                          gastos: viaje['TotalGastos'] ?? 0.0,
                                          numRutas: viaje['NumRutas'] ?? 0,
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ));
      },
    );
  }
}
