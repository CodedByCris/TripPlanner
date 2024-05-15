//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/conf/connectivity.dart';
import 'package:trip_planner/conf/theme/app_theme.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'conf/router/app_router.dart';
import 'presentation/Database/connections.dart';
import 'presentation/screens/user_screens/no_connection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase and Database connection
      future: _initializeApp(),
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return const ProviderScope(child: MainApp());
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }

  Future _initializeApp() async {
    await Firebase.initializeApp();
    await DatabaseHelper().getConnection();
  }
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  final ConnectionStatusListener _connectionStatus =
      ConnectionStatusListener.getInstance();

  @override
  void initState() {
    super.initState();
    _connectionStatus.initNoInternetListener();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = ref.watch(themeNotifierProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: _connectionStatus.connectionChangeNotifier,
      builder: (context, hasConnection, _) {
        return MaterialApp.router(
          title: "Trip Planner",
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: appTheme.getTheme(),
          builder: (context, child) {
            if (hasConnection) {
              return child!;
            } else {
              return const NoConnectionScreen();
            }
          },
        );
      },
    );
  }
}
