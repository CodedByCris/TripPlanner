import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/screens/auth_screens/splash_screen.dart';
import 'package:trip_planner/presentation/widgets/interface/bottom_widget.dart';
import 'package:trip_planner/presentation/screens/screens.dart';
import '../../presentation/widgets/widgets.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    //* Rutas para la barrita inferior
    GoRoute(
      path: '/home/:page',
      name: MenuBarrita.name,
      builder: (context, state) {
        final pageIndex =
            int.parse((state.pathParameters['page'] ?? 0).toString());
        return MenuBarrita(pageIndex: pageIndex);
      },
    ),

    //* Ruta para los mensajes
    GoRoute(
      path: '/messages',
      builder: (context, state) => const MessagesScreen(),
    ),

    //* Auth Routes
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/recover',
      builder: (context, state) => const RecoverScreen(),
    ),

    //* Ruta para las opciones de configuración del usuario
    GoRoute(
      path: '/theme-changer',
      builder: (context, state) => const ThemeChangerScreen(),
    ),
  ],
);
