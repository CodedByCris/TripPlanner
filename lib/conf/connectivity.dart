import "dart:async";
import "dart:io";
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionStatusListener {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusListener _singleton =
      ConnectionStatusListener._internal();

  ConnectionStatusListener._internal();
  // Make this constructor public
  static ConnectionStatusListener getInstance() => _singleton;

  bool hasShownNoInternet = false;

  //connectivity_plus
  final Connectivity connectivity = Connectivity();

  //This tracks the current connection status
  bool hasConnection = false;

  //This is how we'll allow subscribing to connection changes
  StreamController<bool> connectionChangeController =
      StreamController.broadcast();
  Stream<bool> get connectionChange => connectionChangeController.stream;

  // Add ValueNotifier
  ValueNotifier<bool> connectionChangeNotifier = ValueNotifier<bool>(false);

  //Flutter connectivity listener
  void _connectionChange(List<ConnectivityResult> results) {
    //Take the latest result
    ConnectivityResult result = results.last;
    checkConnection(result);
  }

  //The test to actually see if there is a connection
  Future<bool> checkConnection(ConnectivityResult resu) async {
    bool previousConnection = hasConnection;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
      connectionChangeNotifier.value = hasConnection; // Update ValueNotifier
    }

    return hasConnection;
  }

  //Hook into connectivity_plus's Stream to listen for changes
  //And check the connection status
  Future<void> initialize() async {
    connectivity.onConnectivityChanged.listen(_connectionChange);
    await checkConnection(
        ConnectivityResult.none); // Check the connection status
  }

  //A clean up method to close our stream
  //Because this is meant to exist through the entire application life cycle this isn't really an issue
  void dispose() {
    connectionChangeController.close();
  }

  updateConnectivity(
    bool hasConnection,
    ConnectionStatusListener connectionStatus,
  ) {
    if (!hasConnection) {
      connectionStatus.hasShownNoInternet = true;
      print('No conexion a internet');
    } else {
      print('Si conexion a internet');
      if (connectionStatus.hasShownNoInternet) {
        connectionStatus.hasShownNoInternet = false;
      }
    }
  }

  initNoInternetListener() async {
    ConnectionStatusListener connectionStatus =
        ConnectionStatusListener._singleton;

    await connectionStatus.initialize();
    if (!connectionStatus.hasConnection) {
      updateConnectivity(false, connectionStatus);
    }
    connectionStatus.connectionChange.listen((event) {
      updateConnectivity(event, connectionStatus);
    });
  }
}
