//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:trip_planner/app.dart';
import 'package:trip_planner/conf/connectivity.dart';
import 'package:trip_planner/conf/theme/app_theme.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'conf/router/app_router.dart';
import 'presentation/Database/connections.dart';
import 'presentation/screens/user_screens/no_connection_screen.dart';

void main() async {
  final StreamChatClient streamChatClient = StreamChatClient(streamKey);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App(
    client: streamChatClient,
  ));
}

class App extends StatelessWidget {
  final StreamChatClient client;
  const App({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase and  Database connection
      future: _initializeApp(),
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return ProviderScope(
              child: MainApp(
            client: client,
          ));
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
  final StreamChatClient client;
  const MainApp({super.key, required this.client});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends ConsumerState<MainApp> {
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
              return StreamChatCore(
                client: widget.client,
                child: child!,
              );
            } else {
              return const NoConnectionScreen();
            }
          },
        );
      },
    );
  }
}
