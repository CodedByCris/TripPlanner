import 'dart:collection';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

// class ConnectionPool {
//   final int maxConnections;
//   int _openedConnections = 0;
//   final Queue<MySqlConnection> _connectionQueue = Queue<MySqlConnection>();

//   ConnectionPool({required this.maxConnections});

//   Future<MySqlConnection> getConnection(ConnectionSettings settings) async {
//     if (_connectionQueue.isNotEmpty) {
//       return _connectionQueue.removeFirst();
//     }

//     if (_openedConnections >= maxConnections) {
//       throw Exception('Max number of connections reached');
//     }

//     final conn = await MySqlConnection.connect(settings);
//     _openedConnections++;

//     return conn;
//   }

//   void releaseConnection(MySqlConnection conn) {
//     conn.close();
//     _connectionQueue.add(conn);
//   }
// }

//class Mysql {
//   static String host = 'bdjpy89pmoprquu50mej-mysql.services.clever-cloud.com';
//   static String user = 'uxcs1d5heho1k4di';
//   static String password = 'RszQXJpndfXcCIhuZF3Q';
//   static String db = 'bdjpy89pmoprquu50mej';
//   static int port = 3306;

//   ConnectionPool pool = ConnectionPool(maxConnections: 5);

//   Future<MySqlConnection> getConnection() async {
//     ConnectionSettings settings = ConnectionSettings(
//       host: host,
//       password: password,
//       db: db,
//       port: port,
//       user: user,
//     );

//     try {
//       return pool.getConnection(settings);
//     } catch (e) {
//       print('Error al obtener la conexión: $e');
//       rethrow;
//     }
//   }

// void closeConnection(MySqlConnection conn) {

//   pool.releaseConnection(conn);
// }

//}

class DatabaseHelper {
  static final DatabaseHelper _singleton = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _singleton;
  }

  DatabaseHelper._internal();

  MySqlConnection? _connection;

  Future<MySqlConnection> getConnection() async {
    if (_connection == null) {
      final connSettings = ConnectionSettings(
        host: 'bdjpy89pmoprquu50mej-mysql.services.clever-cloud.com',
        port: 3306,
        user: 'uxcs1d5heho1k4di',
        password: 'RszQXJpndfXcCIhuZF3Q',
        db: 'bdjpy89pmoprquu50mej',
      );
      _connection = await MySqlConnection.connect(connSettings);
    }
    return _connection!;
  }

  Future<String?> getCorreo() async {
    return await getToken();
  }

  Future<String?> borrarCorreo() async {
    return await deleteToken();
  }
}
