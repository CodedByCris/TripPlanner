import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final List<String> travelQuotes = [
    'Preparando las maletas para viajar',
    'Mirando el tiempo en Florida',
    'Consultando el mapa de Nueva York',
  ];

  late final String selectedQuote;

  @override
  void initState() {
    super.initState();
    selectedQuote = travelQuotes[Random().nextInt(travelQuotes.length)];

    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    getToken().then((token) {
      Future.delayed(const Duration(seconds: 3), () {
        if (token != null) {
          getToken().then((token) {
            if (token != null) {
              context.go('/home/0');
            }
          });
        } else {
          context.go('/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nubes.gif'),
                  opacity: 1, // Replace with your image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    final int dots = (controller.value * 4).floor() % 4;
                    return Text(
                      '$selectedQuote ${'.' * dots}',
                      style: TextStyle(
                        fontSize: 30,
                        color: const Color.fromARGB(255, 25, 25, 25)
                            .withOpacity(0.8),
                        shadows: const [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 120, 255, 255),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
