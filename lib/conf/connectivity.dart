import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = ChangeNotifierProvider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    init();
  }

  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> init() async {
    await _checkCurrentConnectivity();
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _isConnected = false;
        print('No hay conexión a Internet');
      } else {
        _isConnected = true;
        print('Hay conexión a Internet');
      }
      notifyListeners();
    });
  }

  Future<void> _checkCurrentConnectivity() async {
    var results = await Connectivity().checkConnectivity();
    _isConnected = !results.contains(ConnectivityResult.none);
    print('Conectividad inicial: $_isConnected');
  }
}

class NetworkSensitive extends ConsumerWidget {
  final Widget child;

  const NetworkSensitive({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider).isConnected;

    return isConnected
        ? child
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 5),
                  const Text('Esperando conexión a internet...',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: MediaQuery.of(context).size.height / 20),
                  Image.asset('assets/images/loading.gif')
                ],
              ),
            ),
          );
  }
}
