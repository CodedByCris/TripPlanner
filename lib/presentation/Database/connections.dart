import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/screens/screens.dart';

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
