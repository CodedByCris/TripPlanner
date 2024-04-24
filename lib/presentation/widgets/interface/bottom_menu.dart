import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomMenu extends StatelessWidget {
  final int currentIndex;
  const BottomMenu({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go("/home/0");
        break;
      case 1:
        context.go("/home/1");
        break;
      case 2:
        context.go("/home/2");
        break;
      case 3:
        context.go("/home/3");
        break;
      case 4:
        context.go("/home/4");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConvexAppBar(
      style: TabStyle.custom,
      initialActiveIndex: currentIndex,
      onTap: (index) => onItemTapped(context, index),
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
