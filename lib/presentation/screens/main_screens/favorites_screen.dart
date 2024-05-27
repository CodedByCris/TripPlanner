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
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : correo != null
                  ? hayDatoss
                      ? Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Pulsa para ver todos los datos del viaje",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: groupedData.length,
                                itemBuilder: (context, index) {
                                  final month =
                                      groupedData.keys.elementAt(index);
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          month,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ...groupedData[month]!.map((viaje) {
                                        return GestureDetector(
                                          onLongPress: () async {
                                            final conn =
                                                await db.getConnection();
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
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.heart_broken,
                                  size: 100, color: colors.primary),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No tienes viajes favoritos',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? colors.secondary
                                        : const Color.fromARGB(255, 9, 61, 104),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Puedes agregar uno en nuestro comparador de viajes en la pantalla principal.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? colors.secondary
                                        : const Color.fromARGB(255, 87, 87, 87),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: fetchData,
                                child: const Text('Actualizar favoritos'),
                              ),
                            ],
                          ),
                        )
                  : Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Debes iniciar sesión para marcar un viaje como favoritos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 9, 61, 104),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                GoRouter.of(context).go('/login');
                              },
                              child: const Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }
}
