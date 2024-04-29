import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../conf/connectivity.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: customAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            ref: ref,
            titulo: 'FAVORITOS',
          ),
        ),
        body: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: HistorialTravelCard(
                    origen: 'Origen',
                    destino: 'destino',
                    fechaSalida: DateTime.now(),
                    fechaLlegada: DateTime.now()),
                onTap: () {
                  //TODO: Implementar la navegación a la pantalla de detalles del viaje favorito
                  print('hola');
                },
              );
            },
            itemCount: 10),
      ),
    );
  }
}
