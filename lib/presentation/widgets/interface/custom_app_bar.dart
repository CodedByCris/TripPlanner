import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';

class customAppBar extends StatelessWidget {
  const customAppBar({
    super.key,
    required this.isDarkMode,
    required this.colors,
    required this.ref,
    required this.titulo,
  });

  final bool isDarkMode;
  final WidgetRef ref;
  final ColorScheme colors;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titulo,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      centerTitle: true,
      //* Modo nocturno
      leading: IconButton(
        onPressed: () {
          ref.read(themeNotifierProvider.notifier).toggleDarkMode();
        },
        icon: Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
        color: colors.primary,
      ),

      //* Icono para las conversaciones
      actions: [
        IconButton(
          onPressed: () {
            context.push('/messages');
          },
          icon: const Icon(Icons.message_outlined),
          color: colors.primary,
        )
      ],
    );
  }
}
