import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onPageSelected;
  const BottomMenu(
      {super.key, required this.currentIndex, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConvexAppBar(
      style: TabStyle.custom,
      initialActiveIndex: currentIndex,
      onTap: (index) => onPageSelected(index),
      backgroundColor: colors.primary,
      items: const [
        TabItem(icon: Icons.home_outlined, title: 'Home'),
        TabItem(icon: Icons.favorite_outline, title: 'Favoritos'),
        TabItem(icon: Icons.add_circle, title: 'Nuevo'),
        TabItem(icon: Icons.history_outlined, title: 'Historial'),
        TabItem(icon: Icons.account_box, title: 'Usuario'),
      ],
      color: Colors.white,
    );
  }
}
