import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';

class ThemeChangerScreen extends ConsumerWidget {
  const ThemeChangerScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar tema"),
        actions: [
          IconButton(
              icon: Icon(isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined),
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleDarkMode();
              })
        ],
      ),
      body: const _ThemeChangerView(),
    );
  }
}

class _ThemeChangerView extends ConsumerWidget {
  const _ThemeChangerView();

  @override
  Widget build(BuildContext context, ref) {
    final List<Color> colors = ref.watch(colorListProvider);

    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;
    return ListView.builder(
      itemBuilder: (context, index) {
        final color = colors[index];
        return RadioListTile(
            title: Text(
              "Este color",
              style: TextStyle(color: color),
            ),
            activeColor: color,
            value: index,
            groupValue: selectedColor,
            onChanged: (value) {
              ref.read(themeNotifierProvider.notifier).changeColorIndex(index);
            });
      },
      itemCount: colors.length,
    );
  }
}
