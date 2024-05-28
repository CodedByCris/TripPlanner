import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/widgets/interface/bottom_menu.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

import '../../screens/main_screens/new_screen.dart';
import '../../screens/main_screens/user_screen.dart';

class MenuBarrita extends StatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;
  const MenuBarrita({super.key, required this.pageIndex});

  @override
  MenuBarritaState createState() => MenuBarritaState();
}

class MenuBarritaState extends State<MenuBarrita> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // disable swipe navigation
        children: const <Widget>[
          HomeScreen(),
          FavoritesScreen(),
          NewScreen(),
          HistorialScreen(),
          UserScreen()
        ],
      ),
      bottomNavigationBar: BottomMenu(
        currentIndex: widget.pageIndex,
        onPageSelected: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
