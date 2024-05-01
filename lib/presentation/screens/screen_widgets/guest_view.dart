import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../Database/connections.dart';
import '../../widgets/interface/comparador.dart';
import '../../widgets/widgets.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComparadorWidget();
  }
}
