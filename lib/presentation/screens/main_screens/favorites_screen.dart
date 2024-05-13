import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/screens/details_screens/favorites_details.dart';

import '../../../conf/connectivity.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(travelDataProvider.notifier).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final groupedData = ref.watch(travelDataProvider);
        final colors = Theme.of(context).colorScheme;
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return NetworkSensitive(
          child: Scaffold(
            appBar: AppBar(
              title: CustomAppBar(
                isDarkMode: isDarkMode,
                colors: colors,
                ref: ref,
                titulo: 'FAVORITOS',
              ),
            ),
            body: groupedData.isNotEmpty
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
                            final month = groupedData.keys.elementAt(index);
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirmación'),
                                            content: const Text(
                                                '¿Estás seguro de que quieres eliminar este viaje?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Aceptar'),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await ref
                                                      .read(travelDataProvider
                                                          .notifier)
                                                      .deleteTravel(
                                                          viaje['IdViaje']);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Viaje eliminado de favoritos")),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FavoriteDetails(
                                            idViaje: viaje['IdViaje'],
                                            correo: viaje['Correo'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: ActualTravelCard(
                                      origen: viaje['Origen'],
                                      destino: viaje['Destino'],
                                      fechaSalida: viaje['FechaSalida'],
                                      fechaLlegada: viaje['FechaLlegada'],
                                      gastos: 20,
                                      numRutas: 3,
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
                        const Text(
                          'No tienes viajes favoritos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 61, 104),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  padding: EdgeInsets.only(bottom: 30),
                                  content: Text(
                                    "Buscando nuevos datos",
                                    textAlign: TextAlign.center,
                                  )),
                            );
                            ref.read(travelDataProvider.notifier).fetchData();
                          },
                          child: const Text('Buscar más...'),
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
