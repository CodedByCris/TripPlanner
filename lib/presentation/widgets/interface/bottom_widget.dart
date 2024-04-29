import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/widgets/interface/bottom_menu.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../screens/main_screens/new_screen.dart';
import '../../screens/main_screens/user_screen.dart';

class MenuBarrita extends StatelessWidget {
  static const name = 'home-screen';
  final int pageIndex;
  const MenuBarrita({super.key, required this.pageIndex});

  final viewRoutes = const <Widget>[
    HomeScreen(),
    FavoritesScreen(),
    NewScreen(),
    HistorialScreen(),
    UserScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: viewRoutes,
      ),
      bottomNavigationBar: BottomMenu(
        currentIndex: pageIndex,
      ),
    );
  }
}
