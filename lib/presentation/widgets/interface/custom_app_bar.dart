import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../providers/token_provider.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({
    super.key,
    required this.isDarkMode,
    required this.colors,
    required this.titulo,
  });

  final bool isDarkMode;
  final ColorScheme colors;
  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(tokenProvider);
    return AppBar(
      title: Text(
        titulo,
        style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, fontSize: 20),
      ),
      centerTitle: true,
      // Modo nocturno
      leading: IconButton(
        onPressed: () {
          ref.read(themeNotifierProvider.notifier).toggleDarkMode();
        },
        icon: Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
        color: colors.primary,
      ),

      // Icono para las conversaciones
      actions: correo != null
          ? [
              IconButton(
                onPressed: () {
                  context.push('/messages');
                },
                icon: const Icon(Icons.message_outlined),
                color: colors.primary,
              )
            ]
          : [],
    );
  }
}
