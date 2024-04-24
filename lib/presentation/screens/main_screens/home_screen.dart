import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/guest_view.dart';

import '../../../conf/connectivity.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';
import '../screen_widgets/home_view.dart';
import '../screens.dart';

String? correo;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.read(themeNotifierProvider).isDarkMode;
    final correo =
        ref.watch(tokenProvider); // Escucha los cambios en el estado del correo
    final hasToken = correo?.isNotEmpty ?? false;
    print(correo);

    return NetworkSensitive(
      child: DefaultTabController(
        length: correo != null ? 2 : 1,
        child: Scaffold(
          appBar: AppBar(
            title: customAppBar(
              isDarkMode: isDarkMode,
              colors: colors,
              ref: ref,
              titulo: 'TRIP PLANNER',
            ),
            bottom: hasToken
                ? const TabBar(
                    tabs: [
                      Tab(
                        text: 'VIAJE ACTUAL',
                      ),
                      Tab(
                        text: 'COMPARADOR DE VIAJES',
                      ),
                    ],
                  )
                : null,
          ),
          body: correo != null ? const HomeView() : const GuestView(),
        ),
      ),
    );
  }
}

Future<String?> getCorreo() async {
  return await getToken();
}

Future<String?> borrarCorreo() async {
  return await deleteToken();
}
