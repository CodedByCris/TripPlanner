import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/main_screens/home_screen.dart';

import '../../functions/connections.dart';
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
    return TabBarView(
      children: [
        Tab(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Quieres saber cuánto vas a gastar en tu próximo viaje qué actividades realizar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Utiliza nuestro Comparador de viajes',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ORIGEN',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'DESTINO',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PRECIO MIN',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'PRECIO MAX',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FECHA SALIDA',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 50),
                    Text(
                      'FECHA ENTRADA',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.search_outlined),
                  label: const Text("Buscar"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
