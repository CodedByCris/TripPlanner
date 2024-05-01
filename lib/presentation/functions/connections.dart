import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = 'bdjpy89pmoprquu50mej-mysql.services.clever-cloud.com';
  static String user = 'uxcs1d5heho1k4di';
  static String password = 'RszQXJpndfXcCIhuZF3Q';
  static String db = 'bdjpy89pmoprquu50mej';
  static int port = 3306;

  MySqlConnection? _connection; // Store the connection instance

  Mysql() {
    // No need to create an instance on initialization
  }

  Future<MySqlConnection> getConnection() async {
    ConnectionSettings settings = ConnectionSettings(
      host: host,
      password: password,
      db: db,
      port: port,
      user: user,
    );

    _connection = await MySqlConnection.connect(settings);
    return _connection!; // Return the connection
  }

  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      print('Conexion cerrada');
    }
  }
}
