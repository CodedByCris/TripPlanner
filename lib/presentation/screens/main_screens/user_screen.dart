import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../conf/connectivity.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/interface/custom_app_bar.dart';
import '../../providers/token_provider.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

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
            titulo: 'PERFIL DE USUARIO',
          ),
        ),
        //*Cuerpo de la aplicación
        body: const _UserView(),
      ),
    );
  }
}

class _UserView extends ConsumerStatefulWidget {
  const _UserView();

  @override
  ConsumerState<_UserView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<_UserView> {
  @override
  Widget build(BuildContext context) {
    final List<Color> colors = ref.watch(colorListProvider);

    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          //* Foto del usuario
          const Icon(
            Icons.person,
            size: 100,
          ),
          const SizedBox(height: 50),

          //*LogOut
          const LogOutButton(),

          const SizedBox(height: 50),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: colors[selectedColor],
                    size: 30,
                  ),
                  title: const Text(
                    "Nombre de usuario",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Cris",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.email,
                    color: colors[selectedColor],
                    size: 30,
                  ),
                  title: const Text(
                    "Correo electrónico",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("asdad@gmail.coim",
                      style: TextStyle(
                        fontSize: 15,
                      )),
                ),
                //* Colores de la aplicación
                ExpansionTile(
                  leading: Icon(
                    Icons.format_paint_sharp,
                    color: colors[selectedColor],
                    size: 30,
                  ),
                  title: const Text(
                    "Apariencia de la aplicación",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final color = colors[index];
                          return RadioListTile(
                              subtitle: const Text('Click para cambiar'),
                              title: Text(
                                "Cambiar color",
                                style: TextStyle(color: color),
                              ),
                              activeColor: color,
                              value: index,
                              groupValue: selectedColor,
                              onChanged: (value) {
                                ref
                                    .read(themeNotifierProvider.notifier)
                                    .changeColorIndex(index);
                              });
                        },
                        itemCount: colors.length,
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: colors[selectedColor],
                    size: 30,
                  ),
                  title: const Text(
                    "Información de la app",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Version 1.0",
                      style: TextStyle(
                        fontSize: 15,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogOutButton extends ConsumerWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cerrar sesión'),
              content:
                  const Text('¿Estás seguro de que quieres cerrar sesión?'),
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
                    // Delete the token
                    await ref.read(tokenProvider.notifier).deleteToken();

                    // Redirect the user to the login screen
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/login');
                  },
                ),
              ],
            );
          },
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      child: const Text(
        "Cerrar sesión",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
