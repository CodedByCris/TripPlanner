import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../functions/connections.dart';
import '../../widgets/interface/comparador.dart';
import '../../widgets/widgets.dart';

class GuestView extends StatefulWidget {
  const GuestView({super.key});

  @override
  State<GuestView> createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        Tab(
          child: ComparadorWidget(),
        ),
      ],
    );
  }
}
