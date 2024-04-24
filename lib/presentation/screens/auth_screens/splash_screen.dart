import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    getToken().then((token) {
      Future.delayed(const Duration(seconds: 30), () {
        if (token != null) {
          context.go('/home/0');
        } else {
          context.go('/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 198, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/nubes.gif'),
            SizedBox(
              width: 300,
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final int dots = (controller.value * 4).floor() % 4;
                  return Text(
                    'Comprobando el tiempo en la playa${'.' * dots}',
                    style: TextStyle(
                      fontSize: 24,
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
