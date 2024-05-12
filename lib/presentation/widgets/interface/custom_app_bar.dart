import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
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
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.titulo,
        style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20),
      ),
      centerTitle: true,
      //* Modo nocturno
      leading: IconButton(
        onPressed: () {
          widget.ref.read(themeNotifierProvider.notifier).toggleDarkMode();
        },
        icon: Icon(widget.isDarkMode
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined),
        color: widget.colors.primary,
      ),

      //* Icono para las conversaciones
      actions: [
        IconButton(
          onPressed: () {
            context.push('/messages');
          },
          icon: const Icon(Icons.message_outlined),
          color: widget.colors.primary,
        )
      ],
    );
  }
}
